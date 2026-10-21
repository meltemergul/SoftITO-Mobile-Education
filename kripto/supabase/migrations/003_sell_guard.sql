-- 003_sell_guard.sql: Eldeki miktardan fazla satış yapılmasını engelleyen tetikleyici

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
      raise exception 'Yetersiz bakiye: eldeki miktar %, satış miktarı %', held, new.quantity
        using errcode = 'check_violation';
    end if;
  end if;
  return new;
end $$;

create trigger trg_guard_oversell
  before insert or update on public.transactions
  for each row execute function public.guard_oversell();
