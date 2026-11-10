# SQL dry run

Runs every migration on a throwaway Postgres, then checks the Nous tab
behaviour (pairing sets the start date, pings are limited to one every 30
seconds and kept without history, only the couple can read them, leaving the
couple deletes everything). Nothing here touches the real project.

```bash
docker run -d --name nd-sqldry -e POSTGRES_PASSWORD=dry -e POSTGRES_DB=nd postgres:16
for f in supabase/tests/00_supabase_stubs.sql supabase/migrations/*.sql; do
  docker exec -i nd-sqldry psql -U postgres -d nd -v ON_ERROR_STOP=1 -q < "$f" || break
done
docker exec -i nd-sqldry psql -U postgres -d nd -q -t -A < supabase/tests/10_nous_tab_scenario.sql
docker rm -f nd-sqldry
```

`00_supabase_stubs.sql` stands in for what Supabase provides (`auth.uid()`,
`auth.users`, `storage`, the `supabase_realtime` publication, the
`authenticated` role). Every scenario check prints a line; any failure stops
the script with an error.
