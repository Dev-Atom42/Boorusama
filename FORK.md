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

## fork-3 — unreleased

Base: upstream master @ `2c5c4c7ba` (the changelog already carries the v4.6.3
notes).

- **(fork)** `{type}` filename token — the media class of a post
  (`image` / `gif` / `video` / `zip` / `flash`), usable as a directory or
  inside the file name; resolver in
  `lib/core/downloads/filename/types/media_type.dart`, wired as a sync base
  token handler (no per-booru work, no extra requests). `{extension}` still
  reflects the real downloaded file, so a ugoira saved through its webm
  sample yields `zip/name.webm` — the accepted mismatch. Documented in
  README.md next to the other fork tokens.
- **(fork)** file info badges on main grid tiles — resolution (`WxH`),
  file size (`Filesize.parse`) and the web-source favicon, ported from the
  related-posts preview into `PostGridFileInfoBadges` and shown as a
  top-right stack layer of `SliverPostGridImageGridItem` (the core
  `ImageGridItem` stays untouched). Behind three new `ImageListingSettings`
  flags (`showResolutionInGrid` / `showFileSizeInGrid` /
  `showSourceLogoInGrid`), so the switches appear in both the global
  appearance settings and the per-instance listing settings; per-instance
  overrides keep winning when enabled. The size badge hides when a booru
  sends no `fileSize`; text badges hide on tiny/micro grids where they
  would not fit.
- **(fork)** news feed for followed queries — an in-app feed of what is new
  for queries the user follows, regardless of booru. Unlike the upstream
  Danbooru saved-search feed it runs on the regular post search API the
  app already uses — same parsers, no new endpoints, no Gold account.
  Subscriptions are plain query strings stored locally in Hive per booru
  config (cursors: `lastSeenPostId` / `lastCheckedAt`); the feed page
  merges the newest posts of every subscription, dedupes by post id and
  shows them newest-first (capped); page 2+ is empty, refresh is manual.
  Entry point in the side bar menu; a manage page handles add/remove.
  The pure merge/cursor logic lives in `core/feed/src/logic/` and is unit
  tested, as is the Hive repository.
- **(build)** `pubspec.yaml` version `4.6.1+190` — one more build bump over
  fork-2 for the fork-3 line.
- **(build)** GitHub Actions release workflow trimmed for the fork
  (`.github/workflows/github-release.yml`): manual `workflow_dispatch` only
  (the `v*` tag push trigger from fork-2 is gone; the ref picked in the
  "Run workflow" branch/tag dropdown is now both the checkout ref and the
  release tag, guarded to `v*`), the dead Windows/macOS build steps and the
  `windows_only` / `release_tag` inputs removed, and a new `draft` input to
  create the release as a GitHub draft instead of publishing it right away.
  Remaining inputs: `draft`, `prerelease`, `recreate_release`, `smoke_run`.

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
