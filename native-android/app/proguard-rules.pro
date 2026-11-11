# Quriva native
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod
-dontwarn org.slf4j.impl.StaticLoggerBinder

# Kotlinx Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keepclasseswithmembers class kotlinx.serialization.json.** { kotlinx.serialization.KSerializer serializer(...); }
-keep,includedescriptorclasses class app.quriva.nativeapp.**$$serializer { *; }
-keepclassmembers class app.quriva.nativeapp.** { *** Companion; }
-keepclasseswithmembers class app.quriva.nativeapp.** { kotlinx.serialization.KSerializer serializer(...); }

# Retrofit/OkHttp
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# Media3/Room keep
-keep class androidx.media3.** { *; }
-keep class androidx.room.** { *; }
