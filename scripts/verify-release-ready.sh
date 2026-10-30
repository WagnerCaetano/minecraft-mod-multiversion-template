#!/usr/bin/env bash
# Pre-flight checks before creating/pushing a release tag (matches curseforge-release.yml).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
fail() { echo -e "${RED}FAIL:${NC} $*" >&2; exit 1; }
ok() { echo -e "${GREEN}OK:${NC} $*"; }
warn() { echo -e "${RED}WARN:${NC} $*" >&2; }

PROPS="$ROOT/gradle.properties"
CHANGELOG="$ROOT/CHANGELOG.md"
TAG_ARG="${1:-}"

if [ ! -f "$PROPS" ]; then
  fail "Missing gradle.properties"
fi

VERSION="$(grep '^mod_version=' "$PROPS" | cut -d= -f2- | tr -d '\r' | xargs)"
if [ -z "$VERSION" ]; then
  fail "mod_version is empty in gradle.properties"
fi
if ! echo "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+([.-][0-9A-Za-z.-]+)?$'; then
  fail "mod_version must look like semver (e.g. 1.2.3): got '$VERSION'"
fi
ok "mod_version=$VERSION"

EXPECTED_TAG="v${VERSION}"
if [ -n "$TAG_ARG" ]; then
  if [ "$TAG_ARG" != "$EXPECTED_TAG" ]; then
    fail "Tag $TAG_ARG does not match gradle.properties (expected $EXPECTED_TAG)"
  fi
  ok "Tag argument matches mod_version ($TAG_ARG)"
else
  echo "Expected release tag: $EXPECTED_TAG"
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git rev-parse "$EXPECTED_TAG" >/dev/null 2>&1; then
    fail "Tag $EXPECTED_TAG already exists. Bump mod_version before the next release."
  fi
  ok "Tag $EXPECTED_TAG is not taken yet"

  if ! git diff --quiet || ! git diff --cached --quiet; then
    fail "Uncommitted changes. Commit mod_version and CHANGELOG.md before tagging."
  fi
  ok "Working tree clean"
else
  warn "Not a git repository; skipping tag existence and clean working tree checks"
fi

if [ ! -f "$CHANGELOG" ]; then
  fail "Missing CHANGELOG.md"
fi
if ! grep -qE "^##[[:space:]]+${VERSION}([[:space:]]|$)" "$CHANGELOG"; then
  fail "CHANGELOG.md has no section '## ${VERSION}'. Add release notes before tagging."
fi
ok "CHANGELOG.md contains section for $VERSION"

CF_ID="$(grep '^curseforge_project_id=' "$PROPS" | cut -d= -f2- | tr -d '\r' | xargs || true)"
if [ -z "$CF_ID" ] || [ "$CF_ID" = "0" ]; then
  warn "curseforge_project_id is not set; CI publish will fail until you set it in gradle.properties"
else
  ok "curseforge_project_id=$CF_ID"
fi

if [ -z "${CURSEFORGE_API_TOKEN:-}" ]; then
  warn "CURSEFORGE_API_TOKEN not set (required in GitHub Actions secret for publish)"
else
  ok "CURSEFORGE_API_TOKEN is set locally"
fi

echo ""
echo "Release pre-flight passed. Next steps:"
echo "  git tag -a $EXPECTED_TAG -m \"Release $EXPECTED_TAG\""
echo "  git push origin $EXPECTED_TAG"
