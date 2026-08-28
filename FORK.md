# Fork Changelog

This file tracks what this fork does on top of upstream
[khoadng/Boorusama](https://github.com/khoadng/Boorusama).

`CHANGELOG.md` is kept byte-identical to upstream and is never edited here,
so syncing with upstream never conflicts on it. Upstream release notes for
everything marked *(sync)* below live in [CHANGELOG.md](CHANGELOG.md).

Tags:

- **(fork)** — exists only in this fork
- **(sync)** — upstream code merged in; details in CHANGELOG.md
- **(build)** — packaging / release tweak

## fork-2 — 2026-11-06

Base: upstream master @ `bfc30e792` (23 commits after `v4.6.1`; the
changelog already carries the v4.6.2 notes).

- **(sync)** Upstream 4.6.x feature set: PIN app lock and app-preview blur,
  Wi-Fi-only download option, optional metadata files alongside downloads,
  up to two quick actions on post thumbnails, per-profile media host
  overrides, favorite tag and label management improvements, bulk download
  for Anime-Pictures/Zerochan, Arabic and Indonesian translations, updated
  Turkish, Tamil and Spanish.
- **(fork)** Subdirectory downloads carried over the 4.6.x downloader:
  `{artist}/{id}.jpg`-style templates keep saving into nested folders;
  empty tags and path traversal attempts (`../`, stray slashes) stay
  sanitized.
- **(build)** `pubspec.yaml` version `4.6.1+189` — the upstream version
  line plus a small build bump, so fork builds stay distinguishable
  on-device.

## fork-1 — 2026-09-14

Base: upstream master @ `e79abb5c0` (post-`v4.5.0`, `4.5.0+185`).

- **(fork)** feat: subdirectory downloads — slashes in filename templates
  are treated as directory separators; examples in README.md.
- **(fork)** fix(downloads): sanitize path components and prevent
  directory traversal.
- **(build)** version bumped to `4.5.1+186`; release workflow, Android
  package name and debug keystore adjusted for fork builds.
