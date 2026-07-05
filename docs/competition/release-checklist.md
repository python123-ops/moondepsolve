# MoonDepSolve v0.3 Closeout Checklist

## Code, API, and Identity

- [x] `git config user.name` is `python123` for release commits.
- [x] `git config user.email` is `python123@users.noreply.gitlink.org.cn` for release commits.
- [x] `python scripts/check_contributor_identity.py --ref HEAD` passes.
- [x] `moon info` generated interfaces are reviewed and checked in.
- [x] `moon fmt --check` passes.
- [x] `moon check --warn-list '+73-35'` passes.
- [x] `moon test --warn-list=-35` passes.
- [x] `moon run cmd/main --warn-list=-35` passes.
- [x] Native tests and CLI regression checks are covered by GitHub CI.

## Documentation and Compliance

- [x] README API, CLI, roadmap, version, and repository status are aligned.
- [x] CHANGELOG, CONTRIBUTING, SECURITY, Issue templates, and PR template are present.
- [x] Apache-2.0 and third-party dependency notices are present.
- [x] One-page PDF and DOCX proposal artifacts are present.
- [x] `docs/competition/release-notes-v0.3.md` is used for platform release notes.

## Repositories and Releases

- [x] New closeout commits use the `python123` author and committer identity.
- [x] v0.3 is merged into `master`.
- [x] GitHub and GitLink `master` point to the same commit before release finalization.
- [x] Annotated `v0.3.0` tag is synchronized to both remotes.
- [x] GitHub and GitLink v0.3.0 release records are created.
- [x] Fresh-clone style validation covers identity, default tests, package creation, and demo behavior.

## Mooncakes Publication

- [x] Mooncakes publication completed for `python123/moondepsolve` version `0.3.0`; `moon publish --dry-run` and `moon publish` both passed server-side validation.
