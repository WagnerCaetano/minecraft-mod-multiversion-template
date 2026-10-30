#!/usr/bin/env bash
# Create annotated tag v<mod_version> after verify-release-ready.sh passes.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

bash "$ROOT/scripts/verify-release-ready.sh"

VERSION="$(grep '^mod_version=' gradle.properties | cut -d= -f2 | tr -d '\r' | xargs)"
TAG="v${VERSION}"

git tag -a "$TAG" -m "Release $TAG"
echo "Created tag $TAG. Push with: git push origin $TAG"
