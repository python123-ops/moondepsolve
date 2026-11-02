///|
test "reject leading zeroes and overflowing version components" {
  for
    input in [
      "01.2.3", "1.02.3", "1.2.03", "2147483648.0.0", "1.4294967296.0", "1.2.999999999999999999999999999999",
    ] {
    assert_true(@moondepsolve.parse_version(input) is Err(_))
  }
  assert_eq(version_text(version_ok("2147483647.0.0")), "2147483647.0.0")
}

///|
test "validate prerelease identifiers" {
  for
    input in [
      "1.2.3-alpha..1", "1.2.3-.alpha", "1.2.3-alpha.", "1.2.3-01", "1.2.3-alpha.00",
      "1.2.3-alpha_1", "1.2.3-测试", "1.2.3-alpha+build",
    ] {
    assert_true(@moondepsolve.parse_version(input) is Err(_))
  }
  for input in ["1.2.3-0", "1.2.3-alpha-1", "1.2.3-01a", "1.2.3--"] {
    assert_eq(version_text(version_ok(input)), input)
  }
}

///|
test "compare numeric prerelease identifiers without integer overflow" {
  let ordered = [
    "1.0.0-9", "1.0.0-10", "1.0.0-2147483647", "1.0.0-2147483648", "1.0.0-999999999999999999999999999999",
    "1.0.0-alpha", "1.0.0",
  ]
  for i in 0..<ordered.length() {
    for j in 0..<ordered.length() {
      let order = @moondepsolve.compare_version(
        version_ok(ordered[i]),
        version_ok(ordered[j]),
      )
      assert_eq(order < 0, i < j)
      assert_eq(order == 0, i == j)
      assert_eq(order > 0, i > j)
    }
  }
}

///|
test "prerelease names containing x remain exact and comparator requirements" {
  for input in ["1.2.3-exp.1", "=1.2.3-exp.1", ">=1.2.3-exp.1 <1.2.3"] {
    assert_true(@moondepsolve.matches(version_ok("1.2.3-exp.1"), req_ok(input)))
  }
  for input in ["1.2.3-alpha.x", "1.2.3-alpha.X"] {
    assert_true(@moondepsolve.matches(version_ok(input), req_ok(input)))
    assert_true(@moondepsolve.matches(version_ok(input), req_ok("=" + input)))
  }
}

///|
test "reject range upper bounds that would overflow" {
  for
    input in [
      "^2147483647.0.0", "^0.2147483647.0", "^0.0.2147483647", "~1.2147483647.0",
      "1.2147483647.x", "01.2.x",
    ] {
    assert_true(@moondepsolve.parse_req(input) is Err(_))
  }
  assert_true(
    @moondepsolve.matches(
      version_ok("2147483647.0.0"),
      req_ok("=2147483647.0.0"),
    ),
  )
}

///|
test "version comparison handles the full public Int field range" {
  let low : @moondepsolve.Version = {
    major: -2147483648,
    minor: 0,
    patch: 0,
    prerelease: None,
  }
  let high = version_ok("2147483647.0.0")
  assert_true(@moondepsolve.compare_version(low, high) < 0)
  assert_true(@moondepsolve.compare_version(high, low) > 0)
}

///|
test "explicit equality methods remain available to consumers" {
  let version = version_ok("1.2.3")
  assert_true(version.equal(version_ok("1.2.3")))
  assert_true(version.not_equal(version_ok("1.2.4")))
}

///|
test "resolver selects the highest large numeric prerelease" {
  let repo = registry([
    pkg("core", "1.0.0-2147483647", []),
    pkg("core", "1.0.0-2147483648", []),
    pkg("core", "1.0.0-999999999999999999999999999999", []),
  ])
  match @moondepsolve.resolve([dep("core", ">=1.0.0-0 <1.0.0")], repo) {
    Ok(result) =>
      assert_eq(
        version_text(result.packages[0].version),
        "1.0.0-999999999999999999999999999999",
      )
    Err(error) => abort(@moondepsolve.format_error(error))
  }
}
