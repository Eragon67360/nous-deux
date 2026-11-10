# SQL dry run

Runs every migration on a throwaway Postgres, then checks the Nous tab
behaviour (pairing sets the start date, pings are limited to one every 30
seconds and kept without history, only the couple can read them, leaving the
couple deletes everything) and the shared lists (both partners can add,
tick and clear; another couple sees nothing and cannot write; authors
cannot be forged; signed-out callers get nothing; a list outlives its
creator's deleted account, minus what they wrote). Nothing here touches the
real project.

`30_push_webhooks_scenario.sql` checks the push triggers: each write calls the
right internal function with the shared secret, nothing is sent without it,
and signed-in users can't call pg_net themselves. `00_supabase_stubs.sql`
replaces pg_net's `net.http_post` with a recorder for this.

```bash
docker run -d --name nd-sqldry -e POSTGRES_PASSWORD=dry -e POSTGRES_DB=nd postgres:16
for f in supabase/tests/00_supabase_stubs.sql supabase/migrations/*.sql; do
  docker exec -i nd-sqldry psql -U postgres -d nd -v ON_ERROR_STOP=1 -q < "$f" || break
done
for s in supabase/tests/[1-9]*_scenario.sql; do
  docker exec -i nd-sqldry psql -U postgres -d nd -q -t -A < "$s"
done
docker rm -f nd-sqldry
```

`00_supabase_stubs.sql` stands in for what Supabase provides (`auth.uid()`,
`auth.users`, `storage`, the `supabase_realtime` publication, the
`authenticated` role). Every scenario check prints a line; any failure stops
the script with an error.
