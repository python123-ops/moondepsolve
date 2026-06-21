///|
pub(all) enum UpgradeStrategy {
  HighestCompatible
  MinimalChange
} derive(Eq)

///|
pub(all) struct UpgradeOptions {
  strategy : UpgradeStrategy
  max_states : Int
} derive(Eq)

///|
pub(all) enum UpgradeChangeKind {
  Add
  Remove
  Upgrade
  Downgrade
} derive(Eq)

///|
pub(all) struct UpgradeChange {
  kind : UpgradeChangeKind
  package_name : String
  from_version : Version?
  to_version : Version?
} derive(Eq)

///|
pub(all) struct UpgradePlan {
  strategy : UpgradeStrategy
  resolution : Resolution
  changes : Array[UpgradeChange]
} derive(Eq)

///|
pub(all) enum UpgradeError {
  DependencyFailure(DepError)
  InvalidSearchLimit(Int)
  SearchLimitExceeded(Int)
} derive(Eq)

///|
priv struct UpgradeSearch {
  registry : Registry
  current : Resolution
  max_states : Int
  mut states : Int
  mut exceeded : Bool
  mut best : Resolution
  mut best_cost : Int
}

///|
pub fn default_upgrade_options(strategy : UpgradeStrategy) -> UpgradeOptions {
  { strategy, max_states: 100000 }
}

///|
pub fn plan_upgrade(
  root : Array[Dependency],
  current : Resolution,
  registry : Registry,
  options : UpgradeOptions,
) -> Result[UpgradePlan, UpgradeError] {
  if options.max_states <= 0 {
    return Err(InvalidSearchLimit(options.max_states))
  }
  let highest = match resolve(root, registry) {
    Ok(resolution) => canonical_resolution(resolution)
    Err(error) => return Err(DependencyFailure(error))
  }
  let resolution = match options.strategy {
    HighestCompatible => highest
    MinimalChange => {
      let search : UpgradeSearch = {
        registry,
        current,
        max_states: options.max_states,
        states: 0,
        exceeded: false,
        best: highest,
        best_cost: upgrade_changes(current, highest).length(),
      }
      let pending : Array[PendingDep] = []
      let roots = root.copy()
      roots.sort_by(compare_dependency)
      for dependency in roots {
        pending.push({ dependency, path: "root -> " + dependency.name })
      }
      search_upgrade_solutions(search, [], pending)
      if search.exceeded {
        return Err(SearchLimitExceeded(options.max_states))
      }
      search.best
    }
  }
  Ok({
    strategy: options.strategy,
    resolution,
    changes: upgrade_changes(current, resolution),
  })
}

///|
pub fn format_upgrade_plan(plan : UpgradePlan) -> String {
  let builder = StringBuilder()
  builder.write_string("strategy: ")
  builder.write_string(upgrade_strategy_text(plan.strategy))
  builder.write_string("\nchanges: ")
  builder.write_string(plan.changes.length().to_string())
  builder.write_string("\n")
  for change in plan.changes {
    builder.write_string(format_upgrade_change(change))
    builder.write_string("\n")
  }
  builder.to_string()
}

///|
pub fn format_upgrade_error(error : UpgradeError) -> String {
  match error {
    DependencyFailure(error) =>
      "upgrade planning failed: " + format_error(error)
    InvalidSearchLimit(limit) =>
      "invalid upgrade search limit: \{limit}; expected a positive value"
    SearchLimitExceeded(limit) =>
      "upgrade search limit exceeded after \{limit} states"
  }
}

///|
fn search_upgrade_solutions(
  search : UpgradeSearch,
  selected : Array[PackageVersion],
  pending : Array[PendingDep],
) -> Unit {
  if search.exceeded {
    return
  }
  search.states = search.states + 1
  if search.states > search.max_states {
    search.exceeded = true
    return
  }
  if partial_upgrade_cost(search.current, selected) > search.best_cost {
    return
  }
  if pending.length() == 0 {
    let candidate = canonical_resolution({ packages: selected })
    let cost = upgrade_changes(search.current, candidate).length()
    if cost < search.best_cost ||
      (cost == search.best_cost && prefer_resolution(candidate, search.best)) {
      search.best = candidate
      search.best_cost = cost
    }
    return
  }
  let current = pending[0]
  let rest = pending[1:].to_owned()
  match find_selected(selected, current.dependency.name) {
    Some(item) =>
      if matches(item.version, current.dependency.req) {
        search_upgrade_solutions(search, selected, rest)
      }
    None => {
      let candidates = matching_candidates(
        search.registry,
        current.dependency.name,
        current.dependency.req,
      )
      prefer_current_candidate(
        candidates,
        search.current,
        current.dependency.name,
      )
      for candidate in candidates {
        if search.exceeded {
          return
        }
        let next_selected = selected.copy()
        next_selected.push(candidate)
        let next_pending = rest.copy()
        let parent = current.path + "@" + format_version(candidate.version)
        let dependencies = candidate.dependencies.copy()
        dependencies.sort_by(compare_dependency)
        for dependency in dependencies {
          next_pending.push({
            dependency,
            path: parent + " -> " + dependency.name,
          })
        }
        search_upgrade_solutions(search, next_selected, next_pending)
      }
    }
  }
}

///|
fn upgrade_changes(
  current : Resolution,
  target : Resolution,
) -> Array[UpgradeChange] {
  let changes : Array[UpgradeChange] = []
  for item in target.packages {
    match find_selected(current.packages, item.name) {
      None =>
        changes.push({
          kind: Add,
          package_name: item.name,
          from_version: None,
          to_version: Some(item.version),
        })
      Some(existing) => {
        let order = compare_version(item.version, existing.version)
        if order != 0 {
          changes.push({
            kind: if order > 0 {
              Upgrade
            } else {
              Downgrade
            },
            package_name: item.name,
            from_version: Some(existing.version),
            to_version: Some(item.version),
          })
        }
      }
    }
  }
  for item in current.packages {
    if find_selected(target.packages, item.name) is None {
      changes.push({
        kind: Remove,
        package_name: item.name,
        from_version: Some(item.version),
        to_version: None,
      })
    }
  }
  changes.sort_by((left, right) => {
    compare_text(left.package_name, right.package_name)
  })
  changes
}

///|
fn partial_upgrade_cost(
  current : Resolution,
  selected : Array[PackageVersion],
) -> Int {
  let mut cost = 0
  for item in selected {
    match find_selected(current.packages, item.name) {
      Some(existing) =>
        if compare_version(existing.version, item.version) != 0 {
          cost = cost + 1
        }
      None => cost = cost + 1
    }
  }
  cost
}

///|
fn canonical_resolution(resolution : Resolution) -> Resolution {
  let packages = resolution.packages.copy()
  packages.sort_by(compare_upgrade_package)
  { packages, }
}

///|
fn compare_upgrade_package(
  left : PackageVersion,
  right : PackageVersion,
) -> Int {
  let by_name = compare_text(left.name, right.name)
  if by_name != 0 {
    return by_name
  }
  compare_version(right.version, left.version)
}

///|
fn compare_dependency(left : Dependency, right : Dependency) -> Int {
  let by_name = compare_text(left.name, right.name)
  if by_name != 0 {
    return by_name
  }
  compare_text(left.req.raw, right.req.raw)
}

///|
fn prefer_resolution(candidate : Resolution, current : Resolution) -> Bool {
  let shared = if candidate.packages.length() < current.packages.length() {
    candidate.packages.length()
  } else {
    current.packages.length()
  }
  for index in 0..<shared {
    let left = candidate.packages[index]
    let right = current.packages[index]
    let by_name = compare_text(left.name, right.name)
    if by_name != 0 {
      return by_name < 0
    }
    let by_version = compare_version(left.version, right.version)
    if by_version != 0 {
      return by_version > 0
    }
  }
  candidate.packages.length() > current.packages.length()
}

///|
fn prefer_current_candidate(
  candidates : Array[PackageVersion],
  current : Resolution,
  name : String,
) -> Unit {
  match find_selected(current.packages, name) {
    None => ()
    Some(existing) => {
      let mut found = -1
      for index, candidate in candidates {
        if compare_version(candidate.version, existing.version) == 0 {
          found = index
        }
      }
      if found > 0 {
        let candidate = candidates.remove(found)
        candidates.insert(0, candidate)
      }
    }
  }
}

///|
fn upgrade_strategy_text(strategy : UpgradeStrategy) -> String {
  match strategy {
    HighestCompatible => "highest-compatible"
    MinimalChange => "minimal-change"
  }
}

///|
fn format_upgrade_change(change : UpgradeChange) -> String {
  match (change.kind, change.from_version, change.to_version) {
    (Add, None, Some(version)) =>
      "add \{change.package_name} \{format_version(version)}"
    (Remove, Some(version), None) =>
      "remove \{change.package_name} \{format_version(version)}"
    (Upgrade, Some(from), Some(to)) =>
      "upgrade \{change.package_name} \{format_version(from)} -> \{format_version(to)}"
    (Downgrade, Some(from), Some(to)) =>
      "downgrade \{change.package_name} \{format_version(from)} -> \{format_version(to)}"
    _ => abort("invalid upgrade change")
  }
}
