#!/usr/bin/env bash
# Writes Play's release notes for the build in app/pubspec.yaml from the
# line in app/release_note.json, so the Android release job can publish to
# internal testers without anyone filling the notes in the Console.
#
# Usage: scripts/play-release-notes.sh <out-dir>
# Writes <out-dir>/whatsnew-fr-FR and whatsnew-en-US, the names
# r0adkll/upload-google-play reads. Fails, writing nothing, when the note
# describes another build or a line is blank or over Play's 500 characters:
# the release job runs it first, before anything is built or uploaded.
set -euo pipefail
out="${1:?usage: $0 <out-dir>}"
root="$(cd "$(dirname "$0")/.." && pwd)"

build=$(sed -nE 's/^version:[[:space:]]*[^+[:space:]]+\+([0-9]+).*/\1/p' "$root/app/pubspec.yaml")
[[ "$build" =~ ^[0-9]+$ ]] || { echo "::error::Numéro de build introuvable dans app/pubspec.yaml" >&2; exit 1; }
file=$(jq -ce 'if type == "object" and (.build | type) == "number"
               and (.fr | type) == "string" and (.en | type) == "string"
               then . else error("build, fr et en") end' "$root/app/release_note.json" 2>/dev/null) ||
  { echo "::error::app/release_note.json : il faut un objet avec build, fr et en" >&2; exit 1; }

noted=$(jq -r '.build' <<<"$file")
if [[ "$noted" != "$build" ]]; then
  echo "::error::app/release_note.json décrit le build $noted, pas le $build : écrivez la ligne du build $build (FR et EN) avant la release." >&2
  exit 1
fi
for lang in fr en; do
  line=$(jq -r --arg l "$lang" '.[$l]' <<<"$file")
  [[ -n "${line//[[:space:]]/}" ]] ||
    { echo "::error::app/release_note.json : la ligne $lang est vide." >&2; exit 1; }
  length=$(jq -r --arg l "$lang" '.[$l] | length' <<<"$file")
  ((length <= 500)) ||
    { echo "::error::app/release_note.json : la ligne $lang fait $length caractères, Play en accepte 500." >&2; exit 1; }
done

mkdir -p "$out"
jq -j '.fr' <<<"$file" >"$out/whatsnew-fr-FR"
jq -j '.en' <<<"$file" >"$out/whatsnew-en-US"
echo "Notes de version Play écrites pour le build $build."
