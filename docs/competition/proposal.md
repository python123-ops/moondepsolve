# MoonDepSolve v0.3 Project Proposal

**Author:** python123

**Direction:** MoonBit engineering infrastructure and package ecosystem

**License:** Apache-2.0

**Repositories:** [GitLink](https://gitlink.org.cn/python123/moondepsolve) · [GitHub](https://github.com/python123-ops/moondepsolve)

## Project Positioning

MoonDepSolve is a semantic-version and dependency-resolution foundation for MoonBit package tooling. It covers version requirement parsing, transitive dependency selection, stable lock output, dependency graphs, conflict reports, and upgrade-plan generation.

The project is designed for package managers, build tools, dependency audits, and release automation. Its scope is deliberately narrow: solve and explain dependency state, then provide stable text formats that other tools can consume.

## v0.3 Delivery

- Keeps the v0.1/v0.2 parsing, matching, resolution, lock, graph, and conflict-report APIs compatible.
- Adds `HighestCompatible` and exact `MinimalChange` planning.
- Adds structured `UpgradePlan` output for add, remove, upgrade, and downgrade changes.
- Adds a native file CLI that reads registry/lock files and emits lock, text graph, or Graphviz DOT output.
- Provides expected-output regression checks over real registry and lock files.

## Technical Route

The implementation follows a simple pipeline: version parsing, requirement matching, stable candidate ordering, recursive resolution or bounded exact search, then lock, graph, or diagnostic output.

Core APIs are written in MoonBit and reviewed through generated `.mbti` files. The native CLI uses `moonbitlang/async/fs` for file workflows. This gives the MoonBit ecosystem a reusable dependency component and a working example of library API plus native tool packaging.

## Quality Evidence

The closeout baseline includes default-backend tests, native tests in CI, file CLI regressions, contributor-identity gates, interface drift checks, formatting checks, diagnostics, license files, third-party notices, issue templates, release notes, and a one-page proposal artifact.

## Competition Status

Development started after 2026-04-29 and reached v0.3 with exact upgrade planning and file-based CLI support. The final repository closeout keeps GitHub and GitLink synchronized, keeps the `v0.3.0` tag available on both remotes, and records release notes on both platforms. Mooncakes publication is deferred outside this repository closeout.
