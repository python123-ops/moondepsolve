///|
fn graph_version(input : String) -> @moondepsolve.Version {
  match @moondepsolve.parse_version(input) {
    Ok(version) => version
    Err(err) => abort(@moondepsolve.format_error(err))
  }
}

///|
fn graph_req(input : String) -> @moondepsolve.VersionReq {
  match @moondepsolve.parse_req(input) {
    Ok(req) => req
    Err(err) => abort(@moondepsolve.format_error(err))
  }
}

///|
fn graph_dep(name : String, req : String) -> @moondepsolve.Dependency {
  { name, req: graph_req(req) }
}

///|
test "build dependency graph with stable root transitive and unresolved edges" {
  let resolution : @moondepsolve.Resolution = {
    packages: [
      {
        name: "web",
        version: graph_version("2.0.0"),
        dependencies: [
          graph_dep("core", "^1.0.0"),
          graph_dep("missing", "~0.1.0"),
          graph_dep("missing", "^0.1.0"),
        ],
      },
      { name: "core", version: graph_version("1.4.0"), dependencies: [] },
    ],
  }
  let graph = @moondepsolve.build_dependency_graph(
    [graph_dep("web", "2.0.0"), graph_dep("core", "^1.0.0")],
    resolution,
  )
  assert_eq(graph.nodes.length(), 4)
  assert_true(graph.nodes[0] is Root)
  assert_true(
    graph.nodes[1] is Package("core", version) &&
    @moondepsolve.format_version(version) == "1.4.0",
  )
  assert_true(graph.nodes[3] is Unresolved("missing"))
  let expected =
    #|root -> core@1.4.0 [^1.0.0]
    #|root -> web@2.0.0 [2.0.0]
    #|web@2.0.0 -> core@1.4.0 [^1.0.0]
    #|web@2.0.0 -> unresolved:missing [^0.1.0]
    #|web@2.0.0 -> unresolved:missing [~0.1.0]
    #|
  assert_eq(@moondepsolve.format_graph_text(graph), expected)
}

///|
test "dependency graph output ignores input order and escapes dot labels" {
  let special = "quote\\\"line\nnext"
  let resolution : @moondepsolve.Resolution = {
    packages: [
      { name: special, version: graph_version("1.0.0"), dependencies: [] },
    ],
  }
  let first = @moondepsolve.build_dependency_graph(
    [graph_dep("z", "^9.0.0"), graph_dep(special, "1.0.0")],
    resolution,
  )
  let second = @moondepsolve.build_dependency_graph(
    [graph_dep(special, "1.0.0"), graph_dep("z", "^9.0.0")],
    resolution,
  )
  assert_eq(
    @moondepsolve.format_graph_text(first),
    @moondepsolve.format_graph_text(second),
  )
  let dot = @moondepsolve.format_graph_dot(first)
  assert_true(dot.contains("quote\\\\\\\"line\\nnext@1.0.0"))
  assert_true(dot.contains("unresolved:z"))
}

///|
test "dependency graph keeps multiple selected versions in stable order" {
  let resolution : @moondepsolve.Resolution = {
    packages: [
      { name: "core", version: graph_version("2.0.0"), dependencies: [] },
      { name: "core", version: graph_version("1.0.0"), dependencies: [] },
    ],
  }
  let graph = @moondepsolve.build_dependency_graph([], resolution)
  assert_eq(graph.nodes.length(), 3)
  assert_true(
    graph.nodes[1] is Package("core", version) &&
    @moondepsolve.format_version(version) == "1.0.0",
  )
  assert_true(
    graph.nodes[2] is Package("core", version) &&
    @moondepsolve.format_version(version) == "2.0.0",
  )
}
