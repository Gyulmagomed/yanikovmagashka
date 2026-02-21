-- Промокоды: только вы можете создавать. Выполните в Supabase → SQL Editor.
-- 1. Выполните весь скрипт
-- 2. В конце выполните: insert into admin_secret (secret) values ('ВАШ_СЕКРЕТНЫЙ_ПАРОЛЬ');
-- 3. Добавьте тот же пароль в config.js как adminSecret

-- Таблица секрета (только для проверки в RPC, недоступна через API)
create table if not exists admin_secret (
  id int primary key default 1,
  secret text not null
);
alter table admin_secret enable row level security;

-- Таблица промокодов (пользователи только читают)
create table if not exists promo_codes (
  id uuid default gen_random_uuid() primary key,
  code text not null unique,
  discount_percent integer not null check (discount_percent >= 1 and discount_percent <= 100),
  is_active boolean default true,
  created_at timestamptz default now()
);

alter table promo_codes enable row level security;

-- Все могут читать промокоды (приложение проверяет is_active при валидации)
create policy "Чтение промокодов"
  on promo_codes for select
  using (true);

-- INSERT/UPDATE/DELETE — только через RPC с секретом (политик нет = доступ запрещён)

-- Функция добавления (только с правильным секретом)
create or replace function add_promo_code(
  p_code text,
  p_discount integer,
  p_secret text
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_id uuid;
  v_stored text;
begin
  select secret into v_stored from admin_secret limit 1;
  if v_stored is null or p_secret is null or p_secret != v_stored then
    raise exception 'Доступ запрещён';
  end if;
  insert into promo_codes (code, discount_percent)
  values (upper(trim(p_code)), p_discount)
  returning id into v_id;
  return v_id;
end;
$$;

create or replace function update_promo_code(
  p_id uuid,
  p_code text,
  p_discount integer,
  p_is_active boolean,
  p_secret text
)
returns void
language plpgsql
security definer
as $$
declare
  v_stored text;
begin
  select secret into v_stored from admin_secret limit 1;
  if v_stored is null or p_secret is null or p_secret != v_stored then
    raise exception 'Доступ запрещён';
  end if;
  update promo_codes set
    code = upper(trim(p_code)),
    discount_percent = p_discount,
    is_active = p_is_active
  where id = p_id;
end;
$$;

create or replace function delete_promo_code(p_id uuid, p_secret text)
returns void
language plpgsql
security definer
as $$
declare
  v_stored text;
begin
  select secret into v_stored from admin_secret limit 1;
  if v_stored is null or p_secret is null or p_secret != v_stored then
    raise exception 'Доступ запрещён';
  end if;
  delete from promo_codes where id = p_id;
end;
$$;

-- Разрешить вызов RPC всем (проверка секрета внутри функции)
grant execute on function add_promo_code(text, integer, text) to anon;
grant execute on function update_promo_code(uuid, text, integer, boolean, text) to anon;
grant execute on function delete_promo_code(uuid, text) to anon;

-- ВАЖНО: Замените LIFI на свой секрет (тот же, что в config.js → adminSecret)
insert into admin_secret (id, secret) values (1, 'LIFI')
on conflict (id) do update set secret = excluded.secret;
