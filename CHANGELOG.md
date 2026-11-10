# Changelog

All notable changes to Quriva are documented in this file.
Format: Keep a Changelog-ish, versioned per SemVer.

## [Unreleased]

### Changed
- (nothing yet)

## [0.2.5] — 2026-11-10

### Fixed
- In-reader "now playing" bar positioned above system navigation (respects
  bottom safe-area inset) so it is no longer covered by the phone nav bar.
- Hardened playback track selection to use surah/reciter identity (not just
  URL) so toggling/starting audio always targets the correct surah.

## [0.2.4] — 2026-11-10

### Fixed
- Strip Quran.com footnote/HTML markup from translation text (e.g. raw
  `<sup foot_note=...>` tags no longer appear) in reader and search.

### Changed
- Audio controls moved to the ayah/reader section: per-ayah play/pause buttons
  and a surah header play control (surah-level recitation), with auto-advance
  to the next surah when playback completes.
- Performance optimizations: disabled expensive backdrop blur on list/verse
  tiles and removed the mass per-reciter catalog prefetch to reduce jank and
  network load.

## [0.2.3] — 2026-11-10

### Fixed
- Make startup resilient: `JustAudioBackground.init` failures no longer block
  app launch, and uncaught widget errors render a visible message instead of a
  blank black screen.

## [0.2.2] — 2026-11-10

### Fixed
- Added required `audio_service` foreground service and media button receiver
  declarations to AndroidManifest for `just_audio_background`, fixing app
  startup getting stuck on loading.

## [0.2.1] — 2026-11-10

### Changed
- Release APKs are now signed with a persistent release keystore in CI so
  installs can be updated in-place over future releases.
- Release artifact is published with a versioned name:
  `quriva-v<version>-release.apk` (instead of the generic `app-release.apk`).
  `app-release.apk` remains the local build output path.

## [0.2.0] — 2026-11-10

### Added
- New Quriva app icon (adaptive launcher icon).
- Monochrome black & white "liquid glass" UI: frosted translucent surfaces,
  hairline borders and a floating glass navigation bar.
- Per-reciter surah catalog: the home screen shows how many surahs a reciter
  has recorded, lists/filters surahs by the selected reciter ("Audio only"),
  and indicates availability per surah.
- Background recitation playback with a persistent media notification and
  lock-screen controls (just_audio_background). A floating in-reader mini bar
  stays in sync with the global player.

### Changed
- Player is now app-lifetime/global so audio continues when leaving the reader
  or closing the app UI.
- Android-first: removed iOS targets and references from the repository and
  documentation. iOS may return later via App Store/TestFlight.

## [0.1.0] — 2026-11-10

Foundation release: client-only Quran.com-powered reader.

### Added
- Surah index with EN/ID names, revelation place, verse counts.
- Reader: Uthmani Arabic (selectable), adjustable font size, translation panel.
- Translation picker over the live Quran.com catalogue (EN/ID highlighted).
- Reciter picker; per-surah streaming audio with seek bar and in-reader
  mini-bar (just_audio).
- Surah info screen with in-app attribution (Maududi / Quran.com).
- Global Quran search (Quran.com `/search`), results jump to the ayah.
- Local bookmarks & continue-reading progress (Drift/SQLite).
- Offline content cache + "Clear cached content" in Settings.
- Dark / light / system themes.
- Privacy: no accounts, no analytics, no trackers, no bundled Quran data.
- Tests: Quran.com client contract tests (mock HTTP) and Drift behavior tests.
- CI: analyze+test on push/PR; release workflow that builds and publishes an
  APK for `v*` tags.
