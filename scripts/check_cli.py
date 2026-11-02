#!/usr/bin/env python3
"""Check native CLI outputs and failures on Windows and Unix."""

from __future__ import annotations

import os
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parent.parent
MOON = os.environ.get("MOON", "moon")


def run_cli(*args: str) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        [MOON, "run", "cmd/cli", "--target", "native", "--deny-warn", "--", *args],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )


def main() -> None:
    common = ("--registry", "examples/registry.txt", "--root", "app:^1.0.0")
    cases = [
        ("resolve.lock", ("resolve", *common, "--format", "lock")),
        ("dependency-graph.dot", ("resolve", *common, "--format", "dot")),
        ("minimal-plan.txt", ("plan", *common, "--lock", "examples/current.lock",
                              "--strategy", "minimal", "--max-states", "100000")),
        ("highest-plan.txt", ("plan", *common, "--lock", "examples/current.lock",
                              "--strategy", "highest")),
    ]
    for expected_file, args in cases:
        result = run_cli(*args)
        if result.returncode != 0:
            raise RuntimeError(result.stderr.decode("utf-8", errors="replace"))
        expected = (ROOT / "examples" / "expected" / expected_file).read_bytes()
        if result.stdout != expected:
            raise AssertionError(f"CLI output differs from {expected_file}: {result.stdout!r}")

    with tempfile.TemporaryDirectory(prefix="moondepsolve-") as directory:
        invalid_registry = Path(directory) / "invalid.txt"
        invalid_registry.write_text("app 4294967296.0.0\n", encoding="utf-8")
        failures = [
            (("resolve", "--registry", str(Path(directory) / "missing.txt"),
              "--root", "app:^1.0.0"), b"error:"),
            (("resolve", "--registry", str(invalid_registry),
              "--root", "app:^1.0.0"), b"invalid version"),
            (("plan", *common, "--lock", "examples/current.lock",
              "--strategy", "minimal", "--max-states", "0"), b"invalid max states"),
        ]
        for args, message in failures:
            result = run_cli(*args)
            if result.returncode != 2 or result.stdout or message not in result.stderr:
                raise AssertionError(
                    f"Unexpected CLI failure: exit={result.returncode}, "
                    f"stdout={result.stdout!r}, stderr={result.stderr!r}"
                )
    print("CLI checks passed: 4 exact outputs and 3 error cases.")


if __name__ == "__main__":
    main()
