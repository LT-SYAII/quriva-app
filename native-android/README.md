# Quriva Native (Kotlin/Android)

Native Kotlin rewrite of Quriva (replacement for Flutter) targeting better runtime efficiency and a smaller APK (no Flutter engine/runtime).

## Stack
- **UI:** Jetpack Compose, Material 3 (monochrome theme, app language/theme preferences applied)
- **Networking:** Retrofit/OkHttp + Kotlinx Serialization (Quran.com API)
- **Persistence:** Room (chapters/verses cache, bookmarks, reading progress) + DataStore preferences
- **Audio:** Media3 ExoPlayer + `MediaSessionService` (background/notification-capable), shared playback state/controller
- **Build:** R8/resource shrinking, ABI splits (armeabi-v7a, arm64-v8a, x86_64 + universal), release signing via `key.properties`

## Implemented parity (code-complete)
- Surah list (live API with cached fallback) and chapter info
- Reader: Arabic + translation, metadata, bookmarks, reading progress with resume-to-ayah, synced ayah highlight/auto-scroll, tap-verse-to-seek, playback controls
- Audio/playback: background-capable service, mini-player, Now Playing (seek, play/pause/stop, prev/next), auto-next chapter, playback error handling + retry
- Library: bookmarks and continue-reading
- Search: verse/translation search
- Settings: app language & theme, reciter and translation selection (wired to prefs/playback)
- Polished monochrome UI background/theme

## Release & build
- `native-android/app/build.gradle.kts`: minify/shrink, ABI splits, release signing (reads `native-android/key.properties`, falls back to debug if absent)
- `.github/workflows/native-release.yml`: builds release APKs on `native-v*` tags (and manual), decodes signing secrets when provided, uploads artifacts and publishes tagged releases
- Keystore/secrets: `native-android/key.properties` and keystore files are gitignored

Build (requires Android SDK / platforms for compileSdk 35):
```bash
cd native-android
./gradlew :app:assembleRelease   # or :app:bundleRelease
```

## Status / swap
- Flutter app remains functional and is still the shipped release artifact (`v*` workflow unchanged).
- Native rewrite is **code-complete for core parity** in this repo; final "done" requires build + on-device/CI verification (notification/lockscreen, audio edge cases, offline/error parity, UI polish) and then swapping the published release to native.

## Size notes
- Prefer AAB or per-ABI APKs for smallest delivered size; no Flutter engine bundled.
