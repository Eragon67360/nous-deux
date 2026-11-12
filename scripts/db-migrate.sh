#!/usr/bin/env bash
# Applies the supabase/migrations/*.sql files the database doesn't have yet,
# in order, each in one transaction, and records each one in
# supabase_migrations.schema_migrations (the Supabase CLI's table).
#
# Usage: scripts/db-migrate.sh root@<server>   # self-hosted server, over SSH
#        scripts/db-migrate.sh local            # a local docker stack
#        add --list to only show what would be applied.
set -euo pipefail
target="${1:?usage: $0 user@server|local [--list]}"
mode="${2:-}"
cd "$(dirname "$0")/.."

run() { if [[ "$target" == local ]]; then bash -c "$1"; else ssh "$target" "$1"; fi; }

db=$(run "docker ps --format '{{.Names}}' | grep -E '(^|-)supabase-db(-|$)' | head -n1")
[[ -n "$db" ]] || { echo "no supabase-db container on $target" >&2; exit 1; }
psql_in="docker exec -i $db psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q -t -A"

run "$psql_in" <<'SQL'
SET client_min_messages = warning;
CREATE SCHEMA IF NOT EXISTS supabase_migrations;
CREATE TABLE IF NOT EXISTS supabase_migrations.schema_migrations (
  version text PRIMARY KEY, statements text[], name text
);
SQL
applied=$(echo "SELECT version FROM supabase_migrations.schema_migrations;" | run "$psql_in")

count=0
for f in supabase/migrations/*.sql; do
  base=$(basename "$f" .sql)
  version=${base%%_*}
  name=${base#*_}
  grep -qx "$version" <<<"$applied" && continue
  count=$((count + 1))
  if [[ "$mode" == --list ]]; then echo "pending: $base"; continue; fi
  {
    echo "BEGIN;"
    cat "$f"
    echo
    echo "INSERT INTO supabase_migrations.schema_migrations (version, name) VALUES ('$version', '$name');"
    echo "COMMIT;"
  } | run "$psql_in" >/dev/null
  echo "applied: $base"
done
(( count )) || echo "up to date"
