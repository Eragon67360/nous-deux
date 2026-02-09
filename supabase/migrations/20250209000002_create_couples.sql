-- Couples table: links two users via pairing
CREATE TABLE public.couples (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  user2_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  pairing_code TEXT UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT couples_users_different CHECK (user1_id != user2_id)
);

CREATE UNIQUE INDEX idx_couples_pairing_code ON public.couples(pairing_code) WHERE pairing_code IS NOT NULL;
CREATE INDEX idx_couples_user1 ON public.couples(user1_id);
CREATE INDEX idx_couples_user2 ON public.couples(user2_id);

COMMENT ON TABLE public.couples IS 'Couple pairing; user1 creates, user2 joins by code.';
