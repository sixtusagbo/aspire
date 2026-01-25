# Flutter Local Notifications - Gson TypeToken fix for R8
# https://github.com/MaikuB/flutter_local_notifications/issues/2204
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Keep flutter_local_notifications plugin classes
-keep class com.dexterous.** { *; }
