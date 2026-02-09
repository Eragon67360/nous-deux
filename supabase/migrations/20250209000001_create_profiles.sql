-- Profiles table (extends auth.users)
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT,
  gender TEXT CHECK (gender IN ('woman', 'man')),
  partner_id UUID REFERENCES public.profiles(id),
  language TEXT NOT NULL DEFAULT 'fr',
  fcm_token TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_profiles_partner_id ON public.profiles(partner_id);
CREATE INDEX idx_profiles_language ON public.profiles(language);

COMMENT ON TABLE public.profiles IS 'User profiles; one row per auth user.';
