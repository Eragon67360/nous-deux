#!/usr/bin/env bash
# Copies the push functions to the self-hosted Supabase and restarts its
# functions container. Usage: scripts/deploy-functions.sh root@<server>
# The functions folder is found from the running container's mount, so the
# Coolify service id doesn't need to be known. See docs/SELF_HOSTING.md.
set -euo pipefail
host="${1:?usage: $0 user@server}"
cd "$(dirname "$0")/.."

container=$(ssh "$host" "docker ps --format '{{.Names}}' | grep -E '(^|-)supabase-edge-functions(-|$)' | head -n1")
[[ -n "$container" ]] || { echo "no supabase-edge-functions container on $host" >&2; exit 1; }
dir=$(ssh "$host" "docker inspect -f '{{range .Mounts}}{{if eq .Destination \"/home/deno/functions\"}}{{.Source}}{{end}}{{end}}' $container")
[[ -n "$dir" ]] || { echo "functions folder not found on $container" >&2; exit 1; }

for f in _shared notify-partner-period notify-partner-ping; do
  rsync -a --delete --exclude README.md "supabase/functions/$f/" "$host:$dir/$f/"
done
ssh "$host" "docker restart $container" >/dev/null
echo "deployed _shared, notify-partner-period, notify-partner-ping to $container"
