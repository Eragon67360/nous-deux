\set ON_ERROR_STOP 1
-- A and B are a couple, C and D another one.
INSERT INTO auth.users (id) VALUES
 ('00000000-0000-0000-0000-0000000000a1'),('00000000-0000-0000-0000-0000000000b1'),
 ('00000000-0000-0000-0000-0000000000c1'),('00000000-0000-0000-0000-0000000000d1');
INSERT INTO public.profiles (id, username) VALUES
 ('00000000-0000-0000-0000-0000000000a1','Alex'),('00000000-0000-0000-0000-0000000000b1','Camille'),
 ('00000000-0000-0000-0000-0000000000c1','Sam'),('00000000-0000-0000-0000-0000000000d1','Noa');
INSERT INTO public.couples (id, user1_id, user2_id) VALUES
 ('22222222-2222-2222-2222-222222222222','00000000-0000-0000-0000-0000000000a1','00000000-0000-0000-0000-0000000000b1'),
 ('33333333-3333-3333-3333-333333333333','00000000-0000-0000-0000-0000000000c1','00000000-0000-0000-0000-0000000000d1');

SET ROLE authenticated;
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a1';
INSERT INTO public.shared_lists (id, couple_id, name, icon) VALUES
 ('44444444-4444-4444-4444-444444444444','22222222-2222-2222-2222-222222222222','Courses','cart');
-- added_by is forced to the caller even if the client sends someone else.
INSERT INTO public.shared_list_items (list_id, couple_id, text, added_by) VALUES
 ('44444444-4444-4444-4444-444444444444','22222222-2222-2222-2222-222222222222','Tomates','00000000-0000-0000-0000-0000000000b1');
SELECT 'author kept as caller: ' || (added_by = '00000000-0000-0000-0000-0000000000a1') FROM public.shared_list_items;

SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000b1';
INSERT INTO public.shared_list_items (list_id, couple_id, text) VALUES
 ('44444444-4444-4444-4444-444444444444','22222222-2222-2222-2222-222222222222','Pain');
UPDATE public.shared_list_items SET checked = true WHERE text = 'Tomates';
SELECT 'B sees items: ' || count(*) || ', checked: ' || count(*) FILTER (WHERE checked) FROM public.shared_list_items;
-- Clear checked.
DELETE FROM public.shared_list_items WHERE checked;
SELECT 'after clearing checked: ' || count(*) FROM public.shared_list_items;

-- C (other couple) sees nothing and cannot add to A and B's list,
-- even by sending their own couple_id.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000c1';
SELECT 'C sees lists: ' || count(*) FROM public.shared_lists;
SELECT 'C sees items: ' || count(*) FROM public.shared_list_items;
DO $$ BEGIN
  INSERT INTO public.shared_list_items (list_id, couple_id, text) VALUES
   ('44444444-4444-4444-4444-444444444444','33333333-3333-3333-3333-333333333333','Intrus');
  RAISE EXCEPTION 'expected RLS refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'foreign list insert refused by RLS';
END $$;
DO $$ BEGIN
  INSERT INTO public.shared_lists (couple_id, name) VALUES ('22222222-2222-2222-2222-222222222222','Intrus');
  RAISE EXCEPTION 'expected RLS refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'list in another couple refused by RLS';
END $$;
-- Empty names are refused.
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a1';
DO $$ BEGIN
  INSERT INTO public.shared_lists (couple_id, name) VALUES ('22222222-2222-2222-2222-222222222222','   ');
  RAISE EXCEPTION 'expected check violation';
EXCEPTION WHEN check_violation THEN RAISE NOTICE 'blank list name refused';
END $$;
-- Signed out: nothing at all.
RESET ROLE; SET ROLE anon;
DO $$ BEGIN
  PERFORM count(*) FROM public.shared_lists;
  RAISE EXCEPTION 'expected permission denied';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'anon cannot read lists';
END $$;
RESET ROLE;
SELECT 'realtime has both list tables: ' || (SELECT count(*) = 2 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename IN ('shared_lists','shared_list_items'));

-- D's account is deleted (by the admin, no session): the list D made stays
-- for C with C's items; what D wrote goes. C, now alone, can't add more.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000d1';
INSERT INTO public.shared_lists (id, couple_id, name) VALUES
 ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333','Week-end');
INSERT INTO public.shared_list_items (list_id, couple_id, text) VALUES
 ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333','Duvet');
SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000c1';
INSERT INTO public.shared_list_items (list_id, couple_id, text) VALUES
 ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333','Tente');
RESET ROLE; RESET request.jwt.claim.sub;
DELETE FROM auth.users WHERE id = '00000000-0000-0000-0000-0000000000d1';
SELECT 'list kept without creator: ' || (created_by IS NULL) FROM public.shared_lists WHERE name = 'Week-end';
SELECT 'items left: ' || string_agg(text, ',') FROM public.shared_list_items WHERE list_id = '55555555-5555-5555-5555-555555555555';
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000c1';
DO $$ BEGIN
  INSERT INTO public.shared_list_items (list_id, couple_id, text) VALUES
   ('55555555-5555-5555-5555-555555555555','33333333-3333-3333-3333-333333333333','Réchaud');
  RAISE EXCEPTION 'expected RLS refusal';
EXCEPTION WHEN insufficient_privilege THEN RAISE NOTICE 'unpaired add refused by RLS';
END $$;
RESET ROLE;

-- A leaves: their lists and items go with the couple.
SET ROLE authenticated; SET request.jwt.claim.sub = '00000000-0000-0000-0000-0000000000a1';
SELECT public.leave_couple();
RESET ROLE;
SELECT 'after A leaves, their lists=' || (SELECT count(*) FROM public.shared_lists WHERE couple_id = '22222222-2222-2222-2222-222222222222')
  || ' items=' || (SELECT count(*) FROM public.shared_list_items WHERE couple_id = '22222222-2222-2222-2222-222222222222');
