#!/usr/bin/env bash
# Sends a message from the team to everyone who uses the app
# (docs/NOUVEAUTES.md, announcements/README.md). The database calls the
# send-announcement function with pg_net and the push secret it keeps, so the
# secret never leaves the server.
#
# Usage: scripts/announce.sh <user@server|local> announcements/<slug>.json --test
#        scripts/announce.sh <user@server|local> announcements/<slug>.json
# --test sends to the team's accounts only and records nothing in Nouveautés.
# Without it: a preview, then ENVOYER to send to everyone. Everyone needs a
# test of the same text first, and a file is sent once.
set -euo pipefail
usage="usage: $0 user@server|local announcements/<slug>.json [--test]"
target="${1:?$usage}"
file="${2:?$usage}"
mode="${3:-}"
[[ -z "$mode" || "$mode" == --test ]] || { echo "$usage" >&2; exit 2; }
cd "$(dirname "$0")/.."

die() { echo "$*" >&2; exit 1; }

[[ -f "$file" ]] || die "Fichier introuvable : $file"
slug=$(basename "$file" .json)
content=$(jq -ce 'if type == "object" then . else error("pas un objet") end' "$file" 2>/dev/null) ||
  die "JSON illisible : $file"
# The text goes into the SQL between $announce$ quotes.
[[ "$content" != *'$announce$'* ]] || die "Le texte ne peut pas contenir \$announce\$."

run() { if [[ "$target" == local ]]; then bash -c "$1"; else ssh "$target" "$1"; fi; }

db=$(run "docker ps --format '{{.Names}}' | grep -E '(^|-)supabase-db(-|$)' | head -n1")
[[ -n "$db" ]] || die "Pas de conteneur supabase-db sur $target"
psql_in="docker exec -i $db psql -U postgres -d postgres -v ON_ERROR_STOP=1 -q -t -A"

# What a refusal from the function means, in words.
explain() {
  case "$1" in
    bad_slug) echo "Nom de fichier refusé : AAAA-MM-JJ-mots.json (minuscules, chiffres, tirets)." ;;
    missing_language:*) echo "Langue manquante : ${1#*:}. Chaque message existe dans toutes les langues de l'app." ;;
    unknown_language:*) echo "Langue inconnue : ${1#*:}." ;;
    empty:*) echo "Titre ou texte vide : ${1#*:}." ;;
    title_too_long:*) echo "Titre trop long (60 caractères au plus) : ${1#*:}." ;;
    body_too_long:*) echo "Texte trop long (280 caractères au plus) : ${1#*:}." ;;
    already_sent) echo "Déjà envoyé à tout le monde : un fichier ne part qu'une fois." ;;
    not_tested) echo "Pas encore essayé : lancez d'abord $0 $target $file --test" ;;
    changed_since_test) echo "Modifié depuis l'essai : relancez $0 $target $file --test" ;;
    no_testers) echo "Aucun compte d'essai : ajoutez-en un dans la table announcement_testers." ;;
    *) echo "Refusé par le serveur : $1 (voir docker logs du conteneur des fonctions)." ;;
  esac
}

# Calls the function with an action and prints its JSON answer.
call() {
  local payload id answer
  payload=$(jq -cn --arg action "$1" --arg slug "$slug" --argjson content "$content" \
    '{action: $action, slug: $slug, content: $content}')
  id=$(run "$psql_in" <<SQL
SELECT net.http_post(
  url := 'http://supabase-edge-functions:9000/send-announcement',
  body := \$announce\$$payload\$announce\$::jsonb,
  headers := jsonb_build_object(
    'Content-Type', 'application/json',
    'x-webhook-secret', private.push_webhook_secret()
  ),
  timeout_milliseconds := 120000
);
SQL
)
  [[ "$id" =~ ^[0-9]+$ ]] || die "La base n'a pas pu appeler la fonction."
  # pg_net answers asynchronously: wait for its row (a send can take a while).
  for _ in $(seq 1 130); do
    sleep 1
    answer=$(run "$psql_in" <<SQL
SELECT json_build_object('status', status_code, 'content', content, 'error', error_msg)
FROM net._http_response WHERE id = $id;
SQL
)
    [[ -n "$answer" ]] && break
  done
  [[ -n "$answer" ]] || die "Pas de réponse de la fonction après 130 s."
  case "$(jq -r '.status // "none"' <<<"$answer")" in
    200) jq -c '.content | fromjson' <<<"$answer" ;;
    403) die "Secret refusé : la base et les fonctions n'ont pas le même." ;;
    404) die "Fonction introuvable : send-announcement manque dans le routeur (infra/supabase/compose.yml)." ;;
    none) die "Appel impossible : $(jq -r '.error // "?"' <<<"$answer")" ;;
    *) die "Erreur $(jq -r '.status' <<<"$answer") de la fonction (voir docker logs du conteneur des fonctions)." ;;
  esac
}

# Stops with the function's reason when it refused.
check() {
  if [[ "$(jq -r '.ok' <<<"$1")" != true ]]; then die "$(explain "$(jq -r '.error' <<<"$1")")"; fi
}

if [[ "$mode" == --test ]]; then
  answer=$(call test); check "$answer"
  echo "Envoi test aux comptes de l'équipe : envoyés $(jq -r .sent <<<"$answer"), échecs $(jq -r .failed <<<"$answer")."
  echo "Rien n'est enregistré dans Nouveautés."
  exit 0
fi

answer=$(call preview); check "$answer"
jq -r 'to_entries[] | "\(.key)  \(.value.title)\n    \(.value.body | if length > 60 then .[0:59] + "…" else . end)"' <<<"$content"
echo "Chacun reçoit la langue choisie dans l'app."
echo "Destinataires : $(jq -r .recipients <<<"$answer") comptes avec push, $(jq -r .opted_out <<<"$answer") ont coupé « Nouveautés »."
read -r -p "Tapez ENVOYER pour envoyer à tout le monde : " confirm || confirm=""
[[ "$confirm" == ENVOYER ]] || die "Rien n'est parti."

echo "Enregistré dans Nouveautés · envoi…"
answer=$(call send); check "$answer"
echo "Envoyés : $(jq -r .sent <<<"$answer") · échecs : $(jq -r .failed <<<"$answer") · jetons périmés retirés : $(jq -r .stale_removed <<<"$answer")"
