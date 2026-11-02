///|
pub(all) struct Version {
  major : Int32
  minor : Int32
  patch : Int32
  prerelease : String?
} derive(Eq)

///|
pub extend Version with Eq::{equal, not_equal}

///|
pub(all) enum CompareOp {
  Eq
  Gt
  Gte
  Lt
  Lte
} derive(Eq)

///|
pub extend CompareOp with Eq::{equal, not_equal}

///|
pub(all) struct Comparator {
  op : CompareOp
  version : Version
} derive(Eq)

///|
pub extend Comparator with Eq::{equal, not_equal}

///|
pub(all) struct VersionReq {
  raw : String
  comparators : Array[Comparator]
} derive(Eq)

///|
pub extend VersionReq with Eq::{equal, not_equal}

///|
pub(all) struct Dependency {
  name : String
  req : VersionReq
} derive(Eq)

///|
pub extend Dependency with Eq::{equal, not_equal}

///|
pub(all) struct PackageVersion {
  name : String
  version : Version
  dependencies : Array[Dependency]
} derive(Eq)

///|
pub extend PackageVersion with Eq::{equal, not_equal}

///|
pub(all) struct Registry {
  packages : Array[PackageVersion]
} derive(Eq)

///|
pub extend Registry with Eq::{equal, not_equal}

///|
pub(all) struct Resolution {
  packages : Array[PackageVersion]
} derive(Eq)

///|
pub extend Resolution with Eq::{equal, not_equal}

///|
priv struct PendingDep {
  dependency : Dependency
  path : String
}

///|
pub(all) enum DepError {
  InvalidVersion(String, String)
  InvalidReq(String, String)
  PackageNotFound(String)
  NoMatchingVersion(String, String)
  VersionConflict(String, String, String, String)
} derive(Eq)

///|
pub extend DepError with Eq::{equal, not_equal}

///|
pub fn parse_version(input : String) -> Result[Version, DepError] {
  let text = input.trim().to_owned()
  let (core, prerelease) = match text.split_once("-") {
    Some((left, right)) => {
      let pre = right.to_owned()
      if pre.length() == 0 {
        return Err(InvalidVersion(text, "empty prerelease identifier"))
      }
      if !valid_prerelease(pre) {
        return Err(InvalidVersion(text, "invalid prerelease identifier"))
      }
      (left.to_owned(), Some(pre))
    }
    None => (text, None)
  }
  let parts = core.split(".").map(part => part.to_owned()).collect()
  if parts.length() != 3 {
    return Err(InvalidVersion(input, "expected major.minor.patch"))
  }
  match
    (parse_number(parts[0]), parse_number(parts[1]), parse_number(parts[2])) {
    (Some(major), Some(minor), Some(patch)) =>
      Ok({ major, minor, patch, prerelease, })
    _ => Err(InvalidVersion(input, "version segments must be numeric"))
  }
}

///|
pub fn format_version(version : Version) -> String {
  let base = "\{version.major}.\{version.minor}.\{version.patch}"
  match version.prerelease {
    Some(pre) => base + "-" + pre
    None => base
  }
}

///|
pub fn compare_version(left : Version, right : Version) -> Int32 {
  if left.major != right.major {
    return compare_int(left.major, right.major)
  }
  if left.minor != right.minor {
    return compare_int(left.minor, right.minor)
  }
  if left.patch != right.patch {
    return compare_int(left.patch, right.patch)
  }
  match (left.prerelease, right.prerelease) {
    (None, None) => 0
    (None, Some(_)) => 1
    (Some(_), None) => -1
    (Some(a), Some(b)) => compare_prerelease(a, b)
  }
}

///|
pub fn parse_req(input : String) -> Result[VersionReq, DepError] {
  let raw = input.trim().to_owned()
  if raw.length() == 0 {
    return Err(InvalidReq(input, "empty requirement"))
  }
  if raw.has_prefix("^") {
    let base = match parse_version(raw[1:].to_owned()) {
      Ok(version) => version
      Err(_) => return Err(InvalidReq(input, "invalid caret requirement"))
    }
    let upper = match caret_upper(base) {
      Some(upper) => upper
      None =>
        return Err(InvalidReq(input, "caret upper bound exceeds Int range"))
    }
    return Ok({
      raw,
      comparators: [{ op: Gte, version: base, }, { op: Lt, version: upper, }],
    })
  }
  if raw.has_prefix("~") {
    let base = match parse_version(raw[1:].to_owned()) {
      Ok(version) => version
      Err(_) => return Err(InvalidReq(input, "invalid tilde requirement"))
    }
    if base.minor == 2147483647 {
      return Err(InvalidReq(input, "tilde upper bound exceeds Int range"))
    }
    return Ok({
      raw,
      comparators: [
        { op: Gte, version: base, },
        {
          op: Lt,
          version: {
            major: base.major,
            minor: base.minor + 1,
            patch: 0,
            prerelease: None,
          },
        },
      ],
    })
  }
  if !raw.contains("-") &&
    (raw.has_suffix(".x") || raw.has_suffix(".X") || raw.has_suffix(".*")) {
    return parse_wildcard_req(raw)
  }
  if is_comparator_req(raw) {
    return parse_comparator_req(raw)
  }
  match parse_version(raw) {
    Ok(version) => Ok({ raw, comparators: [{ op: Eq, version, }], })
    Err(_) => Err(InvalidReq(input, "expected version requirement"))
  }
}

///|
pub fn matches(version : Version, req : VersionReq) -> Bool {
  for comparator in req.comparators {
    let order = compare_version(version, comparator.version)
    match comparator.op {
      Eq => if order != 0 { return false }
      Gt => if order <= 0 { return false }
      Gte => if order < 0 { return false }
      Lt => if order >= 0 { return false }
      Lte => if order > 0 { return false }
    }
  }
  true
}

///|
pub fn resolve(
  root : Array[Dependency],
  registry : Registry,
) -> Result[Resolution, DepError] {
  let pending : Array[PendingDep] = []
  for dependency in root {
    pending.push({ dependency, path: "root -> " + dependency.name, })
  }
  solve(registry, [], pending)
}

///|
pub fn format_lock(resolution : Resolution) -> String {
  let builder = StringBuilder()
  builder.write_string("# MoonDepSolve lock\n")
  for item in resolution.packages {
    builder.write_string(item.name)
    builder.write_string(" ")
    builder.write_string(format_version(item.version))
    builder.write_string("\n")
  }
  builder.to_string()
}

///|
pub fn parse_lock(input : String) -> Result[Resolution, DepError] {
  let packages : Array[PackageVersion] = []
  for line_view in input.split("\n") {
    let line = line_view.to_owned().trim().to_owned()
    if line.length() > 0 && !line.has_prefix("#") {
      match parse_lock_line(line) {
        Ok(item) => packages.push(item)
        Err(err) => return Err(err)
      }
    }
  }
  Ok({ packages, })
}

///|
pub fn parse_registry(input : String) -> Result[Registry, DepError] {
  let packages : Array[PackageVersion] = []
  for line_view in input.split("\n") {
    let line = line_view.to_owned().trim().to_owned()
    if line.length() > 0 && !line.has_prefix("#") {
      match parse_registry_line(line) {
        Ok(item) => packages.push(item)
        Err(err) => return Err(err)
      }
    }
  }
  Ok({ packages, })
}

///|
pub fn format_error(err : DepError) -> String {
  match err {
    InvalidVersion(input, reason) => "invalid version '\{input}': \{reason}"
    InvalidReq(input, reason) => "invalid requirement '\{input}': \{reason}"
    PackageNotFound(name) => "package not found: \{name}"
    NoMatchingVersion(name, req) => "no version of \{name} satisfies \{req}"
    VersionConflict(name, selected, req, path) =>
      "conflict for \{name}: selected \{selected} does not satisfy \{req} required by \{path}"
  }
}

///|
fn parse_lock_line(line : String) -> Result[PackageVersion, DepError] {
  let words = split_words(line)
  if words.length() != 2 {
    return Err(InvalidReq(line, "lock line must be: name version"))
  }
  match parse_version(words[1]) {
    Ok(version) => Ok({ name: words[0], version, dependencies: [], })
    Err(err) => Err(err)
  }
}

///|
fn parse_registry_line(line : String) -> Result[PackageVersion, DepError] {
  let (package_part, dependency_part) = match line.split_once("|") {
    Some((left, right)) => (left.to_owned(), right.to_owned())
    None => (line, "")
  }
  let words = split_words(package_part)
  if words.length() != 2 {
    return Err(InvalidReq(line, "registry line must be: name version"))
  }
  let version = match parse_version(words[1]) {
    Ok(version) => version
    Err(err) => return Err(err)
  }
  let dependencies : Array[Dependency] = []
  let dep_text = dependency_part.trim().to_owned()
  if dep_text.length() > 0 {
    for dep_view in dep_text.split(",") {
      let dep_input = dep_view.to_owned().trim().to_owned()
      if dep_input.length() > 0 {
        match parse_dependency_spec(dep_input) {
          Ok(dependency) => dependencies.push(dependency)
          Err(err) => return Err(err)
        }
      }
    }
  }
  Ok({ name: words[0], version, dependencies, })
}

///|
fn parse_dependency_spec(input : String) -> Result[Dependency, DepError] {
  match input.split_once(":") {
    Some((name_view, req_view)) => {
      let name = name_view.to_owned().trim().to_owned()
      let req_text = req_view.to_owned().trim().to_owned()
      if name.length() == 0 {
        return Err(InvalidReq(input, "dependency name is empty"))
      }
      match parse_req(req_text) {
        Ok(req) => Ok({ name, req, })
        Err(err) => Err(err)
      }
    }
    None => Err(InvalidReq(input, "dependency must be: name: requirement"))
  }
}

///|
fn split_words(input : String) -> Array[String] {
  let words : Array[String] = []
  for word_view in input.split(" ") {
    let word = word_view.to_owned().trim().to_owned()
    if word.length() > 0 {
      words.push(word)
    }
  }
  words
}

///|
fn solve(
  registry : Registry,
  selected : Array[PackageVersion],
  pending : Array[PendingDep],
) -> Result[Resolution, DepError] {
  if pending.length() == 0 {
    return Ok({ packages: selected, })
  }
  let current = pending[0]
  let rest = pending[1:].to_owned()
  match find_selected(selected, current.dependency.name) {
    Some(item) =>
      if matches(item.version, current.dependency.req) {
        solve(registry, selected, rest)
      } else {
        Err(
          VersionConflict(
            current.dependency.name,
            format_version(item.version),
            current.dependency.req.raw,
            current.path,
          ),
        )
      }
    None => {
      let candidates = matching_candidates(
        registry,
        current.dependency.name,
        current.dependency.req,
      )
      if candidates.length() == 0 {
        if package_exists(registry, current.dependency.name) {
          return Err(
            NoMatchingVersion(
              current.dependency.name,
              current.dependency.req.raw,
            ),
          )
        }
        return Err(PackageNotFound(current.dependency.name))
      }
      let mut last_error : DepError = NoMatchingVersion(
        current.dependency.name,
        current.dependency.req.raw,
      )
      for candidate in candidates {
        let next_selected = selected.copy()
        next_selected.push(candidate)
        let next_pending = rest.copy()
        let parent = current.path + "@" + format_version(candidate.version)
        for dependency in candidate.dependencies {
          next_pending.push({
            dependency,
            path: parent + " -> " + dependency.name,
          })
        }
        match solve(registry, next_selected, next_pending) {
          Ok(result) => return Ok(result)
          Err(err) => last_error = err
        }
      }
      Err(last_error)
    }
  }
}

///|
fn matching_candidates(
  registry : Registry,
  name : String,
  req : VersionReq,
) -> Array[PackageVersion] {
  let candidates : Array[PackageVersion] = []
  for item in registry.packages {
    if item.name == name && matches(item.version, req) {
      candidates.push(item)
    }
  }
  candidates.sort_by((left, right) => {
    compare_version(right.version, left.version)
  })
  candidates
}

///|
fn find_selected(
  selected : Array[PackageVersion],
  name : String,
) -> PackageVersion? {
  for item in selected {
    if item.name == name {
      return Some(item)
    }
  }
  None
}

///|
fn package_exists(registry : Registry, name : String) -> Bool {
  for item in registry.packages {
    if item.name == name {
      return true
    }
  }
  false
}

///|
fn parse_comparator_req(input : String) -> Result[VersionReq, DepError] {
  let comparators : Array[Comparator] = []
  for part_view in input.split(" ") {
    let part = part_view.to_owned().trim().to_owned()
    if part.length() > 0 {
      match parse_comparator(part) {
        Ok(comparator) => comparators.push(comparator)
        Err(err) => return Err(err)
      }
    }
  }
  Ok({ raw: input, comparators, })
}

///|
fn parse_comparator(input : String) -> Result[Comparator, DepError] {
  if input.has_prefix(">=") {
    return parse_comparator_version(input, 2, Gte)
  }
  if input.has_prefix("<=") {
    return parse_comparator_version(input, 2, Lte)
  }
  if input.has_prefix(">") {
    return parse_comparator_version(input, 1, Gt)
  }
  if input.has_prefix("<") {
    return parse_comparator_version(input, 1, Lt)
  }
  if input.has_prefix("=") {
    return parse_comparator_version(input, 1, Eq)
  }
  Err(InvalidReq(input, "unknown comparator"))
}

///|
fn parse_comparator_version(
  input : String,
  offset : Int32,
  op : CompareOp,
) -> Result[Comparator, DepError] {
  match parse_version(input[offset:].to_owned()) {
    Ok(version) => Ok({ op, version, })
    Err(_) => Err(InvalidReq(input, "invalid comparator version"))
  }
}

///|
fn parse_wildcard_req(input : String) -> Result[VersionReq, DepError] {
  let parts = input.split(".").map(part => part.to_owned()).collect()
  if parts.length() != 3 {
    return Err(InvalidReq(input, "wildcard must be major.minor.x"))
  }
  match (parse_number(parts[0]), parse_number(parts[1])) {
    (Some(major), Some(minor)) => {
      let patch = parts[2].to_lower()
      if patch == "x" || patch == "*" {
        if minor == 2147483647 {
          return Err(
            InvalidReq(input, "wildcard upper bound exceeds Int range"),
          )
        }
        Ok({
          raw: input,
          comparators: [
            { op: Gte, version: { major, minor, patch: 0, prerelease: None, }, },
            {
              op: Lt,
              version: { major, minor: minor + 1, patch: 0, prerelease: None, },
            },
          ],
        })
      } else {
        Err(InvalidReq(input, "wildcard must use x or * in patch position"))
      }
    }
    _ => Err(InvalidReq(input, "wildcard major and minor must be numeric"))
  }
}

///|
fn caret_upper(version : Version) -> Version? {
  if version.major > 0 {
    if version.major == 2147483647 {
      return None
    }
    Some({ major: version.major + 1, minor: 0, patch: 0, prerelease: None, })
  } else if version.minor > 0 {
    if version.minor == 2147483647 {
      return None
    }
    Some({ major: 0, minor: version.minor + 1, patch: 0, prerelease: None, })
  } else {
    if version.patch == 2147483647 {
      return None
    }
    Some({ major: 0, minor: 0, patch: version.patch + 1, prerelease: None, })
  }
}

///|
fn is_comparator_req(input : String) -> Bool {
  input.has_prefix(">") ||
  input.has_prefix("<") ||
  input.has_prefix("=") ||
  input.contains(" ")
}

///|
fn parse_number(input : String) -> Int32? {
  if input.length() == 0 {
    return None
  }
  if input.length() > 1 && input.has_prefix("0") {
    return None
  }
  let mut value = 0
  for c in input.iter() {
    if !is_digit(c) {
      return None
    }
    let digit = c.to_int() - '0'.to_int()
    if value > (2147483647 - digit) / 10 {
      return None
    }
    value = value * 10 + digit
  }
  Some(value)
}

///|
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
fn compare_prerelease(left : String, right : String) -> Int32 {
  let left_parts = left.split(".").map(part => part.to_owned()).collect()
  let right_parts = right.split(".").map(part => part.to_owned()).collect()
  let length = if left_parts.length() < right_parts.length() {
    left_parts.length()
  } else {
    right_parts.length()
  }
  for i in 0..<length {
    let order = compare_identifier(left_parts[i], right_parts[i])
    if order != 0 {
      return order
    }
  }
  left_parts.length() - right_parts.length()
}

///|
fn compare_identifier(left : String, right : String) -> Int32 {
  match (is_numeric_identifier(left), is_numeric_identifier(right)) {
    (true, true) => {
      // Valid numeric identifiers have no leading zeroes, so digit count
      // determines order before lexical comparison, without an Int conversion.
      let order = compare_int(left.length(), right.length())
      if order != 0 {
        order
      } else {
        compare_text(left, right)
      }
    }
    (true, false) => -1
    (false, true) => 1
    (false, false) => compare_text(left, right)
  }
}

///|
fn compare_int(left : Int32, right : Int32) -> Int32 {
  if left < right {
    -1
  } else if left > right {
    1
  } else {
    0
  }
}

///|
fn is_numeric_identifier(input : String) -> Bool {
  input.length() > 0 && input.iter().all(is_digit)
}

///|
fn valid_prerelease(input : String) -> Bool {
  for part in input.split(".") {
    let identifier = part.to_owned()
    if identifier.length() == 0 {
      return false
    }
    for c in identifier.iter() {
      if !is_digit(c) &&
        !(c >= 'A' && c <= 'Z') &&
        !(c >= 'a' && c <= 'z') &&
        c != '-' {
        return false
      }
    }
    if is_numeric_identifier(identifier) &&
      identifier.length() > 1 &&
      identifier.has_prefix("0") {
      return false
    }
  }
  true
}

///|
fn compare_text(left : String, right : String) -> Int32 {
  let left_chars = left.iter().to_array()
  let right_chars = right.iter().to_array()
  let length = if left_chars.length() < right_chars.length() {
    left_chars.length()
  } else {
    right_chars.length()
  }
  for i in 0..<length {
    let order = left_chars[i].to_int() - right_chars[i].to_int()
    if order != 0 {
      return order
    }
  }
  left_chars.length() - right_chars.length()
}
