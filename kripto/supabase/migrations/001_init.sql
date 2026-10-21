-- 001_init.sql: Temel Tablolar, İndeksler ve Tetikleyiciler

create extension if not exists "pgcrypto";

-- Yardımcı: updated_at otomatik güncelleme fonksiyonu
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- 1. PROFILES (Kullanıcı profilleri ve tercihleri)
create table public.profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  display_name     text,
  default_currency text not null default 'USD' check (default_currency in ('USD','TRY')),
  refresh_seconds  int  not null default 60 check (refresh_seconds in (30,60,300)),
  theme            text not null default 'dark' check (theme in ('dark','light')),
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create trigger trg_profiles_updated
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Kayıt olunca otomatik profil oluşturan tetikleyici
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, split_part(new.email, '@', 1));
  return new;
end $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- 2. ASSETS (Ortak coin kataloğu - CoinGecko eşlemesi)
create table public.assets (
  id              uuid primary key default gen_random_uuid(),
  symbol          text not null,
  name            text not null,
  coingecko_id    text not null unique,
  image_url       text,
  market_cap_rank int,
  created_at      timestamptz not null default now()
);

create index idx_assets_symbol on public.assets (upper(symbol));

-- 3. TRANSACTIONS (Asıl tablo: Alış ve Satış işlemleri)
create table public.transactions (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.profiles(id) on delete cascade,
  asset_id       uuid not null references public.assets(id),
  type           text not null check (type in ('BUY','SELL')),
  quantity       numeric(38,18) not null check (quantity > 0),
  price          numeric(38,18) not null check (price > 0),
  price_currency text not null check (price_currency in ('USD','TRY')),
  fee            numeric(38,18) not null default 0 check (fee >= 0),
  fee_currency   text check (fee_currency in ('USD','TRY')),
  executed_at    timestamptz not null,
  source         text not null default 'MANUAL' check (source in ('MANUAL','CSV')),
  note           text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  deleted_at     timestamptz
);

create trigger trg_transactions_updated
  before update on public.transactions
  for each row execute function public.set_updated_at();

create index idx_tx_user_asset_time
  on public.transactions (user_id, asset_id, executed_at)
  where deleted_at is null;

create index idx_tx_user_time
  on public.transactions (user_id, executed_at desc)
  where deleted_at is null;

-- 4. PRICE_CACHE (Ortak güncel fiyat önbelleği)
create table public.price_cache (
  asset_id    uuid not null references public.assets(id) on delete cascade,
  currency    text not null check (currency in ('USD','TRY')),
  price       numeric(38,18) not null,
  change_24h  numeric,
  fetched_at  timestamptz not null default now(),
  primary key (asset_id, currency)
);
