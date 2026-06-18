///|
fn report_version(input : String) -> @moondepsolve.Version {
  match @moondepsolve.parse_version(input) {
    Ok(version) => version
    Err(err) => abort(@moondepsolve.format_error(err))
  }
}

///|
fn report_registry(versions : Array[String]) -> @moondepsolve.Registry {
  {
    packages: versions.map(version => {
      name: "core",
      version: report_version(version),
      dependencies: [],
    }),
  }
}

///|
test "build reports for missing and unmatched packages" {
  let missing = @moondepsolve.build_conflict_report(PackageNotFound("ghost"), {
    packages: [],
  })
  assert_true(
    missing is Some(report) &&
    report.kind is MissingPackage &&
    report.package == "ghost" &&
    report.available_versions.length() == 0,
  )
  guard missing is Some(missing_report) else {
    abort("expected missing-package report")
  }
  assert_eq(
    @moondepsolve.format_conflict_report(missing_report),
    "conflict: missing package\npackage: ghost\navailable: \n",
  )
  let unmatched = @moondepsolve.build_conflict_report(
    NoMatchingVersion("core", "^3.0.0"),
    report_registry(["1.0.0", "2.1.0", "2.0.0"]),
  )
  guard unmatched is Some(report) else { abort("expected conflict report") }
  assert_true(report.kind is NoMatchingVersion)
  assert_true(report.requirement is Some("^3.0.0"))
  assert_eq(
    report.available_versions.map(@moondepsolve.format_version).join(","),
    "2.1.0,2.0.0,1.0.0",
  )
  assert_eq(
    @moondepsolve.format_conflict_report(report),
    "conflict: no matching version\npackage: core\nrequirement: ^3.0.0\navailable: 2.1.0, 2.0.0, 1.0.0\n",
  )
}

///|
test "build selected-version report with path and stable formatting" {
  let report = @moondepsolve.build_conflict_report(
    VersionConflict("core", "1.5.0", "^2.0.0", "root -> right@1.0.0 -> core"),
    report_registry(["1.5.0", "2.2.0", "2.0.0"]),
  )
  guard report is Some(value) else { abort("expected conflict report") }
  assert_true(value.kind is SelectedVersionConflict)
  assert_true(value.selected_version is Some("1.5.0"))
  assert_true(value.dependency_path is Some("root -> right@1.0.0 -> core"))
  let expected =
    #|conflict: selected version conflict
    #|package: core
    #|requirement: ^2.0.0
    #|selected: 1.5.0
    #|path: root -> right@1.0.0 -> core
    #|available: 2.2.0, 2.0.0, 1.5.0
    #|
  assert_eq(@moondepsolve.format_conflict_report(value), expected)
}

///|
test "parse errors do not produce conflict reports" {
  let repo : @moondepsolve.Registry = { packages: [] }
  assert_true(
    @moondepsolve.build_conflict_report(InvalidVersion("1", "bad"), repo)
    is None,
  )
  assert_true(
    @moondepsolve.build_conflict_report(InvalidReq("", "empty"), repo) is None,
  )
}
