///|
pub(all) enum GraphNode {
  Root
  Package(String, Version)
  Unresolved(String)
} derive(Eq)

///|
pub(all) struct DependencyEdge {
  from : GraphNode
  to : GraphNode
  requirement : String
} derive(Eq)

///|
pub(all) struct DependencyGraph {
  nodes : Array[GraphNode]
  edges : Array[DependencyEdge]
} derive(Eq)

///|
pub fn build_dependency_graph(
  root : Array[Dependency],
  resolution : Resolution,
) -> DependencyGraph {
  let packages = resolution.packages.copy()
  packages.sort_by(compare_package)
  let unresolved : Array[String] = []
  let edges : Array[DependencyEdge] = []
  for dependency in root {
    let target = dependency_target(packages, dependency.name, unresolved)
    edges.push({ from: Root, to: target, requirement: dependency.req.raw })
  }
  for item in packages {
    for dependency in item.dependencies {
      let target = dependency_target(packages, dependency.name, unresolved)
      edges.push({
        from: Package(item.name, item.version),
        to: target,
        requirement: dependency.req.raw,
      })
    }
  }
  unresolved.sort_by(compare_text)
  edges.sort_by(compare_edge)
  let nodes : Array[GraphNode] = [Root]
  for item in packages {
    nodes.push(Package(item.name, item.version))
  }
  for name in unresolved {
    nodes.push(Unresolved(name))
  }
  { nodes, edges }
}

///|
pub fn format_graph_text(graph : DependencyGraph) -> String {
  let builder = StringBuilder()
  for edge in graph.edges {
    builder.write_string(graph_node_label(edge.from))
    builder.write_string(" -> ")
    builder.write_string(graph_node_label(edge.to))
    builder.write_string(" [")
    builder.write_string(edge.requirement)
    builder.write_string("]\n")
  }
  builder.to_string()
}

///|
pub fn format_graph_dot(graph : DependencyGraph) -> String {
  let builder = StringBuilder()
  builder.write_string("digraph dependencies {\n")
  for index, node in graph.nodes {
    builder.write_string("  n\{index} [label=\"")
    builder.write_string(dot_escape(graph_node_label(node)))
    builder.write_string("\"];\n")
  }
  for edge in graph.edges {
    let from_index = graph_node_index(graph.nodes, edge.from)
    let to_index = graph_node_index(graph.nodes, edge.to)
    builder.write_string("  n\{from_index} -> n\{to_index} [label=\"")
    builder.write_string(dot_escape(edge.requirement))
    builder.write_string("\"];\n")
  }
  builder.write_string("}\n")
  builder.to_string()
}

///|
fn dependency_target(
  packages : Array[PackageVersion],
  name : String,
  unresolved : Array[String],
) -> GraphNode {
  for item in packages {
    if item.name == name {
      return Package(item.name, item.version)
    }
  }
  if !contains_text(unresolved, name) {
    unresolved.push(name)
  }
  Unresolved(name)
}

///|
fn contains_text(values : Array[String], expected : String) -> Bool {
  for value in values {
    if value == expected {
      return true
    }
  }
  false
}

///|
fn compare_package(left : PackageVersion, right : PackageVersion) -> Int {
  let name_order = compare_text(left.name, right.name)
  if name_order != 0 {
    name_order
  } else {
    compare_version(left.version, right.version)
  }
}

///|
fn compare_edge(left : DependencyEdge, right : DependencyEdge) -> Int {
  let from_order = compare_text(
    graph_node_sort_key(left.from),
    graph_node_sort_key(right.from),
  )
  if from_order != 0 {
    return from_order
  }
  let to_order = compare_text(
    graph_node_sort_key(left.to),
    graph_node_sort_key(right.to),
  )
  if to_order != 0 {
    return to_order
  }
  compare_text(left.requirement, right.requirement)
}

///|
fn graph_node_sort_key(node : GraphNode) -> String {
  match node {
    Root => "0:root"
    Package(name, version) => "1:\{name}@\{format_version(version)}"
    Unresolved(name) => "2:\{name}"
  }
}

///|
fn graph_node_label(node : GraphNode) -> String {
  match node {
    Root => "root"
    Package(name, version) => "\{name}@\{format_version(version)}"
    Unresolved(name) => "unresolved:\{name}"
  }
}

///|
fn graph_node_index(nodes : Array[GraphNode], target : GraphNode) -> Int {
  for index, node in nodes {
    if node == target {
      return index
    }
  }
  abort("dependency graph edge references an unknown node")
}

///|
fn dot_escape(input : String) -> String {
  input
  .replace_all(old="\\", new="\\\\")
  .replace_all(old="\"", new="\\\"")
  .replace_all(old="\n", new="\\n")
  .replace_all(old="\r", new="\\r")
}
