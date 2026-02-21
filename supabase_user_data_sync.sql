-- Синхронизация данных пользователя между устройствами в реальном времени
-- Выполните в Supabase: SQL Editor → New query → вставьте этот код → Run
-- Сначала выполните supabase_device_sessions.sql (таблица device_sessions)

-- 1. Заказы пользователя
create table if not exists user_orders (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  order_id text not null,
  date timestamptz not null,
  items_summary text not null,
  total text not null,
  total_rubles integer not null,
  address_label text,
  created_at timestamptz default now(),
  unique(user_id, order_id)
);

create index if not exists idx_user_orders_user_id on user_orders(user_id);
alter table user_orders enable row level security;

drop policy if exists "Users see own orders" on user_orders;
drop policy if exists "Users insert own orders" on user_orders;
drop policy if exists "Users delete own orders" on user_orders;

create policy "Users see own orders" on user_orders for select using (auth.uid() = user_id);
create policy "Users insert own orders" on user_orders for insert with check (auth.uid() = user_id);
create policy "Users delete own orders" on user_orders for delete using (auth.uid() = user_id);

-- 2. Избранное (product_id)
create table if not exists user_favorites (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null,
  created_at timestamptz default now(),
  unique(user_id, product_id)
);

create index if not exists idx_user_favorites_user_id on user_favorites(user_id);
alter table user_favorites enable row level security;

drop policy if exists "Users see own favorites" on user_favorites;
drop policy if exists "Users insert own favorites" on user_favorites;
drop policy if exists "Users delete own favorites" on user_favorites;

create policy "Users see own favorites" on user_favorites for select using (auth.uid() = user_id);
create policy "Users insert own favorites" on user_favorites for insert with check (auth.uid() = user_id);
create policy "Users delete own favorites" on user_favorites for delete using (auth.uid() = user_id);

-- 3. Корзина
create table if not exists user_cart (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null,
  title text not null,
  price text not null,
  quantity integer not null default 1,
  created_at timestamptz default now(),
  unique(user_id, product_id)
);

create index if not exists idx_user_cart_user_id on user_cart(user_id);
alter table user_cart enable row level security;

drop policy if exists "Users see own cart" on user_cart;
drop policy if exists "Users insert own cart" on user_cart;
drop policy if exists "Users update own cart" on user_cart;
drop policy if exists "Users delete own cart" on user_cart;

create policy "Users see own cart" on user_cart for select using (auth.uid() = user_id);
create policy "Users insert own cart" on user_cart for insert with check (auth.uid() = user_id);
create policy "Users update own cart" on user_cart for update using (auth.uid() = user_id);
create policy "Users delete own cart" on user_cart for delete using (auth.uid() = user_id);

-- 4. Адреса доставки
create table if not exists user_addresses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  address_id text not null,
  label text not null,
  street text not null,
  city text not null,
  phone text not null,
  created_at timestamptz default now(),
  unique(user_id, address_id)
);

create index if not exists idx_user_addresses_user_id on user_addresses(user_id);
alter table user_addresses enable row level security;

drop policy if exists "Users see own addresses" on user_addresses;
drop policy if exists "Users insert own addresses" on user_addresses;
drop policy if exists "Users update own addresses" on user_addresses;
drop policy if exists "Users delete own addresses" on user_addresses;

create policy "Users see own addresses" on user_addresses for select using (auth.uid() = user_id);
create policy "Users insert own addresses" on user_addresses for insert with check (auth.uid() = user_id);
create policy "Users update own addresses" on user_addresses for update using (auth.uid() = user_id);
create policy "Users delete own addresses" on user_addresses for delete using (auth.uid() = user_id);

-- 5. Сохранённые карты
create table if not exists user_saved_cards (
  id uuid default gen_random_uuid() primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  card_id text not null,
  last4 text not null,
  brand text not null,
  expiry_month integer not null,
  expiry_year integer not null,
  holder_name text,
  created_at timestamptz default now(),
  unique(user_id, card_id)
);

create index if not exists idx_user_saved_cards_user_id on user_saved_cards(user_id);
alter table user_saved_cards enable row level security;

drop policy if exists "Users see own cards" on user_saved_cards;
drop policy if exists "Users insert own cards" on user_saved_cards;
drop policy if exists "Users delete own cards" on user_saved_cards;

create policy "Users see own cards" on user_saved_cards for select using (auth.uid() = user_id);
create policy "Users insert own cards" on user_saved_cards for insert with check (auth.uid() = user_id);
create policy "Users delete own cards" on user_saved_cards for delete using (auth.uid() = user_id);

-- 6. Включить Realtime (если таблица уже в публикации — пропускаем без ошибки)
do $$ begin alter publication supabase_realtime add table user_orders; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table user_favorites; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table user_cart; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table user_addresses; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table user_saved_cards; exception when duplicate_object then null; end $$;
do $$ begin alter publication supabase_realtime add table device_sessions; exception when duplicate_object then null; end $$;
