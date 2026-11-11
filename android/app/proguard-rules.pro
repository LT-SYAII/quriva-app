# Flutter/Dart code is AOT-compiled; keep plugin/Android integration entry points.
# Most plugins ship consumer rules, but these guards prevent aggressive shrinking
# from stripping background audio and SQLite JNI surfaces.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.ryanheise.** { *; }
-dontwarn com.ryanheise.**

# sqlite3/drift native bindings
-keep class org.sqlite.** { *; }
-keep class * extends org.sqlite.** { *; }
-dontwarn org.sqlite.**

# OkHttp/ExoPlayer/media stack used by audio plugins (safe keep)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**
