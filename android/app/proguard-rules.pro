# Gson specific classes & generic signatures retention for R8 / ProGuard
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Preserve Gson type tokens and generic signatures
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keep class * extends com.google.gson.reflect.TypeToken
-keepclassmembers class * extends com.google.gson.reflect.TypeToken { *; }

# Flutter Local Notifications Plugin
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# Preserve Android R raw resources from obfuscation/shrinking
-keep class **.R$* { *; }
-keepclassmembers class **.R$* {
    public static <fields>;
}

