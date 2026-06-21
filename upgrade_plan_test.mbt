///|
fn upgrade_version(input : String) -> @moondepsolve.Version {
  match @moondepsolve.parse_version(input) {
    Ok(version) => version
    Err(err) => abort(@moondepsolve.format_error(err))
  }
}

///|
fn upgrade_req(input : String) -> @moondepsolve.VersionReq {
  match @moondepsolve.parse_req(input) {
    Ok(req) => req
    Err(err) => abort(@moondepsolve.format_error(err))
  }
}

///|
fn upgrade_dep(name : String, req : String) -> @moondepsolve.Dependency {
  { name, req: upgrade_req(req) }
}

///|
fn upgrade_pkg(
  name : String,
  version : String,
  dependencies : Array[@moondepsolve.Dependency],
) -> @moondepsolve.PackageVersion {
  { name, version: upgrade_version(version), dependencies }
}

///|
fn upgrade_plan(
  root : Array[@moondepsolve.Dependency],
  current : @moondepsolve.Resolution,
  packages : Array[@moondepsolve.PackageVersion],
  strategy : @moondepsolve.UpgradeStrategy,
  max_states : Int,
) -> @moondepsolve.UpgradePlan {
  match
    @moondepsolve.plan_upgrade(root, current, { packages, }, {
      strategy,
      max_states,
    }) {
    Ok(plan) => plan
    Err(err) => abort(@moondepsolve.format_upgrade_error(err))
  }
}

///|
test "highest-compatible plan upgrades to the newest valid resolution" {
  let current : @moondepsolve.Resolution = {
    packages: [
      upgrade_pkg("app", "1.0.0", [upgrade_dep("core", "^1.0.0")]),
      upgrade_pkg("core", "1.0.0", []),
    ],
  }
  let plan = upgrade_plan(
    [upgrade_dep("app", "1.0.0")],
    current,
    [
      upgrade_pkg("app", "1.0.0", [upgrade_dep("core", "^1.0.0")]),
      upgrade_pkg("core", "1.0.0", []),
      upgrade_pkg("core", "1.2.0", []),
    ],
    HighestCompatible,
    100000,
  )
  assert_true(plan.strategy is HighestCompatible)
  assert_eq(plan.changes.length(), 1)
  guard plan.changes[0]
    is {
      kind: Upgrade,
      package_name: "core",
      from_version: Some(from_version),
      to_version: Some(to_version),
    } else {
    abort("expected a core upgrade")
  }
  assert_eq(@moondepsolve.format_version(from_version), "1.0.0")
  assert_eq(@moondepsolve.format_version(to_version), "1.2.0")
}

///|
test "minimal-change plan finds the global optimum instead of keeping lock greedily" {
  let current : @moondepsolve.Resolution = {
    packages: [
      upgrade_pkg("app", "1.0.0", []),
      upgrade_pkg("left", "1.0.0", []),
      upgrade_pkg("right", "1.0.0", []),
    ],
  }
  let plan = upgrade_plan(
    [upgrade_dep("app", "^1.0.0")],
    current,
    [
      upgrade_pkg("app", "1.0.0", [
        upgrade_dep("left", "^2.0.0"),
        upgrade_dep("right", "^2.0.0"),
      ]),
      upgrade_pkg("app", "1.1.0", [
        upgrade_dep("left", "^1.0.0"),
        upgrade_dep("right", "^1.0.0"),
      ]),
      upgrade_pkg("left", "1.0.0", []),
      upgrade_pkg("left", "2.0.0", []),
      upgrade_pkg("right", "1.0.0", []),
      upgrade_pkg("right", "2.0.0", []),
    ],
    MinimalChange,
    100000,
  )
  assert_eq(plan.changes.length(), 1)
  assert_eq(plan.changes[0].package_name, "app")
  assert_true(plan.changes[0].kind is Upgrade)
  guard plan.changes[0].to_version is Some(version) else {
    abort("expected target app version")
  }
  assert_eq(@moondepsolve.format_version(version), "1.1.0")
}

///|
test "upgrade plan classifies add remove and downgrade in stable order" {
  let current : @moondepsolve.Resolution = {
    packages: [
      upgrade_pkg("core", "2.0.0", []),
      upgrade_pkg("legacy", "1.0.0", []),
    ],
  }
  let plan = upgrade_plan(
    [upgrade_dep("app", "1.0.0")],
    current,
    [
      upgrade_pkg("app", "1.0.0", [upgrade_dep("core", "^1.0.0")]),
      upgrade_pkg("core", "1.5.0", []),
    ],
    MinimalChange,
    100000,
  )
  assert_eq(plan.changes.length(), 3)
  assert_eq(plan.changes[0].package_name, "app")
  assert_true(plan.changes[0].kind is Add)
  assert_eq(plan.changes[1].package_name, "core")
  assert_true(plan.changes[1].kind is Downgrade)
  assert_eq(plan.changes[2].package_name, "legacy")
  assert_true(plan.changes[2].kind is Remove)
  assert_eq(
    @moondepsolve.format_upgrade_plan(plan),
    "strategy: minimal-change\nchanges: 3\nadd app 1.0.0\ndowngrade core 2.0.0 -> 1.5.0\nremove legacy 1.0.0\n",
  )
}

///|
test "upgrade planning reports invalid and exhausted search limits" {
  let root = [upgrade_dep("core", "^1.0.0")]
  let current : @moondepsolve.Resolution = { packages: [] }
  let repo : @moondepsolve.Registry = {
    packages: [upgrade_pkg("core", "1.0.0", [])],
  }
  match
    @moondepsolve.plan_upgrade(root, current, repo, {
      strategy: MinimalChange,
      max_states: 0,
    }) {
    Err(InvalidSearchLimit(0)) => ()
    _ => abort("expected invalid search limit")
  }
  match
    @moondepsolve.plan_upgrade(root, current, repo, {
      strategy: MinimalChange,
      max_states: 1,
    }) {
    Err(SearchLimitExceeded(1)) => ()
    _ => abort("expected exhausted search limit")
  }
  match
    @moondepsolve.plan_upgrade(
      [upgrade_dep("ghost", "1.0.0")],
      current,
      repo,
      @moondepsolve.default_upgrade_options(HighestCompatible),
    ) {
    Err(DependencyFailure(PackageNotFound("ghost"))) => ()
    _ => abort("expected wrapped dependency failure")
  }
}

///|
test "minimal-change plan keeps an already valid resolution unchanged" {
  let current : @moondepsolve.Resolution = {
    packages: [upgrade_pkg("core", "1.1.0", [])],
  }
  let plan = upgrade_plan(
    [upgrade_dep("core", "^1.0.0")],
    current,
    [
      upgrade_pkg("core", "1.2.0", []),
      upgrade_pkg("core", "1.1.0", []),
      upgrade_pkg("core", "1.0.0", []),
    ],
    MinimalChange,
    100000,
  )
  assert_eq(plan.changes.length(), 0)
  assert_eq(
    @moondepsolve.format_upgrade_plan(plan),
    "strategy: minimal-change\nchanges: 0\n",
  )
}

///|
test "minimal-change ties prefer higher versions independent of registry order" {
  let current : @moondepsolve.Resolution = { packages: [] }
  let root = [upgrade_dep("app", "^1.0.0")]
  let low = upgrade_pkg("app", "1.0.0", [])
  let high = upgrade_pkg("app", "1.2.0", [])
  let first = upgrade_plan(root, current, [low, high], MinimalChange, 100000)
  let second = upgrade_plan(root, current, [high, low], MinimalChange, 100000)
  assert_true(first.resolution == second.resolution)
  assert_eq(first.resolution.packages.length(), 1)
  assert_eq(
    @moondepsolve.format_version(first.resolution.packages[0].version),
    "1.2.0",
  )
}
