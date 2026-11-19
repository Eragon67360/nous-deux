#!/usr/bin/env bash
# Tests for scripts/play-release-notes.sh. Run from anywhere:
#   scripts/tests/play-release-notes.test.sh
# Each case copies the script into a throwaway repo layout (app/pubspec.yaml,
# app/release_note.json) and checks what it writes and how it exits.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
script="$here/../play-release-notes.sh"
failures=0
roots=()
trap 'rm -rf "${roots[@]}"' EXIT

# new_repo <pubspec version> <release_note.json content> → prints the root
new_repo() {
  local root
  root=$(mktemp -d)
  mkdir -p "$root/scripts" "$root/app"
  cp "$script" "$root/scripts/"
  printf 'name: nousdeux\nversion: %s\n' "$1" >"$root/app/pubspec.yaml"
  printf '%s' "$2" >"$root/app/release_note.json"
  echo "$root"
}

check() { # check <name> <condition…>
  local name=$1; shift
  if "$@"; then echo "ok   $name"; else echo "FAIL $name"; failures=$((failures + 1)); fi
}

# 1. The note describes this build: one file per Play language, the line alone.
root=$(new_repo '0.3.6+30' '{"build": 30, "fr": "Le build 30 apporte la pilule.", "en": "Build 30 brings the pill."}')
out="$root/whatsnew"
roots+=("$root")
"$root/scripts/play-release-notes.sh" "$out" >/dev/null 2>"$root/err"
check "matching build exits 0" test $? -eq 0
# Byte for byte: no trailing newline in Play's notes.
check "writes the French line" cmp -s "$out/whatsnew-fr-FR" <(printf %s "Le build 30 apporte la pilule.")
check "writes the English line" cmp -s "$out/whatsnew-en-US" <(printf %s "Build 30 brings the pill.")
check "writes nothing else" test "$(ls "$out" 2>/dev/null | wc -l | tr -d ' ')" = 2

# 2. The note was left from the previous release: refuse, name both builds.
root=$(new_repo '0.3.6+31' '{"build": 30, "fr": "Le build 30.", "en": "Build 30."}')
roots+=("$root")
"$root/scripts/play-release-notes.sh" "$root/whatsnew" >/dev/null 2>"$root/err"
check "stale note fails" test $? -ne 0
check "stale note names both builds" grep -q '30.*31' "$root/err"
check "stale note writes no notes" test ! -e "$root/whatsnew/whatsnew-fr-FR"

# 3. Play takes at most 500 characters per language.
long=$(printf 'é%.0s' $(seq 1 501))
root=$(new_repo '0.3.6+30' "{\"build\": 30, \"fr\": \"$long\", \"en\": \"Build 30.\"}")
roots+=("$root")
"$root/scripts/play-release-notes.sh" "$root/whatsnew" >/dev/null 2>"$root/err"
check "501 characters fail" test $? -ne 0
check "the error names the language" grep -q 'ligne fr fait 501' "$root/err"
check "501 characters write nothing" test ! -e "$root/whatsnew"
exactly=$(printf 'é%.0s' $(seq 1 500))
root=$(new_repo '0.3.6+30' "{\"build\": 30, \"fr\": \"$exactly\", \"en\": \"Build 30.\"}")
roots+=("$root")
"$root/scripts/play-release-notes.sh" "$root/whatsnew" >/dev/null 2>"$root/err"
check "500 characters pass" test $? -eq 0
# Emoji count twice (UTF-16, as Play's Java strings do): 497 + 2 emoji = 501.
emoji=$(printf 'a%.0s' $(seq 1 497))😀😀
root=$(new_repo '0.3.6+30' "{\"build\": 30, \"fr\": \"Build 30.\", \"en\": \"$emoji\"}")
roots+=("$root")
"$root/scripts/play-release-notes.sh" "$root/whatsnew" >/dev/null 2>"$root/err"
check "emoji count as two" test $? -ne 0
check "emoji error names the language" grep -q 'ligne en fait 501' "$root/err"

# 4. A note without one of the languages, or empty, is refused.
root=$(new_repo '0.3.6+30' '{"build": 30, "fr": "Le build 30."}')
roots+=("$root")
"$root/scripts/play-release-notes.sh" "$root/whatsnew" >/dev/null 2>"$root/err"
check "missing English fails" test $? -ne 0
check "missing English writes nothing" test ! -e "$root/whatsnew"
root=$(new_repo '0.3.6+30' '{"build": 30, "fr": "  ", "en": "Build 30."}')
roots+=("$root")
"$root/scripts/play-release-notes.sh" "$root/whatsnew" >/dev/null 2>"$root/err"
check "blank French fails" test $? -ne 0
check "blank French writes nothing" test ! -e "$root/whatsnew"

echo
if [[ $failures -eq 0 ]]; then echo "all passed"; else echo "$failures failed"; exit 1; fi
