-- Add onboarding completion timestamp (null = first-time user, set = account setup done)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_completed_at TIMESTAMPTZ;

-- Backfill existing profiles so current users are not sent to onboarding
UPDATE public.profiles
SET onboarding_completed_at = created_at
WHERE onboarding_completed_at IS NULL;

COMMENT ON COLUMN public.profiles.onboarding_completed_at IS 'Set when user completes account setup (display name, gender, language).';
