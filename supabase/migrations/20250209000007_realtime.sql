-- Enable Realtime for calendar_events and location_sharing
ALTER PUBLICATION supabase_realtime ADD TABLE public.calendar_events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.location_sharing;
