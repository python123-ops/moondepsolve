# Git Hooks

## Pre-commit Hook

This pre-commit hook verifies the sole contributor identity, formatting,
MoonBit diagnostics, and the default test suite before finalizing a commit.

### Usage Instructions

To use this pre-commit hook:

1. Make the hook executable if it is not already:
   ```bash
   chmod +x .githooks/pre-commit
   ```

2. Configure Git to use the hooks in the .githooks directory:
   ```bash
   git config core.hooksPath .githooks
   ```

3. The hook will automatically run when you execute `git commit`.

The warning list enables warning 73 while retaining the v0.2-compatible public
field `ConflictReport.package`, which MoonBit currently reports as warning 35.
