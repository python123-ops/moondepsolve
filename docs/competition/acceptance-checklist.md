# MoonDepSolve v0.3 Acceptance Checklist

Official development window: 2026-04-29 to 2026-07-12. Acceptance window: 2026-07-13 to 2026-07-17.

## Functionality

- [x] v0.1/v0.2 entry functions remain available; `ConflictReport.package_name` replaces the reserved `package` field for strict warning-free validation.
- [x] Semantic version parsing, requirement matching, transitive resolution, and highest-compatible selection are implemented.
- [x] Text registry parsing, stable lock output, and lock readback are implemented.
- [x] Dependency graph, text graph, DOT graph, and conflict report output are implemented.
- [x] `HighestCompatible` and exact `MinimalChange` upgrade planning are implemented.
- [x] Add, remove, upgrade, and downgrade changes are reported with the target `Resolution`.
- [x] Invalid input, search limits, and dependency failures return structured errors.
- [x] Native file CLI supports `resolve`, `plan`, lock/text/dot output, and expected-output regression checks.

## Engineering Quality

- [x] `moon info` generated `.mbti` files are checked into the repository.
- [x] `moon fmt --check`, `moon check --deny-warn`, and `moon test --deny-warn` pass.
- [x] Default backend tests pass; native backend tests pass in GitHub CI.
- [x] CI uses full Git history and verifies contributor identity before MoonBit checks.
- [x] CI covers interface drift, formatting, strict diagnostics, default tests, native tests, and file CLI regressions.
- [x] `.gitattributes` keeps text line endings stable and treats binary artifacts as binary.

## Documentation and Compliance

- [x] README, CHANGELOG, CONTRIBUTING, SECURITY, Issue templates, and PR template are present.
- [x] Apache-2.0 license is retained.
- [x] `moonbitlang/async@0.19.4` is recorded in third-party notices.
- [x] One-page proposal Markdown, PDF, and DOCX are present and use the MoonDepSolve project identity.
- [x] Demo script and v0.3 release notes are present.

## Dual Repository State

- [x] Reachable commits are authored and committed as `python123 <python123@users.noreply.gitlink.org.cn>`.
- [x] v0.3 work is merged into `master`.
- [x] GitHub and GitLink `master` point to the same commit.
- [x] `v0.3.0` annotated tag is present on both remotes; `v0.3.1` records the OSC2026 strict-CI fix.
- [x] Fresh-clone style verification has been rerun for identity, default tests, package creation, and demo output where the local environment permits it.
- [x] GitHub and GitLink release records are created or updated during closeout.

## Publication

- [x] `moon package` validates the package archive locally.
- [x] Mooncakes package `python123/moondepsolve` version `0.3.0` is published; `0.3.1` package validation passes and publication is pending module-owner login as `python123`.
