-- 004_views.sql: Eldeki miktar görünümü (Holdings)

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
