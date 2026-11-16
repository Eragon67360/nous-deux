#!/usr/bin/env bash
# Fails when R8 renamed a class that must keep its name in release builds.
# device_calendar sends its models to Dart as JSON keyed by field name, so a
# renamed model reaches Dart empty: phone calendars without an id, and the
# import screen showed none (2026-11-16). The keep rule is in
# android/app/proguard-rules.pro.
#
# Usage: scripts/check-r8-keeps.sh build/app/outputs/mapping/release/mapping.txt
set -euo pipefail

mapping=${1:?usage: $0 <mapping.txt>}
prefix='com.builttoroam.devicecalendar.models.'

# Mapping lines for classes read "original -> renamed:".
lines=$(grep -F "$prefix" "$mapping" | grep -E '^[^ ].* -> .*:$' || true)
if [ -z "$lines" ]; then
  echo "::error::No ${prefix}* class in $mapping: did device_calendar move? Update this check."
  exit 1
fi

renamed=$(printf '%s\n' "$lines" | awk '$1 != substr($3, 1, length($3) - 1)')
if [ -n "$renamed" ]; then
  echo "::error::R8 renamed device_calendar models; phone calendars would reach Dart without ids:"
  printf '%s\n' "$renamed"
  exit 1
fi
echo "device_calendar models kept: $(printf '%s\n' "$lines" | wc -l | tr -d ' ') classes"
