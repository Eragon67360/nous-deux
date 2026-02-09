-- Real-time location sharing only (no history; single row per user, updated in place)
CREATE TABLE public.location_sharing (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_sharing BOOLEAN NOT NULL DEFAULT false,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_location_sharing_couple_id ON public.location_sharing(couple_id);

COMMENT ON TABLE public.location_sharing IS 'Current location only; no history stored.';
