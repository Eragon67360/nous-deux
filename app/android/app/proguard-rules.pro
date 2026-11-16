# Read by Flutter's release build with its own R8 rules.

# device_calendar hands calendars and events to Dart as JSON built from its
# Kotlin field names (Gson). R8 renamed those fields in release builds, so
# every phone calendar reached Dart without an id or a name and the import
# screen showed none (Galaxy S25, 2026-11-16). The plugin's README asks for
# this rule ("Proguard / R8 exceptions").
-keep class com.builttoroam.devicecalendar.** { *; }
