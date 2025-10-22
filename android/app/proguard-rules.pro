# Keep ML Kit Text Recognition classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep Google Play Services
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Keep Flutter classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Optional: if you use reflection or GetX
-keep class com.example.** { *; }
-dontwarn com.example.**

# Prevent stripping of metadata annotations
-keepattributes Signature,RuntimeVisibleAnnotations,AnnotationDefault
