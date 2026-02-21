-- Таблица сессий устройств (как в Telegram)
-- Выполните в Supabase: SQL Editor → New query → вставьте этот код → Run
-- Нужно для функции "Устройства" — показывает все устройства, с которых залогинен пользователь

-- 1. Таблица
create table if not exists device_sessions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  session_id text not null,
  device_name text not null,
  platform text not null,
  last_active timestamptz not null default now(),
  created_at timestamptz default now(),
  unique(user_id, session_id)
);

-- 2. Индекс для быстрого поиска по user_id
create index if not exists idx_device_sessions_user_id on device_sessions(user_id);

-- 3. Включаем RLS
alter table device_sessions enable row level security;

-- 4. Удаляем старые политики (если скрипт уже запускали)
drop policy if exists "Users see own sessions" on device_sessions;
drop policy if exists "Users insert own sessions" on device_sessions;
drop policy if exists "Users update own sessions" on device_sessions;
drop policy if exists "Users delete own sessions" on device_sessions;

-- 5. Политики RLS
-- Пользователь видит только свои сессии
create policy "Users see own sessions"
  on device_sessions for select
  using (auth.uid() = user_id);

-- Пользователь может добавлять свои сессии
create policy "Users insert own sessions"
  on device_sessions for insert
  with check (auth.uid() = user_id);

-- Пользователь может обновлять свои сессии (last_active, device_name, platform)
create policy "Users update own sessions"
  on device_sessions for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Пользователь может удалять свои сессии
create policy "Users delete own sessions"
  on device_sessions for delete
  using (auth.uid() = user_id);
