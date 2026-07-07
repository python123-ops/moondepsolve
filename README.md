# MoonDepSolve

[![CI](https://github.com/python123-ops/moondepsolve/actions/workflows/ci.yml/badge.svg)](https://github.com/python123-ops/moondepsolve/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![Release](https://img.shields.io/badge/release-v0.3.1-brightgreen.svg)](CHANGELOG.md)

MoonDepSolve is a MoonBit library and native CLI for semantic versions, deterministic dependency resolution, lock output, dependency graphs, conflict reports, and exact upgrade planning.

- GitLink: <https://gitlink.org.cn/python123/moondepsolve>
- GitHub: <https://github.com/python123-ops/moondepsolve>
- Module: `python123/moondepsolve`
- Maintainer identity: `python123 <python123@users.noreply.gitlink.org.cn>`

## What It Solves

MoonBit ecosystem tools need a small, reviewable dependency core: parse versions, match version ranges, choose compatible package versions, explain conflicts, and write stable lock output. MoonDepSolve keeps that boundary narrow so it can be reused by package managers, build tools, dependency audits, and release automation.

## v0.3 Highlights

- `HighestCompatible` chooses the highest compatible package set through the existing resolver.
- `MinimalChange` searches bounded candidate states, first minimizing changed packages and then preferring higher versions for deterministic ties.
- `UpgradePlan` reports stable add, remove, upgrade, and downgrade changes with the target `Resolution`.
- The native CLI reads registry and lock files, then emits lock output, a text dependency graph, or Graphviz DOT.
- Four example-driven CLI checks compare real file outputs byte for byte.

v0.3 is additive. Existing v0.1/v0.2 APIs for version parsing, requirement matching, resolution, lock output, dependency graphs, and conflict reports remain available.

## Quick Verification

Default backend:

```bash
python scripts/check_contributor_identity.py --ref HEAD
moon info
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon run cmd/main --deny-warn
```

Native CLI path, on a machine with a C compiler:

```bash
moon check --target native --deny-warn
moon test --target native --deny-warn
sh scripts/demo-v0.3.sh
```

`ConflictReport.package_name` replaces the earlier `package` field so OSC2026 quality gates can run with `--deny-warn` and no reserved-keyword suppression. Formatted reports still print `package: ...` for stable CLI output.

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

- GitHub and GitLink `master` are kept at the same commit.
- CI runs contributor identity checks, interface drift checks, formatting, diagnostics, default tests, native tests, and file CLI regressions.
- The OSC2026 materials are in [`docs/competition`](docs/competition), including the one-page proposal PDF, demo script, release notes, and acceptance checklist.
- License and dependency notices are in [LICENSE](LICENSE) and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

Mooncakes package: `python123/moondepsolve` version `0.3.1` is published. The release was validated with `moon package`, `moon publish --dry-run`, and `moon publish`.

## License

MoonDepSolve is released under the [Apache License 2.0](LICENSE).
