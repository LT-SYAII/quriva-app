# Quriva Native (Kotlin/Android)

This directory is the **native Kotlin rewrite** of Quriva, created to replace the Flutter app for better runtime efficiency and a smaller APK (no Flutter engine/runtime bundled).

## Goals
- 100% Kotlin + Jetpack Compose UI
- Smaller APK/AAB and lower memory overhead vs Flutter build
- Feature parity with the current Quriva app (Quran reader, Quran.com API, recitation audio + background playback, ayah highlighting/timestamps, bookmarks/progress, settings, caching)

## Tech stack (planned)
- **UI:** Jetpack Compose, Material 3
- **DI:** Hilt
- **Networking:** Retrofit/OkHttp + Kotlinx Serialization (or Moshi)
- **Database/cache:** Room + DataStore
- **Audio:** Media3 ExoPlayer + MediaSessionService (background/notification)
- **Images:** none required (procedural/monochrome UI), or Coil if added
- **Build:** R8 full mode/shrinkResources, ABI splits/AAB for minimal download size

## Migration phases
1. **Foundation:** Gradle/Kotlin/Compose project, app shell, theme, Compose Navigation. ✅
2. **Data layer (in progress):** Quran.com API client/models/repository for chapters, uthmani verses, translations, and chapter recitation timelines. Next: Room cache, DataStore preferences. 🔄
3. **Core reading (in progress):** Surah list (live) → **Reader screen** (Arabic + translation, chapter metadata) implemented. Next: search, bookmarks, reading progress. 🔄
4. **Audio (in progress):** **Media3 ExoPlayer** playback in reader with **ayah timeline highlighting/auto-scroll**. Next: full background MediaSessionService + notification, mini/now-playing UI, reciter/catalog selection. 🔄
5. **Polish & parity:** chapter info, reciter/translation selection, offline/cache behavior, error/empty states.
6. **Release hardening:** baseline profiles, R8/resource shrinking, ABI splits/AAB, signing/CI, remove/replace Flutter app once parity is verified.

> Status: substantial Kotlin-native progress landed (list + reader + synced audio). Full feature parity and release swap remain a multi-step effort; the Flutter app stays functional throughout.

## Build (when Android SDK/toolchain is available)
```bash
cd native-android
./gradlew :app:assembleRelease
```

## APK size notes
- Use Android App Bundle (`:app:bundleRelease`) or per-ABI splits for smallest delivered size.
- Keep `isMinifyEnabled = true` and `isShrinkResources = true` in release.
- Avoid bundling large fonts/media; Quriva uses system/procedural assets.
