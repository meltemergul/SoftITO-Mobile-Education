-- 005_realtime.sql: Supabase Realtime yayınına tabloları ekleme

alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.price_cache;
