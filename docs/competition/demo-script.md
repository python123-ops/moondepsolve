# MoonDepSolve v0.3 Demo Script

## 0:00-0:30 Project Positioning

Open the README and repository page. MoonDepSolve is a dependency-resolution foundation for the MoonBit package ecosystem: semantic versions, transitive resolution, dependency graphs, conflict reports, and exact upgrade planning.

Mention the two public repositories:

- GitLink: <https://gitlink.org.cn/python123/moondepsolve>
- GitHub: <https://github.com/python123-ops/moondepsolve>

## 0:30-1:10 File-Based Resolution

Open `examples/registry.txt`, then run:

```bash
moon run cmd/cli --target native -- \
  resolve --registry examples/registry.txt \
  --root 'app:^1.0.0' --format lock
```

Show the selected packages and explain that the same command can emit a text graph or Graphviz DOT through `--format text` and `--format dot`.

## 1:10-2:00 Exact Upgrade Planning

Open `examples/current.lock`, then run:

```bash
moon run cmd/cli --target native -- \
  plan --registry examples/registry.txt \
  --lock examples/current.lock \
  --root 'app:^1.0.0' --strategy minimal
```

Explain that `MinimalChange` first minimizes the number of changed packages, then uses higher versions as a deterministic tie-breaker. Run `--strategy highest` to show the highest-compatible plan.

## 2:00-2:35 Explainability and Boundaries

Show `ConflictReport`, sorted candidate versions, and dependency paths. Point out that lock output is intentionally small while dependency edges remain in the registry and graph views.

## 2:35-3:00 Evidence

Show CI and terminal evidence:

```bash
python scripts/check_contributor_identity.py --ref HEAD
moon test --warn-list=-35
moon run cmd/main --warn-list=-35
moon package
```

Close with the Apache-2.0 license, third-party notices, changelog, one-page proposal, v0.3.0 tag, release records, and matching GitHub/GitLink `master` commits.
