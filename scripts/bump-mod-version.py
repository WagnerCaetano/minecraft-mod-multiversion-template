#!/usr/bin/env python3
"""Bump semver patch in root gradle.properties (mod_version=). Prints new version to stdout."""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
PROPS = ROOT / "gradle.properties"


def bump_patch(version: str) -> str:
    version = version.strip()
    match = re.match(r"^(\d+)\.(\d+)\.(\d+)(.*)$", version)
    if not match:
        raise SystemExit(f"mod_version is not semver x.y.z: {version!r}")
    major, minor, patch, suffix = match.groups()
    return f"{major}.{minor}.{int(patch) + 1}{suffix}"


def main() -> None:
    text = PROPS.read_text(encoding="utf-8")
    match = re.search(r"^(mod_version=)(.+)$", text, re.MULTILINE)
    if not match:
        raise SystemExit("mod_version not found in gradle.properties")

    old = match.group(2).strip()
    new = bump_patch(old)
    text = text[: match.start(2)] + new + text[match.end(2) :]
    PROPS.write_text(text, encoding="utf-8")
    print(new)


if __name__ == "__main__":
    main()
