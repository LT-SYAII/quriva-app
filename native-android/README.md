# Quriva Native (Kotlin/Android)

This directory is the **native Kotlin rewrite** of Quriva, created to replace the Flutter app for better runtime efficiency and a smaller APK (no Flutter engine/runtime bundled).

## Goals
- 100% Kotlin + Jetpack Compose UI
- Smaller APK/AAB and lower memory overhead vs Flutter build
- Feature parity with the current Quriva app (Quran reader, Quran.com API, recitation audio + background playback, ayah highlighting/timestamps, bookmarks/progress, settings, caching)

## Tech stack
- **UI:** Jetpack Compose, Material 3
- **Networking:** Retrofit/OkHttp + Kotlinx Serialization
- **Database/cache:** Room + DataStore
- **Audio:** Media3 ExoPlayer + MediaSessionService (background/notification)
- **Build:** R8/resource shrinking, ABI splits, (AAB recommended for delivery)

## Implemented (native)
- Surah list (live Quran.com API with Room cache fallback)
- Reader: Arabic + translation, chapter metadata, bookmark toggle, reading progress, ayah highlight/auto-scroll synced to recitation, tap-verse-to-seek
- Audio: shared Media3 ExoPlayer via `MediaSessionService` (background/foreground-capable), mini-player, Now Playing (seek, play/pause/stop, prev/next), auto-next chapter, reader playback controls
- Persistence: Room (chapters/verses cache, bookmarks, progress) + DataStore preferences (language, translation, reciter, theme)
- Library: saved bookmarks and continue-reading
- Search: verse/translation search
- Chapter info screen
- Settings: app language & theme (applied), reciter and translation selection (wired to playback/reader)
- Release prep: minify/shrink resources, ABI splits, proguard rules, `native-release.yml` workflow (manual/tag `native-v*`)

## Remaining for full parity & release swap
- Build/verify on device with full Android SDK (compileSdk 35/platforms): confirm notification/lockscreen controls, audio edge cases, and end-to-end behavior
- Fine-grained UI/UX parity with Flutter (glass/monochrome polish), and deeper offline/error/empty-state parity
- Finalize native signing + release pipeline, publish native APK/AAB, then replace Flutter release artifact only after parity is confirmed (Flutter remains functional until then)

## Build (with Android SDK/toolchain)
```bash
cd native-android
./gradlew :app:assembleRelease   # or :app:bundleRelease
```

## APK size notes
- Prefer Android App Bundle (`:app:bundleRelease`) or per-ABI APKs for smallest delivered size.
- Keep `isMinifyEnabled = true` and `isShrinkResources = true` in release.
- No Flutter engine bundled; assets kept minimal/procedural.
