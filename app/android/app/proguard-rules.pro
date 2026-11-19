# Read by Flutter's release build with its own R8 rules.

# device_calendar hands calendars and events to Dart as JSON built from its
# Kotlin field names (Gson). R8 renamed those fields in release builds, so
# every phone calendar reached Dart without an id or a name and the import
# screen showed none (Galaxy S25, 2026-11-16). The plugin's README asks for
# this rule ("Proguard / R8 exceptions").
-keep class com.builttoroam.devicecalendar.** { *; }

# flutter_local_notifications saves scheduled reminders as JSON with Gson
# (2.8.9, which ships no R8 rules) and reads them back to schedule the next
# ones, to list them and to restore them after a reboot. R8 renamed the
# plugin's classes and stripped the generic type of Gson's TypeToken, so after
# the first save every schedule failed ("TypeToken must be created with a type
# argument") and no reminder rang (Galaxy S25, release build, 2026-11-19). The
# plugin's README asks for Gson's rules ("Release build configuration").
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes Signature
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
