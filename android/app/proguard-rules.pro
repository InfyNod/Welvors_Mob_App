# ==============================================================================
# Flutter ProGuard / R8 Rules for Welvors App Size & Code Shrinking
# ==============================================================================

# Flutter Core & Plugin Registrant
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Razorpay Flutter Gateway
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Socket.IO Client & Engine.IO
-keep class io.socket.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn io.socket.**
-dontwarn okhttp3.**
-dontwarn okio.**

# Firebase Messaging & Core
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Maps & Play Services
-keep class com.google.android.gms.maps.** { *; }
-keep interface com.google.android.gms.maps.** { *; }
-dontwarn com.google.android.gms.**

# Camera & Video Player
-keep class io.flutter.plugins.camera.** { *; }
-keep class io.flutter.plugins.videoplayer.** { *; }

# Flutter Local Notifications & Desugaring
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Kotlin Coroutines and Reflection
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
