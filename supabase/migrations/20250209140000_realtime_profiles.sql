-- Enable Realtime for profiles so the app can react when partner_id is set (partner joined).
ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
