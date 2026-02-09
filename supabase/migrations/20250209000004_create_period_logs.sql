-- Period tracking logs (user-owned, visible to partner in same couple)
CREATE TABLE public.period_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE,
  mood TEXT,
  symptoms TEXT[] DEFAULT '{}',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT period_dates_order CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE INDEX idx_period_logs_user_id ON public.period_logs(user_id);
CREATE INDEX idx_period_logs_couple_id ON public.period_logs(couple_id);
CREATE INDEX idx_period_logs_start_date ON public.period_logs(start_date);

COMMENT ON TABLE public.period_logs IS 'Period cycle logs; owner can CRUD, partner can read.';
