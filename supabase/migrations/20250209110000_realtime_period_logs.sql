-- Enable Realtime for period_logs so partner sees new/updated logs
ALTER PUBLICATION supabase_realtime ADD TABLE public.period_logs;
