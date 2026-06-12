# MoonDepSolve

MoonDepSolve 是一个面向 MoonBit 包生态的语义版本与依赖求解基础库。它提供语义版本解析、版本范围匹配、传递依赖求解、冲突诊断、稳定 lock 输出，以及轻量文本包索引和 lock 读回能力，适合用于包管理、构建规划、依赖审计、自动化发布和教学示例。

MoonDepSolve is a compact MoonBit library for semantic version parsing, version range matching, deterministic dependency resolution, conflict diagnosis, stable lock output, and lightweight text registry / lock parsing.

Core author: `python123`

Public repositories:

- GitLink: <https://gitlink.org.cn/python123/moondepsolve>
- GitHub mirror: <https://github.com/python123-ops/moondepsolve>
- Mooncakes: planned after the v0.1 acceptance hardening pass

The GitLink repository is the primary competition repository. The GitHub repository is kept as a public mirror for review and community access.

## Features

- Parse semantic versions such as `1.2.3` and `1.2.3-alpha.1`.
- Compare stable and prerelease versions.
- Parse version requirements:
  - exact: `1.2.3`
  - caret: `^1.2.0`
  - tilde: `~1.2.0`
  - comparator set: `>=1.0.0 <2.0.0`
  - wildcard: `1.2.x`
- Resolve transitive dependencies from an in-memory package registry.
- Select the highest compatible version deterministically.
- Report readable conflicts with dependency paths.
- Format a stable dependency lock result for demos and tests.
- Parse a small text package index for demos, fixtures, and future file-backed registries.
- Parse MoonDepSolve lock output back into a `Resolution`.

## Install And Run

Install the MoonBit toolchain first:

```bash
moon version
```

Run checks, tests, and the demo:

```bash
moon check
moon test
moon run cmd/main
```

Regenerate public interface summaries after API changes:

```bash
moon info
moon fmt
```

## Public API

```moonbit
parse_version(input : String) -> Result[Version, DepError]
format_version(version : Version) -> String
compare_version(left : Version, right : Version) -> Int

parse_req(input : String) -> Result[VersionReq, DepError]
matches(version : Version, req : VersionReq) -> Bool

resolve(root : Array[Dependency], registry : Registry) -> Result[Resolution, DepError]
format_lock(resolution : Resolution) -> String
parse_lock(input : String) -> Result[Resolution, DepError]
parse_registry(input : String) -> Result[Registry, DepError]
format_error(err : DepError) -> String
```

The v0.1 API keeps the original in-memory `Registry` model stable. File-backed package indexes and richer lock formats are built around this core instead of replacing it.

## Minimal Example

```moonbit
let registry : @moondepsolve.Registry = {
  packages: [
    {
      name: "core",
      version: version("1.2.0"),
      dependencies: [],
    },
    {
      name: "http",
      version: version("0.3.4"),
      dependencies: [dependency("core", "^1.0.0")],
    },
  ],
}

match @moondepsolve.resolve([dependency("http", "~0.3.0")], registry) {
  Ok(result) => println(@moondepsolve.format_lock(result))
  Err(err) => println(@moondepsolve.format_error(err))
}
```

## Text Registry Format

`parse_registry` accepts a small line-based format. Blank lines and lines starting with `#` are ignored.

```text
# name version | dependency: requirement, dependency2: requirement
core 1.2.0
http 0.3.4 | core: ^1.0.0
appkit 1.0.0 | http: ~0.3.0
```

The format is intentionally simple so examples can be reviewed by hand. It is not a full package-index standard yet; it is the first step toward file-backed registries.

## Lock Format

`format_lock` emits a stable line-based lock:

```text
# MoonDepSolve lock
appkit 1.0.0
http 0.3.4
core 1.2.0
```

`parse_lock` reads this output back into a `Resolution`. Lock entries currently record selected package names and versions; dependency edges stay in the registry.

## Error Diagnosis

Conflicts include the selected version, the unsatisfied requirement, and the path that introduced the conflict:

```text
conflict for core: selected 1.5.0 does not satisfy ^2.0.0 required by root -> right@1.0.0 -> core
```

This makes the library useful for build tools and package-audit commands where users need to understand why a dependency set cannot be resolved.

## Roadmap

- v0.1: stabilize semantic version parsing, version requirements, in-memory resolution, text registry parsing, lock output, tests, README, and competition materials.
- v0.2: add structured lock metadata, lock read/write round trips, and more detailed parse diagnostics.
- v0.3: add dependency graph export and conflict explanation reports.
- v0.4: add upgrade suggestions, including highest-compatible and minimum-change upgrade plans.
- Release: publish to Mooncakes after the v0.1 API and acceptance checklist are stable.

## Competition Maintenance

This project is maintained as one project with two public repositories:

- `origin`: GitLink primary repository for competition review.
- `github`: GitHub mirror for public visibility and CI review.

Maintenance rules:

- Keep meaningful commits after 2026-04-29 visible in the public history.
- Use clear commit prefixes such as `feat:`, `fix:`, `test:`, `docs:`, and `chore:`.
- Push accepted changes to both GitLink and GitHub.
- Keep README, license, examples, CI, tests, generated `.mbti` files, and competition materials in sync.

## Test Coverage

The test suite covers:

- Version parsing and malformed input.
- Prerelease comparison.
- Exact, caret, tilde, comparator-set, and wildcard ranges.
- Transitive dependency resolution and highest-compatible selection.
- Missing or conflicting dependency diagnostics.
- Stable lock output and lock readback.
- Text registry parsing.

Run:

```bash
moon test
```

Before final acceptance, also run:

```bash
moon coverage analyze > uncovered.log
```

Use the result to guide test improvements. Do not commit temporary coverage logs unless they are intentionally turned into documentation.

## License And Compliance

MoonDepSolve is licensed under Apache-2.0. The implementation is written for this project in MoonBit and does not copy private, closed-source, commercial, or unclear-origin code. AI assistance may be used for implementation, tests, and documentation, but all submitted code and project direction remain reviewed by the maintainer.
