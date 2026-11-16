\set ON_ERROR_STOP 1
-- Own words (migration 20261116600000): little notes and check-in states a
-- person writes. Rémi and Inès are a couple; Zoé waits for a partner with
-- her own invite. Every check prints a line; a wrong result raises.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000091a1'),('00000000-0000-0000-0000-0000000091b1'),('00000000-0000-0000-0000-0000000091c1');
INSERT INTO public.profiles (id, username, language) VALUES
 ('00000000-0000-0000-0000-0000000091a1','Rémi','fr'),
 ('00000000-0000-0000-0000-0000000091b1','Inès','en'),
 ('00000000-0000-0000-0000-0000000091c1','Zoé','fr');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('91000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000091a1','00000000-0000-0000-0000-0000000091b1'),
 ('91000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000091c1',NULL);

CREATE FUNCTION pg_temp.expect(label text, ok boolean) RETURNS text
LANGUAGE plpgsql AS $$
BEGIN
  IF NOT coalesce(ok, false) THEN RAISE EXCEPTION '%: failed', label; END IF;
  RETURN label || ': ok';
END $$;

-- Runs a statement as the current caller and wants it refused, with this
-- message (invalid_text, cooldown…) or this SQLSTATE (42501, 23514).
CREATE FUNCTION pg_temp.refused(label text, stmt text, wanted text) RETURNS text
LANGUAGE plpgsql AS $$
DECLARE
  _state text;
  _msg text;
BEGIN
  BEGIN
    EXECUTE stmt;
  EXCEPTION WHEN OTHERS THEN
    _state := SQLSTATE;
    _msg := SQLERRM;
  END;
  IF _state IS NULL THEN RAISE EXCEPTION '%: went through', label; END IF;
  IF wanted NOT IN (_state, _msg) THEN
    RAISE EXCEPTION '%: got % (%), wanted %', label, _msg, _state, wanted;
  END IF;
  RETURN label || ': refused (' || _msg || ')';
END $$;

-- Lets Rémi send again without waiting 30 seconds.
CREATE PROCEDURE pg_temp.wait_30s()
LANGUAGE sql AS $$
  UPDATE public.couple_pings SET sent_at = NOW() - INTERVAL '31 seconds'
  WHERE sender_id = '00000000-0000-0000-0000-0000000091a1'
$$;

SET app.settings.push_webhook_secret = 'dry-run-secret';

-- ---------------------------------------------------------------------------
-- Little notes
-- ---------------------------------------------------------------------------
SELECT pg_temp.expect('one send_ping, with p_text optional',
  (SELECT string_agg(pg_get_function_identity_arguments(oid) || ' / ' || pg_get_function_arguments(oid), ', ')
   FROM pg_proc WHERE proname = 'send_ping' AND pronamespace = 'public'::regnamespace)
  = 'p_kind text, p_text text / p_kind text, p_text text DEFAULT NULL::text');
SELECT pg_temp.expect('signed-in callers may call send_ping, signed-out ones may not',
  has_function_privilege('authenticated', 'public.send_ping(text, text)', 'EXECUTE')
  AND NOT has_function_privilege('anon', 'public.send_ping(text, text)', 'EXECUTE'));

-- Rémi writes a note; the spaces around it go.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
SELECT pg_temp.expect('a written note comes back trimmed',
  (SELECT kind = 'custom' AND text = 'Bon courage pour ton oral'
   FROM public.send_ping('custom', '  Bon courage pour ton oral  ')));
RESET ROLE;
SELECT pg_temp.expect('it calls notify-partner-ping like any note',
  EXISTS (SELECT 1 FROM net.http_calls
          WHERE url LIKE '%/notify-partner-ping'
            AND body->'record'->>'sender_id' = '00000000-0000-0000-0000-0000000091a1'
            AND body->'record'->>'kind' = 'custom'));

-- Inès reads it with its text; Zoé and signed-out callers read nothing.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091b1';
SELECT pg_temp.expect('Inès reads Rémi''s note and its text',
  (SELECT kind = 'custom' AND text = 'Bon courage pour ton oral'
   FROM public.couple_pings WHERE sender_id = '00000000-0000-0000-0000-0000000091a1'));
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091c1';
SELECT pg_temp.expect('Zoé reads no note', (SELECT count(*) FROM public.couple_pings) = 0);
SELECT pg_temp.refused('Zoé, waiting for a partner, cannot send a written note',
  $q$SELECT public.send_ping('custom', 'Coucou')$q$, 'not_paired');
RESET ROLE;
SET ROLE anon;
SELECT pg_temp.refused('signed-out callers cannot read notes',
  'SELECT count(*) FROM public.couple_pings', '42501');
SELECT pg_temp.refused('signed-out callers cannot send one',
  $q$SELECT public.send_ping('custom', 'Coucou')$q$, '42501');
RESET ROLE;

-- The 30 seconds count across kinds, both ways.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
SELECT pg_temp.refused('a preset note right after a written one',
  $q$SELECT public.send_ping('kiss')$q$, 'cooldown');
SELECT pg_temp.expect('the written note stays as it was',
  (SELECT kind = 'custom' AND text = 'Bon courage pour ton oral'
   FROM public.couple_pings WHERE sender_id = auth.uid()));
RESET ROLE;
CALL pg_temp.wait_30s();
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
-- A preset note sent with a text keeps no text, and replaces the written one.
SELECT pg_temp.expect('a preset note sent with a text stores none',
  (SELECT kind = 'kiss' AND text IS NULL FROM public.send_ping('kiss', 'pas stocké')));
SELECT pg_temp.expect('still one note per person, its text gone',
  (SELECT count(*) = 1 AND bool_and(kind = 'kiss' AND text IS NULL)
   FROM public.couple_pings WHERE sender_id = auth.uid()));
SELECT pg_temp.refused('a written note right after a preset one',
  $q$SELECT public.send_ping('custom', 'Coucou')$q$, 'cooldown');
RESET ROLE;
CALL pg_temp.wait_30s();

-- Texts that are not one short line are refused.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
SELECT pg_temp.refused('41 characters',
  format('SELECT public.send_ping(%L, %L)', 'custom', repeat('a', 41)), 'invalid_text');
SELECT pg_temp.refused('an empty text',
  $q$SELECT public.send_ping('custom', '')$q$, 'invalid_text');
SELECT pg_temp.refused('only spaces',
  $q$SELECT public.send_ping('custom', '     ')$q$, 'invalid_text');
SELECT pg_temp.refused('a line break',
  format('SELECT public.send_ping(%L, %L)', 'custom', E'À demain\nbisous'), 'invalid_text');
SELECT pg_temp.refused('a tab',
  format('SELECT public.send_ping(%L, %L)', 'custom', E'À demain\tbisous'), 'invalid_text');
SELECT pg_temp.refused('a written note without a text',
  $q$SELECT public.send_ping('custom')$q$, 'invalid_text');
SELECT pg_temp.refused('an unknown kind with a text',
  $q$SELECT public.send_ping('hello', 'Coucou')$q$, 'invalid_kind');
SELECT pg_temp.expect('refused texts change nothing',
  (SELECT kind = 'kiss' AND text IS NULL FROM public.couple_pings WHERE sender_id = auth.uid()));
-- 40 characters is fine, counted in characters (é is two bytes), spaces
-- around not counted.
SELECT pg_temp.expect('40 characters go through',
  (SELECT text = repeat('é', 40) FROM public.send_ping('custom', ' ' || repeat('é', 40) || ' ')));
RESET ROLE;
CALL pg_temp.wait_30s();

-- Older builds send p_kind only, positionally or by name as PostgREST does.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
SELECT pg_temp.expect('the one-argument call still works',
  (SELECT kind = 'good_night' AND text IS NULL FROM public.send_ping('good_night')));
RESET ROLE;
CALL pg_temp.wait_30s();
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
SELECT pg_temp.expect('and by name, as PostgREST calls it',
  (SELECT kind = 'miss_you' AND text IS NULL FROM public.send_ping(p_kind => 'miss_you')));

-- Clients still cannot write the table themselves.
SELECT pg_temp.refused('a direct insert of a written note',
  $q$INSERT INTO public.couple_pings (couple_id, sender_id, kind, text)
     VALUES ('91000000-0000-0000-0000-0000000000a1', auth.uid(), 'custom', 'Coucou')$q$, '42501');
SELECT pg_temp.refused('a direct edit of the text',
  $q$UPDATE public.couple_pings SET kind = 'custom', text = 'Coucou'$q$, '42501');
SELECT pg_temp.refused('a direct delete',
  'DELETE FROM public.couple_pings', '42501');
RESET ROLE;

-- The table holds the same rules for anyone who writes it, owner included.
SELECT pg_temp.refused('the table refuses a written note without a text',
  $q$UPDATE public.couple_pings SET kind = 'custom' WHERE sender_id = '00000000-0000-0000-0000-0000000091a1'$q$, '23514');
SELECT pg_temp.refused('the table refuses a text on a preset note',
  $q$UPDATE public.couple_pings SET text = 'Coucou' WHERE sender_id = '00000000-0000-0000-0000-0000000091a1'$q$, '23514');
SELECT pg_temp.refused('the table refuses spaces around the text',
  $q$UPDATE public.couple_pings SET kind = 'custom', text = ' Coucou' WHERE sender_id = '00000000-0000-0000-0000-0000000091a1'$q$, '23514');
SELECT pg_temp.refused('the table refuses 41 characters',
  format('UPDATE public.couple_pings SET kind = %L, text = %L WHERE sender_id = %L',
         'custom', repeat('a', 41), '00000000-0000-0000-0000-0000000091a1'), '23514');
SELECT pg_temp.refused('the table refuses a line break',
  format('UPDATE public.couple_pings SET kind = %L, text = %L WHERE sender_id = %L',
         'custom', E'À demain\nbisous', '00000000-0000-0000-0000-0000000091a1'), '23514');

-- ---------------------------------------------------------------------------
-- Daily check-ins with states Inès writes herself
-- ---------------------------------------------------------------------------
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091b1';
UPDATE public.profiles SET tracks_cycle = TRUE WHERE id = auth.uid();
-- The way the app saves the day: one upsert per person and day.
INSERT INTO public.cycle_checkins (user_id, couple_id, day, symptoms, mood)
VALUES (auth.uid(), '91000000-0000-0000-0000-0000000000a1', '2026-11-17', '{cramps,"Besoin de chocolat"}', 'tired')
ON CONFLICT (user_id, day) DO UPDATE SET symptoms = EXCLUDED.symptoms, mood = EXCLUDED.mood;
SELECT pg_temp.expect('a check-in with a written state saves',
  (SELECT symptoms = '{cramps,"Besoin de chocolat"}' FROM public.cycle_checkins WHERE user_id = auth.uid()));
-- 12 states, and 30 characters (counted in characters), are fine.
INSERT INTO public.cycle_checkins (user_id, couple_id, day, symptoms)
VALUES (auth.uid(), '91000000-0000-0000-0000-0000000000a1', '2026-11-16',
  ARRAY['cramps','headache','acne','pain','bloating','Fatiguée','Envie de câlins','Mal au dos',
        'Besoin de chocolat','Ventre gonflé','Nuit courte', repeat('é', 30)])
ON CONFLICT (user_id, day) DO UPDATE SET symptoms = EXCLUDED.symptoms;
SELECT pg_temp.expect('12 states of up to 30 characters save',
  (SELECT cardinality(symptoms) = 12 FROM public.cycle_checkins WHERE user_id = auth.uid() AND day = '2026-11-16'));

-- What does not fit is refused, on insert and on update.
SELECT pg_temp.refused('a state of 31 characters',
  format('INSERT INTO public.cycle_checkins (user_id, couple_id, day, symptoms) VALUES (auth.uid(), %L, %L, ARRAY[%L])',
         '91000000-0000-0000-0000-0000000000a1', '2026-11-15', repeat('a', 31)), '23514');
SELECT pg_temp.refused('13 states',
  format('INSERT INTO public.cycle_checkins (user_id, couple_id, day, symptoms) VALUES (auth.uid(), %L, %L, %L::text[])',
         '91000000-0000-0000-0000-0000000000a1', '2026-11-15',
         (SELECT array_agg('état ' || i) FROM generate_series(1, 13) AS i)), '23514');
SELECT pg_temp.refused('a state with a line break',
  format('UPDATE public.cycle_checkins SET symptoms = ARRAY[%L, %L] WHERE day = %L',
         'cramps', E'Besoin de\nchocolat', '2026-11-17'), '23514');
SELECT pg_temp.refused('a state with spaces around',
  $q$UPDATE public.cycle_checkins SET symptoms = '{" Besoin de chocolat"}' WHERE day = '2026-11-17'$q$, '23514');
SELECT pg_temp.refused('an empty state',
  $q$UPDATE public.cycle_checkins SET symptoms = '{cramps,""}' WHERE day = '2026-11-17'$q$, '23514');
SELECT pg_temp.refused('a null state',
  $q$UPDATE public.cycle_checkins SET symptoms = ARRAY['cramps', NULL] WHERE day = '2026-11-17'$q$, '23514');
SELECT pg_temp.expect('refused states change nothing',
  (SELECT symptoms = '{cramps,"Besoin de chocolat"}' FROM public.cycle_checkins WHERE day = '2026-11-17'));
RESET ROLE;

-- Rémi reads her written state while she shares how she feels, not after.
SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
SELECT pg_temp.expect('Rémi reads her written state while it is shared',
  (SELECT symptoms = '{cramps,"Besoin de chocolat"}' FROM public.cycle_checkins
   WHERE user_id = '00000000-0000-0000-0000-0000000091b1' AND day = '2026-11-17'));
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091c1';
SELECT pg_temp.expect('Zoé reads none of her check-ins', (SELECT count(*) FROM public.cycle_checkins) = 0);
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091b1';
UPDATE public.profiles SET share_checkins = FALSE WHERE id = auth.uid();
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000091a1';
SELECT pg_temp.expect('and nothing once she stops sharing it',
  (SELECT count(*) FROM public.cycle_checkins WHERE user_id = '00000000-0000-0000-0000-0000000091b1') = 0);
RESET ROLE;

RESET app.settings.push_webhook_secret;
