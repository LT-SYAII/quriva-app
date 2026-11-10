# Changelog

All notable changes to Quriva are documented in this file.
Format: Keep a Changelog-ish, versioned per SemVer.

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
