# Razorpay
-keep class com.razorpay.** {*;}
-keepclassmembers class * implements com.razorpay.CheckoutPresenter$CheckoutView {
    *;
}

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Play Core (Fixes R8 missing class errors for Flutter engine)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
