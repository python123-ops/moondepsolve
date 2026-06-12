# MoonDepSolve Design

## Goal

MoonDepSolve provides a compact MoonBit dependency resolution core for package
ecosystem tooling. It handles semantic versions, version ranges, transitive
dependencies, deterministic selection, human-readable conflict diagnosis,
stable lock output, lightweight text registry parsing, and lock readback.

## Data Model

- `Version` stores major, minor, patch, and optional prerelease text.
- `VersionReq` stores the original range text plus normalized comparators.
- `Dependency` connects a package name with a version requirement.
- `PackageVersion` stores one concrete package release and its dependencies.
- `Registry` is an in-memory package index.
- `Resolution` is an ordered list of selected package versions.
- `DepError` represents parse errors, missing packages, no matching versions,
  and version conflicts.

## Text Formats

The first file-backed registry step is a small line-based text format:

```text
core 1.2.0
http 0.3.4 | core: ^1.0.0
appkit 1.0.0 | http: ~0.3.0
```

Each line defines one package version. Dependencies are optional and separated
from the package header with `|`. Individual dependency requirements use
`name: requirement` and are comma-separated.

The lock format remains the stable output produced by `format_lock`:

```text
# MoonDepSolve lock
appkit 1.0.0
http 0.3.4
core 1.2.0
```

`parse_lock` reads the selected packages back into `Resolution`. Dependency
edges intentionally remain in the registry; the lock stores the selected result.

## Resolution Strategy

The resolver starts with root dependencies, expands one pending dependency at a
time, and selects the highest compatible package version from the registry. If a
selected package is encountered again, the new requirement must match the
selected version. When it does not, the resolver returns a conflict message with
the dependency path that introduced the incompatible requirement.

The implementation uses arrays instead of maps to avoid external dependencies
and keep the first version easy to inspect. The public API stays small enough to
serve as a stable base for later structured lockfile, package-index,
upgrade-planning, graph-output, and build-planning extensions.
