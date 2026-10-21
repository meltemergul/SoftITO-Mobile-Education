---
name: crypto-portfolio-database
description: Kripto kâr/zarar ve portföy takibi uygulamasının Supabase (PostgreSQL) veritabanını tasarlar ve değiştirir. Tablo şeması, migration, RLS güvenlik kuralları, indeksler, tetikleyiciler, Realtime, fiyat önbelleği ve CSV içe aktarma kurallarını uygular. Bu projede SQL yazılırken, tablo eklenirken, sorgu veya güvenlik politikası düzenlenirken kullan.
---

# Veritabanı Skill: Supabase / PostgreSQL

Bu skill, kripto portföy takip uygulamasının veri katmanı kuralları içindir. Teknoloji: **Supabase (PostgreSQL + Auth + Realtime + Edge Functions)**. İstemci: Flutter (`supabase_flutter`).

## 1. Ne zaman kullanılır

- Yeni tablo, kolon, indeks veya görünüm eklerken
- RLS politikası yazarken veya değiştirirken
- İşlem, fiyat önbelleği veya CSV içe aktarma ile ilgili SQL yazarken
- Flutter tarafında Supabase sorgusu yazarken (hangi veri nereden gelmeli kararı)

## 2. Temel ilkeler

1. **İşlemler tek gerçek kaynaktır.** Ortalama maliyet, K/Z, bakiye ve gerçekleşmiş kâr **veritabanında saklanmaz**, işlemlerden hesaplanır. Bir işlem düzeltildiğinde her şey kendiliğinden tutarlı kalır.
2. **Para ve miktar için `float` yok.** Veritabanında `numeric(38,18)`, Dart'ta `decimal` paketi.
3. **Her tabloda RLS açık.** Kullanıcı yalnızca kendi satırlarını görür ve değiştirir.
4. **Yumuşak silme.** İşlemler `deleted_at` ile işaretlenir, fiziksel silinmez.
5. **Tüm şema değişiklikleri migration dosyasıyla.** Panelden elle değişiklik yapma.
6. **Fiyat önbelleği ortaktır.** `price_cache` kullanıcıya bağlı değildir, tek yazan Edge Function'dır.

## 3. Tablo şeması

### 3.1 Genel bakış

| Tablo | Amaç | Sahiplik |
|---|---|---|
| `profiles` | Kullanıcı profili ve tercihleri | Kullanıcı |
| `assets` | Coin kataloğu (CoinGecko eşlemesi) | Ortak, salt okunur |
| `transactions` | Alış/satış işlemleri, **asıl tablo** | Kullanıcı |
| `price_cache` | Güncel fiyat önbelleği | Ortak, yalnızca Edge Function yazar |

### 3.2 Migration: şema

```sql
-- 001_init.sql

create extension if not exists "pgcrypto";

-- Yardımcı: updated_at otomatik güncelleme
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

-- PROFILES
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

-- Kayıt olunca otomatik profil oluştur
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

-- ASSETS (ortak katalog)
create table public.assets (
  id            uuid primary key default gen_random_uuid(),
  symbol        text not null,
  name          text not null,
  coingecko_id  text not null unique,
  image_url     text,
  market_cap_rank int,
  created_at    timestamptz not null default now()
);
create index idx_assets_symbol on public.assets (upper(symbol));

-- TRANSACTIONS (asıl tablo)
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

-- PRICE_CACHE (ortak)
create table public.price_cache (
  asset_id    uuid not null references public.assets(id) on delete cascade,
  currency    text not null check (currency in ('USD','TRY')),
  price       numeric(38,18) not null,
  change_24h  numeric,
  fetched_at  timestamptz not null default now(),
  primary key (asset_id, currency)
);
```

### 3.3 Migration: RLS

```sql
-- 002_rls.sql

alter table public.profiles      enable row level security;
alter table public.transactions  enable row level security;
alter table public.assets        enable row level security;
alter table public.price_cache   enable row level security;

-- profiles: yalnızca kendi satırı
create policy "profiles_select_own" on public.profiles
  for select to authenticated using (id = auth.uid());
create policy "profiles_update_own" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- transactions: yalnızca kendi satırları
create policy "tx_select_own" on public.transactions
  for select to authenticated using (user_id = auth.uid());
create policy "tx_insert_own" on public.transactions
  for insert to authenticated with check (user_id = auth.uid());
create policy "tx_update_own" on public.transactions
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "tx_delete_own" on public.transactions
  for delete to authenticated using (user_id = auth.uid());

-- assets ve price_cache: giriş yapan herkes okur, yazma yok
-- (yazma yalnızca service_role ile Edge Function'dan yapılır)
create policy "assets_read" on public.assets
  for select to authenticated using (true);
create policy "price_cache_read" on public.price_cache
  for select to authenticated using (true);
```

**RLS kuralları:**
- `service_role` anahtarı **asla** Flutter uygulamasına konmaz, yalnızca Edge Function içinde kullanılır.
- Uygulamadaki `anon` anahtar RLS sayesinde güvenle açıkta durabilir. RLS kapalı bir tablo = herkese açık tablo demektir.
- Yeni tablo eklendiğinde aynı migration içinde `enable row level security` ve politikalar yazılır.

### 3.4 Satış doğrulama tetikleyicisi

Eldeki miktardan fazla satış yapılmasını veritabanı da engeller (istemci doğrulamasına ek güvence).

```sql
-- 003_sell_guard.sql

create or replace function public.guard_oversell()
returns trigger language plpgsql as $$
declare
  held numeric(38,18);
begin
  if new.type = 'SELL' and new.deleted_at is null then
    select coalesce(sum(case when type = 'BUY' then quantity else -quantity end), 0)
      into held
      from public.transactions
     where user_id = new.user_id
       and asset_id = new.asset_id
       and deleted_at is null
       and executed_at <= new.executed_at
       and id <> new.id;

    if held < new.quantity then
      raise exception 'Yetersiz bakiye: eldeki miktar % , satış miktarı %', held, new.quantity
        using errcode = 'check_violation';
    end if;
  end if;
  return new;
end $$;

create trigger trg_guard_oversell
  before insert or update on public.transactions
  for each row execute function public.guard_oversell();
```

Sınırlama: Geçmişe dönük bir ALIŞ silinirse sonraki satışlar yetersiz kalabilir. Bu durumu istemci tarafında silme öncesi uyarıyla yakala ("Bu alışı silersen X satışı eksi bakiyeye düşer").

### 3.5 Görünüm: eldeki miktar

Ortalama maliyet sıralı hesap gerektirdiği için **Dart tarafında** (`cost_calculator.dart`) yapılır. Veritabanı yalnızca eldeki miktarı verir:

```sql
-- 004_views.sql

create or replace view public.holdings
with (security_invoker = true) as
select
  t.user_id,
  t.asset_id,
  sum(case when t.type = 'BUY' then t.quantity else -t.quantity end) as quantity
from public.transactions t
where t.deleted_at is null
group by t.user_id, t.asset_id
having sum(case when t.type = 'BUY' then t.quantity else -t.quantity end) > 0;
```

`security_invoker = true` sayesinde görünüm, sorguyu yapan kullanıcının RLS kurallarına tabi olur.

### 3.6 Realtime

```sql
-- 005_realtime.sql
alter publication supabase_realtime add table public.transactions;
alter publication supabase_realtime add table public.price_cache;
```

Flutter tarafında yalnızca ihtiyaç duyulan kanallara abone ol, ekran kapanınca `unsubscribe` et.

## 4. Ortalama maliyet ve K/Z kuralı (hesap Dart'ta)

Veritabanı bu değerleri saklamaz, ama tüm katmanlar aynı kurala uymalı:

- İşlemler `executed_at` sırasıyla tekrar oynatılır (replay).
- **ALIŞ:** `toplam_maliyet += miktar × fiyat (+ komisyon)`, `miktar += alış miktarı`
- **SATIŞ:** `ortalama = toplam_maliyet / miktar`; gerçekleşmiş K/Z = `(satış fiyatı − ortalama) × satış miktarı − komisyon`; `toplam_maliyet -= ortalama × satış miktarı`; `miktar -= satış miktarı`
- **Miktar sıfıra inerse maliyet tabanı sıfırlanır.** Pozisyon kapanıp yeniden açılınca eski ortalama taşınmaz.
- Farklı para birimli işlemler, işlem anında kayıtlı `price_currency` ile tutulur. Görüntüleme para birimine dönüşüm anlık kurla yapılır (bkz. fiyat önbelleği).

## 5. Fiyat önbelleği

- Tek yazan **Edge Function** (`service_role`). İstemci yalnızca okur.
- Bir coin için hem `USD` hem `TRY` satırı tutulur, böylece ayrı kur tablosuna gerek kalmaz.
- Tazelik kontrolü: `fetched_at > now() - interval '<TTL>'` ise API'ye gidilmez.
- Upsert örneği (Edge Function içinde):

```sql
insert into public.price_cache (asset_id, currency, price, change_24h, fetched_at)
values ($1, $2, $3, $4, now())
on conflict (asset_id, currency)
do update set price = excluded.price,
              change_24h = excluded.change_24h,
              fetched_at = excluded.fetched_at;
```

**Kota hesabı (önemli):** CoinGecko Demo planı ayda 10.000 çağrı sunuyor (kaynaklara göre; resmi sayfadan doğrula). TTL 60 sn ve uygulama kesintisiz kullanılırsa ayda yaklaşık 43.000 çağrı gerekir, kota aşılır. 10.000 çağrı, TTL 60 sn ile yaklaşık 166 saatlik aktif kullanıma yeter. Bu yüzden:
- TTL değerini sabit olarak tek yerde tut (varsayılan 60 sn, kota sorunu çıkarsa 120-300 sn).
- Yenileme yalnızca biri uygulamayı **aktif kullanırken** tetiklensin, arka planda zamanlayıcıyla sürekli çağrı yapma.
- Tüm coinleri **tek toplu istekte** çek.

## 6. CSV içe aktarma

Şablon:

```
tarih,coin,islem_tipi,miktar,fiyat,para_birimi,komisyon
2026-01-15 10:30,BTC,BUY,0.05,95000,USD,2.5
```

Kurallar:
1. Dosya istemcide okunur ve doğrulanır, satır bazlı hata listesi gösterilir. Hatalı satır varsa kullanıcı onayı olmadan hiçbir şey yazılmaz.
2. `coin` sembolü `assets` tablosundaki kayıtla eşlenir; bulunamazsa satır "bilinmeyen coin" hatası verir.
3. `islem_tipi` yalnızca `BUY` veya `SELL`; `para_birimi` yalnızca `USD` veya `TRY`.
4. Tarih biçimi `yyyy-MM-dd HH:mm`, saat dilimi Europe/Istanbul varsayılır ve UTC'ye çevrilerek saklanır.
5. Satırlar `executed_at` sırasına dizilip **tek toplu insert** ile yazılır, `source = 'CSV'`.
6. Sıralı doğrulamada (replay) eksi bakiyeye düşen satış varsa tüm içe aktarma reddedilir.
7. Tekrar yüklemeyi önlemek için aynı kullanıcıda aynı `(asset, type, quantity, price, executed_at)` kombinasyonu uyarı verir.

## 7. Flutter sorgu kalıpları

```dart
// İşlemleri çek (RLS sayesinde user_id filtresi gerekmez ama açık yazmak okunabilirliği artırır)
final rows = await supabase
    .from('transactions')
    .select('*, assets(symbol, name, coingecko_id)')
    .isFilter('deleted_at', null)
    .order('executed_at', ascending: true);

// Yumuşak silme
await supabase
    .from('transactions')
    .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
    .eq('id', txId);

// Fiyatlar (önbellekten oku)
final prices = await supabase
    .from('price_cache')
    .select('asset_id, currency, price, change_24h, fetched_at');

// Realtime: işlemler değişince portföyü yenile
supabase
    .channel('tx-changes')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'transactions',
      callback: (_) => ref.invalidate(transactionsProvider),
    )
    .subscribe();
```

Kurallar:
- `select('*')` yerine ihtiyaç duyulan kolonları yaz.
- Miktar ve fiyatı `numeric` olarak string gelen değerden `Decimal.parse` ile oku, `double`'a çevirme.
- Tarihleri her zaman UTC gönder, ekranda yerel saate çevir.
- Her sorguda hata durumu ele alınır (`PostgrestException`), kullanıcıya anlaşılır mesaj gösterilir.

## 8. Adlandırma ve migration düzeni

- Tablo ve kolon: `snake_case`, tablo adları çoğul (`transactions`).
- Anahtar: `id uuid`; yabancı anahtar: `<tablo_tekil>_id`.
- İndeks: `idx_<tablo>_<kolonlar>`; tetikleyici: `trg_<tablo>_<amaç>`; politika: `<tablo>_<eylem>_<kapsam>`.
- Migration dosyaları sıralı numaralı ve geri alınabilir düşünülerek yazılır: `supabase/migrations/001_init.sql`, `002_rls.sql`, ...
- Yeni kolon eklerken eski satırlar için `default` veya `not null` stratejisini migration içinde belirt.
- Silme gerektiren değişiklikler önce yedek alınarak ve ayrı migration ile yapılır.

## 9. Yapma listesi

- `float` / `double precision` ile para saklama.
- Ortalama maliyet veya K/Z'yi tabloya yazma (türetilmiş veri saklama).
- RLS kapalı tablo bırakma.
- `service_role` anahtarını istemciye koyma.
- İstemciden `price_cache` veya `assets`'e doğrudan yazma.
- Fiziksel `delete` ile işlem silme (yumuşak silme kullan).
- Panelden şemayı elle değiştirip migration'a yansıtmamak.
- CSV'yi satır satır tek tek insert etmek.

## 10. Teslim öncesi kontrol listesi

- [ ] Yeni her tabloda RLS açık ve politikalar test edildi (başka kullanıcının verisi görünmüyor)
- [ ] Para ve miktar kolonları `numeric(38,18)`
- [ ] Gerekli indeksler eklendi
- [ ] Migration dosyası numaralı ve temiz bir veritabanında baştan çalışıyor
- [ ] Fazla satış hem formda hem tetikleyicide engelleniyor
- [ ] `price_cache` TTL değeri tek yerde tanımlı, kota hesabı kontrol edildi
- [ ] Realtime yalnızca gerekli tablolarda açık
- [ ] CSV içe aktarma hatalı satırda hiçbir şey yazmadan duruyor
- [ ] Hesap silinince kullanıcının tüm verisi `on delete cascade` ile siliniyor