///|
pub(all) enum ConflictKind {
  MissingPackage
  NoMatchingVersion
  SelectedVersionConflict
} derive(Eq)

///|
#warnings("-35")
pub(all) struct ConflictReport {
  kind : ConflictKind
  package : String
  requirement : String?
  selected_version : String?
  dependency_path : String?
  available_versions : Array[Version]
} derive(Eq)

///|
#warnings("-35")
pub fn build_conflict_report(
  error : DepError,
  registry : Registry,
) -> ConflictReport? {
  match error {
    PackageNotFound(name) =>
      Some({
        kind: MissingPackage,
        package: name,
        requirement: None,
        selected_version: None,
        dependency_path: None,
        available_versions: [],
      })
    NoMatchingVersion(name, requirement) =>
      Some({
        kind: NoMatchingVersion,
        package: name,
        requirement: Some(requirement),
        selected_version: None,
        dependency_path: None,
        available_versions: package_versions(registry, name),
      })
    VersionConflict(name, selected, requirement, path) =>
      Some({
        kind: SelectedVersionConflict,
        package: name,
        requirement: Some(requirement),
        selected_version: Some(selected),
        dependency_path: Some(path),
        available_versions: package_versions(registry, name),
      })
    InvalidVersion(_, _) | InvalidReq(_, _) => None
  }
}

///|
pub fn format_conflict_report(report : ConflictReport) -> String {
  let builder = StringBuilder()
  builder.write_string("conflict: ")
  builder.write_string(conflict_kind_text(report.kind))
  builder.write_string("\npackage: ")
  builder.write_string(report.package)
  builder.write_string("\n")
  match report.requirement {
    Some(value) => builder.write_string("requirement: \{value}\n")
    None => ()
  }
  match report.selected_version {
    Some(value) => builder.write_string("selected: \{value}\n")
    None => ()
  }
  match report.dependency_path {
    Some(value) => builder.write_string("path: \{value}\n")
    None => ()
  }
  builder.write_string("available: ")
  builder.write_string(report.available_versions.map(format_version).join(", "))
  builder.write_string("\n")
  builder.to_string()
}

///|
fn package_versions(registry : Registry, name : String) -> Array[Version] {
  let versions : Array[Version] = []
  for item in registry.packages {
    if item.name == name {
      versions.push(item.version)
    }
  }
  versions.sort_by((left, right) => compare_version(right, left))
  versions
}

///|
fn conflict_kind_text(kind : ConflictKind) -> String {
  match kind {
    MissingPackage => "missing package"
    NoMatchingVersion => "no matching version"
    SelectedVersionConflict => "selected version conflict"
  }
}
