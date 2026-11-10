# Quriva

**Read. Reflect. Live.**

Quriva is an open-source, offline-friendly Quran reader for Android. It puts
focus on reading experience first.
All Quran content — Arabic Uthmani text, translations, surah info, search and
recitations — is fetched live from the **official Quran.com API (v4)** and
cached locally on the device. The app ships **no bundled Quran data**, keeps
**no accounts**, and involves **no analytics or tracking**.

|              | |
|--------------|-|
| Platform     | Android (Flutter) |
| Data source  | [Quran.com API v4](https://quran.com/api) + [Quranicaudio](https://quranicaudio.com) streaming |
| State        | Riverpod 3 |
| Storage      | Drift (SQLite) for cache, bookmarks & reading progress |
| Audio        | just_audio (streaming, per-surah) |
| License      | MIT (code) — content attribution comes from their own licenses, see below |

[![CI](https://github.com/LT-SYAII/quriva-app/actions/workflows/ci.yml/badge.svg)](https://github.com/LT-SYAII/quriva-app/actions/workflows/ci.yml)
[![Release](https://github.com/LT-SYAII/quriva-app/actions/workflows/release.yml/badge.svg)](https://github.com/LT-SYAII/quriva-app/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/code%20license-MIT-green.svg)](LICENSE)

## Features (v0.2.0)

- **Surah index** with simple/Arabic names, translated titles (EN/ID),
  revelation place and verse counts.
- **Per-reciter surah list** — each reciter has their own available-surah
  catalog (sourced live from Quran.com); filter the index to "Audio only" and
  see per-surah availability at a glance.
- **Reader** — Uthmani Arabic text, selectable, adjustable font size,
  with a translation of your choice.
- **Translations** — pick from the live Quran.com translation catalogue
  (searchable; English and Indonesian entries are highlighted).
- **Reciters & background audio** — choose a reciter; play the full surah
  (streamed from Quranicaudio) with a persistent media notification and
  lock-screen controls. Playback continues when you leave the reader or close
  the app UI, with a floating in-reader mini bar.
- **Liquid glass UI** — a monochrome black & white theme with frosted,
  translucent surfaces and a floating glass navigation bar, plus a new app icon.
- **Surah info** — background of each surah (source: Tafhim al-Qur'an, via
  Quran.com), rendered as plain text with clear attribution.
- **Global search** — search by Arabic text or translation keywords
  (Quran.com search), results jump straight to the pinned ayah in the reader.
- **Bookmarks** — local-only, stored in SQLite; open results from the
  bookmarks screen directly to the ayah.
- **Continue reading** — remembers your last opened/visible ayah position.
- **Dark mode**, **light mode**, **system mode**; Arabic font size slider.
- **Offline cache** — content you have opened stays readable without network;
  a "Clear cached content" action lives in Settings.
- **Privacy** — no login, no accounts, no analytics, no third-party
  trackers. Only content hosts are contacted: `api.quran.com` and the
  download/streaming domain used by Quranicaudio.

## Roadmap

- Per-ayah **tafsir view** — the upstream `/tafsirs/{id}/by_verse/{key}`
  endpoint currently returns 404 on Quran.com's v4 API; it is intentionally
  not shipped until the endpoint works again.
- **Word-by-word** study mode.
- **Per-ayah recitation** mode and finer playback controls.
- Multiple simultaneous translations per ayah.
- Tajweed/mushaf page mode.
- Optional account sync (self-hosted, end-to-end encrypted) for bookmarks
  across devices — strictly opt-in.
- Desktop/web builds after Android stabilises.

## Data sources & licenses (summary)

- Arabic text, chapter metadata, translations, search: **Quran.com API v4**.
  Individual translations and tafsir works carry their own licenses and
  authorship; see `ATTRIBUTIONS.md` and `DATA_LICENSES.md` for details.
- Recitation audio: streamed from Quranicaudio (used by Quran.com);
  reciters keep their copyright and are credited in-app.
- Chapter info texts: e.g. *Sayyid Abul Ala Maududi — Tafhim al-Qur'an*, via
  Quran.com; attributed inside the app on every info screen.

Nothing above is redistributed by Quriva; the app is a client.

## Getting started

```bash
git clone https://github.com/LT-SYAII/quriva-app.git
cd quriva-app
flutter pub get
flutter run            # use a device or emulator
```

Requirements: Flutter 3.47+ (Dart 3.13+) and the Android SDK.

### Tests & analysis

```bash
flutter analyze
flutter test
```

### Build a release APK (CI does this for tags)

```bash
flutter build apk --release
```

The CI workflow (`.github/workflows/release.yml`) runs analyze + tests and
publishes a release APK for every `v*` tag. Note that the automated APK is
signed with debug keys meant for easy evaluation; build and sign your own
release for production use.

## Project structure

```
lib/
├── app/                  # App root, router, theme
├── core/
│   ├── api/              # Quran.com API v4 client
│   └── database/         # Drift schema: caches, bookmarks, progress
├── features/
│   ├── audio/            # Playback controller (just_audio)
│   ├── bookmarks/        # Library & bookmark screens
│   ├── quran/            # Domain models, repository, reader/search/info screens
│   └── settings/         # Preferences + settings screen
└── shared/               # Widgets shared across feature folders
```

## Contributing

Issues and pull requests are welcome. If you touch the API client, prefer
thin, verifiable changes and add/adjust tests in `test/`. Keep the privacy
guarantees intact: no analytics SDKs, no account requirements, no data
leaving the device except content requests to Quran.com/Quranicaudio.

## Acknowledgements

- **Quran.com** — for an open, fast and well-designed API that powers this app.
- **Quranicaudio** and every reciter whose recitation the app streams.
- The Flutter team and the open-source packages used (see `pubspec.yaml`).

---

*Quriva is not affiliated with Quran.com. Names of Allah, the Quran and the
relying platforms are used solely for truthful attribution.*
