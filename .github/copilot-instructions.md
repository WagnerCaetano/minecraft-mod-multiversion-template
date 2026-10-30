# Minecraft mod multiversion template

- **Forge 1.20.1** in `forge/`; **NeoForge 1.21.1** in `neoforge/`; shared code in `common/` (no Minecraft/loader APIs).
- Mod metadata lives in root `gradle.properties` (`mod_id`, `mod_version`, `curseforge_project_id`, …).

## Releases (tag-only)

Publishing is **never** triggered by pushing a branch. It runs only when a version tag matching `mod_version` is pushed (see `.github/workflows/curseforge-release.yml`).

Before suggesting or creating a release tag, run:

```bash
bash scripts/verify-release-ready.sh
```

If the user wants to tag, prefer `bash scripts/release-tag.sh` then `git push origin v<mod_version>`.

Do not bump `mod_version` in the same change as tagging without updating `CHANGELOG.md` for that version.
