-- 006_seed_assets.sql: Başlangıç Coin Kataloğu

insert into public.assets (symbol, name, coingecko_id, market_cap_rank)
values
  ('BTC', 'Bitcoin', 'bitcoin', 1),
  ('ETH', 'Ethereum', 'ethereum', 2),
  ('SOL', 'Solana', 'solana', 3),
  ('BNB', 'BNB', 'binancecoin', 4),
  ('XRP', 'XRP', 'ripple', 5),
  ('DOGE', 'Dogecoin', 'dogecoin', 6),
  ('ADA', 'Cardano', 'cardano', 7),
  ('AVAX', 'Avalanche', 'avalanche-2', 8)
on conflict (coingecko_id) do nothing;
