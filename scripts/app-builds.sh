#!/usr/bin/env bash
# The update screen's rows on the server (docs/UPDATE_SCREEN.md).
#
# Usage: scripts/app-builds.sh <user@server|local>
#          shows the latest and minimum build per platform
#        scripts/app-builds.sh <user@server|local> --min ios|android <build>
#          builds older than <build> must update: only for a build that
#          breaks older ones (a server change, say)
#        scripts/app-builds.sh <user@server|local> --token [--to-file <path>]
#          a new token for the release jobs. Only its SHA-256 goes to the
#          server; the token goes to the repository secret RELEASE_TOKEN
#          (gh, with GH_TOKEN for Eragon67360), or to <path> (rehearsal).
#          The previous token stops working.
set -euo pipefail
usage="usage: $0 user@server|local [--min ios|android <build> | --token [--to-file <path>]]"
target="${1:?$usage}"
action="${2:-}"
cd "$(dirname "$0")/.."

die() { echo "$*" >&2; exit 1; }
run() { if [[ "$target" == local ]]; then bash -c "$1"; else ssh "$target" "$1"; fi; }

db=$(run "docker ps --format '{{.Names}}' | grep -E '(^|-)supabase-db(-|$)' | head -n1")
[[ -n "$db" ]] || die "Pas de conteneur supabase-db sur $target"
psql_in="docker exec -i $db psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q -t -A -F ' | '"

show() {
  echo "plateforme | dernier build | minimum | note"
  run "$psql_in" <<'SQL'
SELECT platform, latest_build, min_build, note FROM public.app_builds ORDER BY platform;
SQL
}

case "$action" in
  "")
    show
    ;;
  --min)
    platform="${3:-}"
    build="${4:-}"
    [[ "$platform" == ios || "$platform" == android ]] || die "$usage"
    [[ "$build" =~ ^[0-9]+$ ]] || die "$usage"
    run "$psql_in" >/dev/null <<SQL
UPDATE public.app_builds SET min_build = $build, updated_at = now() WHERE platform = '$platform';
SQL
    echo "Minimum $platform : build $build. Les builds plus anciens affichent « Mise à jour nécessaire »."
    show
    ;;
  --token)
    file=""
    if [[ "${3:-}" == --to-file ]]; then
      file="${4:?$usage}"
    elif [[ -n "${3:-}" ]]; then
      die "$usage"
    fi
    [[ -n "$file" ]] || command -v gh >/dev/null || die "gh introuvable"
    token=$(openssl rand -hex 32)
    hash=$(printf '%s' "$token" | shasum -a 256 | cut -d' ' -f1)
    run "$psql_in" >/dev/null <<SQL
INSERT INTO private.release_token (token_sha256) VALUES (decode('$hash', 'hex'))
ON CONFLICT (only_row) DO UPDATE SET token_sha256 = EXCLUDED.token_sha256;
SQL
    if [[ -n "$file" ]]; then
      ( umask 077; printf '%s' "$token" > "$file" )
      echo "Jeton enregistré sur $target ; le jeton est dans $file."
    else
      printf '%s' "$token" | gh secret set RELEASE_TOKEN --repo Eragon67360/nous-deux ||
        die "Le secret GitHub n'a pas été enregistré : relancez $0 $target --token."
      echo "Jeton enregistré sur $target et dans le secret GitHub RELEASE_TOKEN."
    fi
    ;;
  *)
    die "$usage"
    ;;
esac
