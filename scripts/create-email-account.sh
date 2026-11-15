#!/usr/bin/env bash
# Creates an email and password account, already confirmed, on the
# self-hosted auth server: for store reviewers and test accounts. Nobody can
# sign up with an email (migration 20261115100000), so this is the only way
# such an account exists. No email is sent; the address needs no mailbox.
#
# You type the password here. It is never shown, never passed as a command
# argument, and travels only in the HTTPS request to the auth admin API.
# Keep it in the Proton Pass vault "Nous Deux".
#
# Usage: scripts/create-email-account.sh root@<server> <email>
set -euo pipefail
target="${1:?usage: $0 user@server email}"
email="${2:?usage: $0 user@server email}"
api="${NOUS_DEUX_API:-https://api.nous-deux.app}"
command -v jq >/dev/null || { echo "jq is needed" >&2; exit 1; }

read -rsp "Password for $email (12 characters or more): " pw; echo
read -rsp "Same password again: " pw2; echo
[[ "$pw" == "$pw2" ]] || { echo "The two passwords differ." >&2; exit 1; }
(( ${#pw} >= 12 )) || { echo "Use 12 characters or more." >&2; exit 1; }

# The service role key stays in this process: never printed or saved.
key=$(ssh "$target" "docker exec \$(docker ps --format '{{.Names}}' | grep -E '^supabase-kong' | head -n1) printenv SUPABASE_SERVICE_KEY")
[[ -n "$key" ]] || { echo "no service key found on $target" >&2; exit 1; }

response=$(
  EMAIL="$email" PASSWORD="$pw" \
    jq -n '{email: env.EMAIL, password: env.PASSWORD, email_confirm: true}' |
    curl -sS -w '\n%{http_code}' -X POST "$api/auth/v1/admin/users" \
      -H 'Content-Type: application/json' \
      -H @<(printf 'apikey: %s\nAuthorization: Bearer %s\n' "$key" "$key") \
      --data-binary @-
)
status=${response##*$'\n'}
body=${response%$'\n'*}

if [[ "$status" == 200 || "$status" == 201 ]]; then
  echo "created $email ($(jq -r .id <<<"$body"))"
else
  echo "not created ($status): $(jq -r '.msg // .message // .error_description // .' <<<"$body")" >&2
  exit 1
fi
