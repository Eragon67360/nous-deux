#!/usr/bin/env bash
# Records the build a release job has just sent to testers, so that older
# builds offer the update (docs/UPDATE_SCREEN.md). Run by the iOS TestFlight
# and Android release workflows after their upload.
#
# Usage: scripts/record-build.sh ios|android
# Reads the build number from app/pubspec.yaml and the line on what changed
# from app/release_note.json, which names the build it describes: a line
# written for another build is left out (the screen then shows its general
# text). Needs SUPABASE_URL, SUPABASE_ANON_KEY and RELEASE_TOKEN in the
# environment; without RELEASE_TOKEN it warns and records nothing.
set -euo pipefail
usage="usage: $0 ios|android"
platform="${1:?$usage}"
[[ "$platform" == ios || "$platform" == android ]] || { echo "$usage" >&2; exit 2; }
cd "$(dirname "$0")/.."

if [[ -z "${RELEASE_TOKEN:-}" ]]; then
  echo "::warning::RELEASE_TOKEN manquant : l'écran de mise à jour ne connaîtra pas ce build (scripts/app-builds.sh <serveur> --token)."
  exit 0
fi
: "${SUPABASE_URL:?SUPABASE_URL manquant}" "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY manquant}"

build=$(sed -nE 's/^version:[[:space:]]*[^+[:space:]]+\+([0-9]+).*/\1/p' app/pubspec.yaml)
[[ "$build" =~ ^[0-9]+$ ]] || { echo "Numéro de build introuvable dans app/pubspec.yaml" >&2; exit 1; }
file=$(jq -ce 'if type == "object" and (.build | type) == "number"
               and (.fr | type) == "string" and (.en | type) == "string"
               then . else error("build, fr et en") end' app/release_note.json 2>/dev/null) ||
  { echo "app/release_note.json : il faut un objet avec build, fr et en" >&2; exit 1; }
if [[ "$(jq -r '.build' <<<"$file")" == "$build" ]]; then
  note=$(jq -c '{fr, en}' <<<"$file")
else
  echo "::warning::app/release_note.json décrit le build $(jq -r '.build' <<<"$file"), pas le $build : enregistré sans ligne."
  note='{}'
fi

# The token goes to jq through the environment, never on a command line.
status=$(jq -cn --arg p "$platform" --argjson b "$build" --argjson n "$note" \
    '{p_platform: $p, p_build: $b, p_note: $n, p_token: env.RELEASE_TOKEN}' |
  curl -sS --connect-timeout 10 --max-time 30 -o /dev/null -w '%{http_code}' -X POST \
    "${SUPABASE_URL%/}/rest/v1/rpc/record_app_build" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    -H 'Content-Type: application/json' \
    --data-binary @-) ||
  { echo "::warning::Serveur injoignable : le build $build pour $platform n'est pas enregistré."; exit 1; }
if [[ "$status" == 2* ]]; then
  echo "Build $build enregistré pour $platform."
else
  echo "::warning::Le serveur a refusé le build $build pour $platform (HTTP $status)."
  exit 1
fi
