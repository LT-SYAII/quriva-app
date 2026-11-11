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
2. **Data layer (in progress):** Quran.com API client/models/repository (chapters, verses, translations, timelines, reciters, translation resources, search, chapter info) with **Room cache** (chapters/verses) and **DataStore preferences**. 🔄
3. **Core reading (in progress):** Surah list (live/cached) → **Reader** (Arabic + translation, metadata, bookmark toggle, progress save), **Library** (bookmarks + continue-reading), and **Search** implemented. Next: chapter info screen, richer search UX. 🔄
4. **Audio (in progress):** **Media3 ExoPlayer + MediaSessionService** for background playback/notification with shared controller/state, **ayah timeline highlighting/auto-scroll**, mini-player and now-playing screens, reciter/translation selection wired to playback prefs. Next: auto-next, lockscreen/notification polish, richer transport UX. 🔄
5. **Polish & parity:** **Settings** (reciter/translation selection), **Search**, and **Chapter Info** screens added. Remaining: app language/theme controls, deeper offline/error/empty behavior parity, full UI polish.
6. **Release hardening:** R8/resource shrinking configured; remaining: ABI splits/AAB, signing, native CI/release, and swap from Flutter once parity is verified.

> Status: core read, synced background-capable audio, persistence, search, settings, info, library, and player UI are ported to Kotlin. Remaining for full parity: auto-next/advanced transport, complete settings/polish, and native release pipeline/swap. Flutter app remains functional.

## Build (when Android SDK/toolchain is available)
```bash
cd native-android
./gradlew :app:assembleRelease
```

## APK size notes
- Use Android App Bundle (`:app:bundleRelease`) or per-ABI splits for smallest delivered size.
- Keep `isMinifyEnabled = true` and `isShrinkResources = true` in release.
- Avoid bundling large fonts/media; Quriva uses system/procedural assets.
