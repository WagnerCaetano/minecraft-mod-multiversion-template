---
applyTo: "gradle.properties,CHANGELOG.md,.github/workflows/curseforge-release.yml,scripts/release-tag.sh,scripts/verify-release-ready.sh"
description: Verify tag-based CurseForge release readiness before creating or pushing version tags
---

# Tag-based release verification

When the user asks to **release**, **publish**, **tag**, or **ship** a version, or when editing release-related files, enforce this checklist before recommending `git push origin vX.Y.Z`.

## Required state (must all pass)

1. **`mod_version`** in root `gradle.properties` is the exact version being released (semver `x.y.z`, optional suffix allowed).
2. **`CHANGELOG.md`** contains a heading `## <mod_version>` with notes for that release.
3. Changes are **committed**; working tree is clean (no unstaged/uncommitted edits).
4. Git tag **`v<mod_version>`** does **not** already exist locally or on the remote.
5. Tag name must equal **`v` + `mod_version`** (CI fails otherwise). Example: `mod_version=1.2.3` → tag `v1.2.3` only.
6. **`curseforge_project_id`** is set in `gradle.properties` (numeric, not empty/`0`) before CI publish.
7. GitHub repo secret **`CURSEFORGE_API_TOKEN`** must exist for Actions (remind user; do not commit tokens).

## Commands to run (in order)

```bash
bash scripts/verify-release-ready.sh
bash scripts/release-tag.sh
git push origin v$(grep '^mod_version=' gradle.properties | cut -d= -f2 | tr -d '\r')
```

Optional dry run without publishing:

```bash
./gradlew buildAll
```

## What CI does on tag push

Workflow: `.github/workflows/curseforge-release.yml` — triggers on tags `v[0-9]*.*`

- Validates `github.ref_name` === `v${mod_version}`
- `./gradlew buildAll` then `./gradlew publishAllCurseForge`
- Creates GitHub Release with jars from `forge/build/libs/` and `neoforge/build/libs/`

## Do not

- Trigger release by pushing to a `release` branch (not configured).
- Create tags that do not match `mod_version`.
- Auto-bump `mod_version` after publish in CI (developer bumps on main for the *next* release).
- Put API tokens in the repository.

## If verification fails

Explain the failing check from `verify-release-ready.sh` output and fix `gradle.properties` / `CHANGELOG.md` / git state before tagging.
