///|
fn main {
  let registry : @moondepsolve.Registry = {
    packages: [
      { name: "core", version: version("1.0.0"), dependencies: [] },
      { name: "core", version: version("1.2.0"), dependencies: [] },
      {
        name: "http",
        version: version("0.3.4"),
        dependencies: [dependency("core", "^1.0.0")],
      },
      {
        name: "appkit",
        version: version("1.0.0"),
        dependencies: [dependency("http", "~0.3.0")],
      },
    ],
  }
  println("MoonDepSolve demo")
  println("root=appkit@1.0.0")
  let root = [dependency("appkit", "1.0.0")]
  match @moondepsolve.resolve(root, registry) {
    Ok(result) => {
      println("resolved=\{result.packages.length()}")
      println(@moondepsolve.format_lock(result))
      println("Dependency graph")
      println(
        @moondepsolve.format_graph_text(
          @moondepsolve.build_dependency_graph(root, result),
        ),
      )
    }
    Err(err) => println(@moondepsolve.format_error(err))
  }
  let conflict : @moondepsolve.DepError = VersionConflict(
    "core", "1.2.0", "^2.0.0", "root -> appkit@1.0.0 -> core",
  )
  match @moondepsolve.build_conflict_report(conflict, registry) {
    Some(report) => {
      println("Conflict report")
      println(@moondepsolve.format_conflict_report(report))
    }
    None => ()
  }
}

///|
fn version(input : String) -> @moondepsolve.Version {
  match @moondepsolve.parse_version(input) {
    Ok(version) => version
    Err(err) => abort(@moondepsolve.format_error(err))
  }
}

///|
fn dependency(name : String, req : String) -> @moondepsolve.Dependency {
  match @moondepsolve.parse_req(req) {
    Ok(parsed) => { name, req: parsed }
    Err(err) => abort(@moondepsolve.format_error(err))
  }
}
