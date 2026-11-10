-- Shared lists (groceries, to-dos, ideas): several named lists per couple,
-- live on both phones. Deleted with the couple (leave_couple).

CREATE TABLE public.shared_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
  name TEXT NOT NULL CHECK (char_length(btrim(name)) BETWEEN 1 AND 60),
  icon TEXT NOT NULL DEFAULT 'list'
    CHECK (icon IN ('list', 'cart', 'star', 'home', 'gift')),
  created_by UUID NOT NULL DEFAULT auth.uid()
    REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shared_lists_couple_id ON public.shared_lists(couple_id);

CREATE TABLE public.shared_list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES public.shared_lists(id) ON DELETE CASCADE,
  -- Copied from the list by a trigger: lets RLS and Realtime filter by couple.
  couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
  text TEXT NOT NULL CHECK (char_length(btrim(text)) BETWEEN 1 AND 200),
  checked BOOLEAN NOT NULL DEFAULT false,
  added_by UUID NOT NULL DEFAULT auth.uid()
    REFERENCES public.profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_shared_list_items_list_id ON public.shared_list_items(list_id);
CREATE INDEX idx_shared_list_items_couple_id ON public.shared_list_items(couple_id);

COMMENT ON TABLE public.shared_lists IS 'Named lists a couple shares.';
COMMENT ON TABLE public.shared_list_items IS 'Items of a shared list; who added each one is kept.';

-- An item always belongs to its list's couple, and its author is the caller:
-- the client cannot pick either.
CREATE OR REPLACE FUNCTION public.shared_list_items_fill()
RETURNS TRIGGER AS $$
BEGIN
  SELECT couple_id INTO NEW.couple_id FROM public.shared_lists WHERE id = NEW.list_id;
  IF TG_OP = 'INSERT' THEN
    NEW.added_by := COALESCE(auth.uid(), NEW.added_by);
  ELSE
    NEW.added_by := OLD.added_by;
    NEW.list_id := OLD.list_id;
    NEW.couple_id := OLD.couple_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE TRIGGER shared_list_items_fill
  BEFORE INSERT OR UPDATE ON public.shared_list_items
  FOR EACH ROW EXECUTE FUNCTION public.shared_list_items_fill();

CREATE OR REPLACE FUNCTION public.shared_lists_keep_owner()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_by := COALESCE(auth.uid(), NEW.created_by);
  ELSE
    NEW.created_by := OLD.created_by;
    NEW.couple_id := OLD.couple_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER shared_lists_keep_owner
  BEFORE INSERT OR UPDATE ON public.shared_lists
  FOR EACH ROW EXECUTE FUNCTION public.shared_lists_keep_owner();

CREATE TRIGGER shared_lists_updated_at
  BEFORE UPDATE ON public.shared_lists
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
CREATE TRIGGER shared_list_items_updated_at
  BEFORE UPDATE ON public.shared_list_items
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.shared_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shared_list_items ENABLE ROW LEVEL SECURITY;

-- Both partners can do everything with their couple's lists, and only once
-- they are actually paired.
CREATE POLICY "Couple members manage their lists"
  ON public.shared_lists FOR ALL
  USING (couple_id IN (SELECT public.my_couple_ids()))
  WITH CHECK (
    couple_id IN (
      SELECT id FROM public.couples
      WHERE (user1_id = auth.uid() OR user2_id = auth.uid())
        AND user2_id IS NOT NULL
    )
  );

CREATE POLICY "Couple members manage their list items"
  ON public.shared_list_items FOR ALL
  USING (couple_id IN (SELECT public.my_couple_ids()))
  WITH CHECK (couple_id IN (SELECT public.my_couple_ids()));

ALTER PUBLICATION supabase_realtime ADD TABLE public.shared_lists;
ALTER PUBLICATION supabase_realtime ADD TABLE public.shared_list_items;
