# MoonDepSolve

[![CI](https://github.com/python123-ops/moondepsolve/actions/workflows/ci.yml/badge.svg)](https://github.com/python123-ops/moondepsolve/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/badge/release-v0.3.2-brightgreen.svg)](CHANGELOG.md)

MoonDepSolve is a MoonBit library and native CLI for semantic versions, deterministic dependency resolution, lock output, dependency graphs, conflict reports, and exact upgrade planning.

- GitLink: <https://gitlink.org.cn/python123/moondepsolve>
- GitHub: <https://github.com/python123-ops/moondepsolve>
- Product site source: [`site/index.html`](https://github.com/python123-ops/moondepsolve/blob/master/site/index.html)
- Module: `python123/moondepsolve`
- Maintainer identity: `python123 <python123@users.noreply.gitlink.org.cn>`

## What It Solves

MoonBit ecosystem tools need a small, reviewable dependency core: parse versions, match version ranges, choose compatible package versions, explain conflicts, and write stable lock output. MoonDepSolve keeps that boundary narrow so it can be reused by package managers, build tools, dependency audits, and release automation.

## v0.3.2 Maintenance

- Updated for MoonBit `0.10.19+97801ee1b` (2026-10-30) and `moonbitlang/async@0.22.7`.
- Made the existing equality methods explicit to keep strict compiler checks passing.
- Fixed numeric overflow, leading zeroes, malformed prerelease identifiers, large numeric prerelease ordering, and exact requirements containing `x` in prerelease names.
- Added range-bound overflow checks and regression tests. All four stable backends pass: 35 tests each on Wasm, Wasm GC, and JavaScript, and 39 on native.
- Added a cross-platform CLI check for four byte-for-byte outputs and three failure cases; CI runs on Linux and Windows with a pinned toolchain.
- Reduced the Mooncakes archive to source, tests, examples, metadata, and license notices through `.moonignore`.

## v0.3 Features

- `HighestCompatible` chooses the highest compatible package set through the existing resolver.
- `MinimalChange` searches bounded candidate states, first minimizing changed packages and then preferring higher versions for deterministic ties.
- `UpgradePlan` reports stable add, remove, upgrade, and downgrade changes with the target `Resolution`.
- The native CLI reads registry and lock files, then emits lock output, a text dependency graph, or Graphviz DOT.
- Four example-driven CLI checks compare real file outputs byte for byte.

v0.3 is additive. Existing v0.1/v0.2 APIs for version parsing, requirement matching, resolution, lock output, dependency graphs, and conflict reports remain available.

## Quick Verification

Use MoonBit `0.10.19+97801ee1b` or a compatible newer toolchain. The pinned version is tested in CI; older toolchains may not understand the updated async dependency's package configuration.

Default backend:

```bash
python scripts/check_contributor_identity.py --ref HEAD
moon info
moon fmt --check
moon check --deny-warn
moon test --target all --deny-warn
moon run cmd/main --deny-warn
```

Native CLI path, on a machine with a C compiler:

```bash
moon check --target native --deny-warn
moon test --target native --deny-warn
python scripts/check_cli.py
```

`ConflictReport.package_name` replaces the earlier `package` field so OSC2026 quality gates can run with `--deny-warn` and no reserved-keyword suppression. Formatted reports still print `package: ...` for stable CLI output.

## Version and Requirement Syntax

Versions use `major.minor.patch` with an optional `-prerelease`. Core components range from `0` to `2147483647` and reject leading zeroes. Prerelease identifiers follow the [SemVer identifier and precedence rules](https://semver.org/spec/v2.0.0.html#spec-item-9); numeric prerelease identifiers can exceed the core component limit. Build metadata (`+build`) is not supported by the current `Version` type.

Requirements support exact versions, `^major.minor.patch`, `~major.minor.patch`, space-separated comparators, and patch wildcards such as `1.2.x`, `1.2.X`, or `1.2.*`. A generated upper bound must fit the core component range. Matching applies the comparators directly, including to prereleases; it does not add npm-style prerelease exclusion. OR expressions, hyphen ranges, and bare `*` are not supported.

## File CLI

Registry rows use `name version | dependency:requirement`:

```text
app 1.1.0 | core:^1.1.0, logging:1.0.x
core 1.2.0
logging 1.0.0
```

Resolve and print a lock:

```bash
moon run cmd/cli --target native -- \
  resolve \
  --registry examples/registry.txt \
  --root 'app:^1.0.0' \
  --format lock
```

Plan from an existing lock:

```bash
moon run cmd/cli --target native -- \
  plan \
  --registry examples/registry.txt \
  --lock examples/current.lock \
  --root 'app:^1.0.0' \
  --strategy minimal \
  --max-states 100000
```

Expected minimal-change output starts with:

```text
strategy: minimal-change
changes: 0
target lock:
# MoonDepSolve lock
app 1.0.0
core 1.0.0
logging 1.0.0
```

Use `--strategy highest` to generate a highest-compatible upgrade plan. `--max-states` must be positive; if the bound is exhausted, MoonDepSolve returns `SearchLimitExceeded` instead of pretending it found an optimum.

## Library API

| Capability | Public API |
| --- | --- |
| Versions | `parse_version`, `format_version`, `compare_version` |
| Requirements | `parse_req`, `matches` |
| Resolution | `resolve` |
| Registry and lock | `parse_registry`, `format_lock`, `parse_lock` |
| Base errors | `format_error` |
| Dependency graph | `build_dependency_graph`, `format_graph_text`, `format_graph_dot` |
| Conflict report | `build_conflict_report`, `format_conflict_report` |
| Upgrade planning | `default_upgrade_options`, `plan_upgrade`, `format_upgrade_plan`, `format_upgrade_error` |

Exact signatures are tracked in [`pkg.generated.mbti`](pkg.generated.mbti).

## Project Evidence

- This maintenance release is maintained on GitHub. GitLink retains the earlier competition history.
- CI runs contributor identity checks, interface drift checks, formatting, diagnostics, all stable backend tests, native file CLI regressions, and package validation on Linux and Windows.
- The OSC2026 materials are in [`docs/competition`](docs/competition), including the one-page proposal PDF, demo script, release notes, and acceptance checklist.
- License and dependency notices are in [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Mooncakes package: [`python123/moondepsolve@0.3.1`](https://mooncakes.io/docs/python123/moondepsolve@0.3.1) is published. Version `0.3.2` passes local package validation; registry publication requires authentication as the existing module owner `python123`. The current `python123-ops` login is rejected by the registry for that namespace.

## License

MoonDepSolve is released under the [Apache License 2.0](LICENSE).
