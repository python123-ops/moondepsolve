///|
test "resolve command accepts repeated roots and defaults to lock output" {
  let command = parse_cli([
    "resolve", "--registry", "registry.txt", "--root", "app:^1.0.0", "--root", "tools:2.0.x",
  ])
  guard command is Resolve(registry~, roots~, format~) else {
    abort("expected resolve command")
  }
  assert_eq(registry, "registry.txt")
  assert_eq(roots.length(), 2)
  assert_eq(roots[0].name, "app")
  assert_eq(roots[0].req.raw, "^1.0.0")
  assert_eq(roots[1].name, "tools")
  assert_eq(roots[1].req.raw, "2.0.x")
  assert_true(format is LockOutput)
}

///|
test "plan command parses minimal strategy and bounded state count" {
  let command = parse_cli([
    "plan", "--registry", "registry.txt", "--lock", "MoonDepSolve.lock", "--root",
    "app:^1.0.0", "--strategy", "minimal", "--max-states", "2500",
  ])
  guard command is Plan(registry~, lock_path~, roots~, strategy~, max_states~) else {
    abort("expected plan command")
  }
  assert_eq(registry, "registry.txt")
  assert_eq(lock_path, "MoonDepSolve.lock")
  assert_eq(roots.length(), 1)
  assert_true(strategy is MinimalChange)
  assert_eq(max_states, 2500)
}

///|
test "resolve command parses text and dot formats" {
  guard parse_cli([
      "resolve", "--registry", "r.txt", "--root", "app:1.0.0", "--format", "text",
    ])
    is Resolve(format=TextOutput, ..) else {
    abort("expected text format")
  }
  guard parse_cli([
      "resolve", "--registry", "r.txt", "--root", "app:1.0.0", "--format", "dot",
    ])
    is Resolve(format=DotOutput, ..) else {
    abort("expected dot format")
  }
}

///|
test "CLI rejects malformed roots and unsupported option values" {
  for
    argv in [
      ["resolve", "--registry", "r.txt", "--root", "missing-colon"],
      [
        "resolve", "--registry", "r.txt", "--root", "app:1.0.0", "--format", "json",
      ],
      [
        "plan", "--registry", "r.txt", "--lock", "l.txt", "--root", "app:1.0.0",
        "--strategy", "greedy",
      ],
      [
        "plan", "--registry", "r.txt", "--lock", "l.txt", "--root", "app:1.0.0",
        "--max-states", "0",
      ],
    ] {
    try parse_cli(argv) catch {
      _ => ()
    } noraise {
      _ => abort("expected invalid CLI input")
    }
  }
}
