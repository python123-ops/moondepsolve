# MoonDepSolve v0.3.0

MoonDepSolve v0.3.0 adds exact upgrade planning and a native file-driven CLI while preserving the v0.1/v0.2 public APIs.

## Highlights

- Exact `MinimalChange` planning minimizes changed packages globally, then prefers higher versions for deterministic ties.
- `HighestCompatible` produces an explicit upgrade plan from the existing resolver.
- Structured add/remove/upgrade/downgrade changes and bounded search errors.
- Native `resolve` and `plan` commands read registry/lock files and emit lock, text graph, or Graphviz DOT.
- 27 default-backend tests, 31 native tests, and four deterministic CLI output regressions.
- Full-history contributor identity gate for `python123` and synchronized GitLink/GitHub delivery.

## Compatibility

This release is additive. Existing parsing, matching, resolution, lock, dependency graph, and conflict report APIs remain available.

`ConflictReport.package` remains unchanged for v0.2 compatibility. Current MoonBit toolchains report that field as warning 35 because `package` is reserved for possible future use; project checks suppress only that warning.

## Verify

```bash
moon test --warn-list=-35
moon test --target native --warn-list=-35
sh scripts/demo-v0.3.sh
```

License: Apache-2.0.
