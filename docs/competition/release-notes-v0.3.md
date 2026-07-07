# MoonDepSolve v0.3.1

MoonDepSolve v0.3.1 keeps the exact upgrade planning and native file-driven CLI from v0.3.0, and removes the remaining reserved-keyword warning so OSC2026 checks can run with strict `--deny-warn` gates.

## Highlights

- Exact `MinimalChange` planning minimizes changed packages globally, then prefers higher versions for deterministic ties.
- `HighestCompatible` produces an explicit upgrade plan from the existing resolver.
- Structured add/remove/upgrade/downgrade changes and bounded search errors.
- Native `resolve` and `plan` commands read registry/lock files and emit lock, text graph, or Graphviz DOT.
- 27 default-backend tests, 31 native tests, and four deterministic CLI output regressions.
- Full-history contributor identity gate for `python123` and synchronized GitLink/GitHub delivery.
- `ConflictReport.package_name` replaces the reserved `package` field while formatted reports still print `package: ...`.

## Compatibility

Existing parsing, matching, resolution, lock, dependency graph, and conflict report entry functions remain available. The conflict-report field rename is the only public surface change in this strict-CI fix.

## Verify

```bash
moon check --deny-warn
moon test --deny-warn
moon test --target native --deny-warn
sh scripts/demo-v0.3.sh
```

License: Apache-2.0.
