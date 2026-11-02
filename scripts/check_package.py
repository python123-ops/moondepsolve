#!/usr/bin/env python3
"""Build the release archive and check its contents and extracted sources."""

from __future__ import annotations

import os
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile


def main() -> None:
    root = Path(__file__).resolve().parent.parent
    moon = os.environ.get("MOON", "moon")
    subprocess.run([moon, "package"], cwd=root, check=True)
    manifest = (root / "moon.mod").read_text(encoding="utf-8")
    name = re.search(r'^name\s*=\s*"([^"]+)"', manifest, re.MULTILINE).group(1)
    version = re.search(r'^version\s*=\s*"([^"]+)"', manifest, re.MULTILINE).group(1)
    archive = root / "_build" / "publish" / f"{name.replace('/', '-')}-{version}.zip"
    with zipfile.ZipFile(archive) as package:
        files = package.namelist()
        forbidden = ("_build/", "docs/", "site/", "scripts/", ".git/", ".mooncakes/")
        if any(path.startswith(forbidden) or "credentials" in path for path in files):
            raise AssertionError("Release archive contains maintenance or private files")
        if not {"moon.mod", "moon.pkg", "README.md", "LICENSE"}.issubset(files):
            raise AssertionError("Release archive is missing required module files")
        with tempfile.TemporaryDirectory(prefix="moondepsolve-package-") as directory:
            package.extractall(directory)
            subprocess.run(
                [moon, "check", "--target", "all", "--deny-warn"],
                cwd=directory,
                check=True,
            )
    print(f"Package checks passed: {len(files)} files, {archive.stat().st_size} bytes; all backends compile after extraction.")


if __name__ == "__main__":
    main()
