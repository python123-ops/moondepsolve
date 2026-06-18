#!/usr/bin/env python3
"""Reject Git identities and reachable commits that are not python123."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


EXPECTED_NAME = "python123"
EXPECTED_EMAIL = "python123@users.noreply.gitlink.org.cn"
EXPECTED_IDENTITY = f"{EXPECTED_NAME} <{EXPECTED_EMAIL}>"


def git(*args: str) -> str:
    completed = subprocess.run(
        ["git", *args],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    )
    if completed.returncode != 0:
        detail = completed.stderr.strip() or completed.stdout.strip()
        raise RuntimeError(f"git {' '.join(args)} failed: {detail}")
    return completed.stdout.strip()


def configured_identity(role: str) -> str:
    name = git("config", "--get", f"{role}.name")
    email = git("config", "--get", f"{role}.email")
    return f"{name} <{email}>"


def pending_identity(kind: str) -> str:
    raw = git("var", f"GIT_{kind.upper()}_IDENT")
    return raw.rsplit(" ", 2)[0]


def history_violations() -> list[str]:
    fields = "%H%x00%an%x00%ae%x00%cn%x00%ce"
    rows = git("log", "--all", f"--format={fields}")
    violations: list[str] = []
    for row in rows.splitlines():
        parts = row.split("\0")
        if len(parts) != 5:
            violations.append(f"unparseable history row: {row!r}")
            continue
        commit, author_name, author_email, committer_name, committer_email = parts
        author = f"{author_name} <{author_email}>"
        committer = f"{committer_name} <{committer_email}>"
        if author != EXPECTED_IDENTITY or committer != EXPECTED_IDENTITY:
            violations.append(
                f"{commit}: author={author}; committer={committer}"
            )
    return violations


def main() -> int:
    try:
        root = Path(git("rev-parse", "--show-toplevel"))
        checks = {
            "configured user": configured_identity("user"),
            "pending author": pending_identity("author"),
            "pending committer": pending_identity("committer"),
        }
        violations = [
            f"{label}: {actual}"
            for label, actual in checks.items()
            if actual != EXPECTED_IDENTITY
        ]
        violations.extend(history_violations())
    except RuntimeError as error:
        print(f"Contributor identity check failed: {error}", file=sys.stderr)
        return 2

    if violations:
        print(
            f"Contributor identity check failed in {root}.\n"
            f"Expected only {EXPECTED_IDENTITY}:",
            file=sys.stderr,
        )
        for violation in violations:
            print(f"  - {violation}", file=sys.stderr)
        return 1

    commit_count = git("rev-list", "--all", "--count")
    print(
        f"Contributor identity verified: {EXPECTED_IDENTITY} "
        f"across {commit_count} reachable commits."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
