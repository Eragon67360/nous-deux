#!/usr/bin/env bash
# Fails when R8 renamed a class that must keep its name in release builds.
# - device_calendar sends its models to Dart as JSON keyed by field name, so a
#   renamed model reaches Dart empty: phone calendars without an id, and the
#   import screen showed none (2026-11-16).
# - flutter_local_notifications saves scheduled reminders as Gson JSON and
#   reads them back to schedule again and after a reboot. Renamed, every
#   schedule after the first failed and no reminder rang (2026-11-19).
# The keep rules are in android/app/proguard-rules.pro.
#
# Usage: scripts/check-r8-keeps.sh build/app/outputs/mapping/release/mapping.txt
set -euo pipefail

mapping=${1:?usage: $0 <mapping.txt>}
failed=0

# check <class prefix> <what breaks when renamed>
check() {
  local prefix=$1 effect=$2 lines renamed
  # Mapping lines for classes read "original -> renamed:". Classes R8 writes
  # itself ($$ExternalSynthetic…) aren't the plugin's and may be renamed.
  lines=$(grep -F "$prefix" "$mapping" | grep -E '^[^ ].* -> .*:$' | grep -vF '$$ExternalSynthetic' || true)
  if [ -z "$lines" ]; then
    echo "::error::No ${prefix}* class in $mapping: did the plugin move? Update this check."
    failed=1
    return
  fi
  renamed=$(printf '%s\n' "$lines" | awk '$1 != substr($3, 1, length($3) - 1)')
  if [ -n "$renamed" ]; then
    echo "::error::R8 renamed ${prefix}* classes; $effect:"
    printf '%s\n' "$renamed"
    failed=1
    return
  fi
  echo "${prefix}* kept: $(printf '%s\n' "$lines" | wc -l | tr -d ' ') classes"
}

check 'com.builttoroam.devicecalendar.models.' 'phone calendars would reach Dart without ids'
check 'com.dexterous.flutterlocalnotifications.' 'reminders would stop being scheduled after the first one'
exit $failed
