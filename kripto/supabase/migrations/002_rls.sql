-- 002_rls.sql: Row Level Security (RLS) Güvenlik Politikaları

alter table public.profiles      enable row level security;
alter table public.transactions  enable row level security;
alter table public.assets        enable row level security;
alter table public.price_cache   enable row level security;

-- PROFILES POLİTİKALARI: Kullanıcı yalnızca kendi profilini okuyabilir ve güncelleyebilir
create policy "profiles_select_own" on public.profiles
  for select to authenticated using (id = auth.uid());

create policy "profiles_update_own" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- TRANSACTIONS POLİTİKALARI: Yalnızca kullanıcının kendi işlemleri
create policy "tx_select_own" on public.transactions
  for select to authenticated using (user_id = auth.uid());

create policy "tx_insert_own" on public.transactions
  for insert to authenticated with check (user_id = auth.uid());

create policy "tx_update_own" on public.transactions
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "tx_delete_own" on public.transactions
  for delete to authenticated using (user_id = auth.uid());

-- ASSETS VE PRICE_CACHE: Giriş yapan tüm kullanıcılar okuyabilir, istemciden doğrudan yazma kapalıdır
-- (Yazma işlemleri yalnızca Edge Function / service_role üzerinden yürütülür)
create policy "assets_read" on public.assets
  for select to authenticated using (true);

create policy "price_cache_read" on public.price_cache
  for select to authenticated using (true);
