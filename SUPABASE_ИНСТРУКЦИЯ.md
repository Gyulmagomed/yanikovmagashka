# Supabase — настройка с нуля (без CORS)

Supabase — альтернатива Firebase. Обычно не даёт CORS-ошибок при загрузке фото.

**Подробная пошаговая инструкция:** откройте файл **`SUPABASE_ПОШАГОВО.md`** — там расписано, что нажимать и что вводить на каждом шаге.

---

## Шаг 1. Создать проект

1. Откройте **https://supabase.com**
2. Нажмите **Start your project**
3. Войдите через GitHub или email
4. Нажмите **New Project**
5. Заполните:
   - **Name:** yanikov-shop
   - **Database Password:** придумайте и сохраните
   - **Region:** выберите ближайший (например, Frankfurt)
6. Нажмите **Create new project**
7. Подождите 1–2 минуты

---

## Шаг 2. Создать таблицу products

1. В левом меню выберите **SQL Editor**
2. Нажмите **New query**
3. Вставьте и выполните (Run):

```sql
create table products (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  price integer not null,
  category text not null,
  description text,
  sizes text[],
  image_url text,
  created_at timestamptz default now()
);

alter table products enable row level security;

create policy "Разрешить чтение всем"
  on products for select
  using (true);

create policy "Разрешить добавление всем"
  on products for insert
  with check (true);

create policy "Разрешить удаление всем"
  on products for delete
  using (true);

create policy "Разрешить обновление всем"
  on products for update using (true)
  with check (true);
```

4. Нажмите **Run** (или Ctrl+Enter)

**Если таблица уже создана** — выполните недостающие политики:

```sql
create policy "Разрешить удаление всем"
  on products for delete
  using (true);

create policy "Разрешить обновление всем"
  on products for update using (true)
  with check (true);
```

---

## Шаг 3. Создать хранилище для фото

1. В левом меню выберите **Storage**
2. Нажмите **New bucket**
3. **Name:** products
4. Включите **Public bucket** (чтобы фото были доступны по ссылке)
5. Нажмите **Create bucket**
6. Откройте bucket **products** → **Policies** → **New Policy** → **For full customization**
7. Вставьте и выполните (можно по одной политике):

```sql
-- Разрешить загрузку
CREATE POLICY "Allow upload"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'products');

-- Разрешить чтение
CREATE POLICY "Allow read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'products');

-- Разрешить удаление (для удаления фото при удалении товара)
CREATE POLICY "Allow delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'products');
```

8. Нажмите **Review** → **Save policy** (для каждой политики отдельно)

---

## Шаг 3.5. Включить авторизацию (вход/регистрация)

1. В левом меню выберите **Authentication** → **Providers**
2. Убедитесь, что **Email** включён (по умолчанию включён)
3. Для удобства тестирования отключите **Confirm email** — тогда пользователь сразу войдёт после регистрации
4. Сохраните изменения

После этого приложение будет сохранять сессию: при повторном запуске пользователь останется в системе без повторного ввода данных.

---

## Шаг 4. Взять URL и ключ

1. В левом меню: **Project Settings** (иконка шестерёнки)
2. Раздел **API**
3. Скопируйте:
   - **Project URL**
   - **anon public** (ключ)

---

## Шаг 5. Настроить админку

1. Откройте файл **`admin_supabase/config.js`**
2. Вставьте данные:

```javascript
const supabaseConfig = {
  url: "https://xxxxx.supabase.co",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
};
```

3. Сохраните

---

## Шаг 6. Настроить приложение

1. Откройте **`lib/supabase_config.dart`**
2. Вставьте те же данные:

```dart
class SupabaseConfig {
  static const String url = 'https://xxxxx.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6...';
  ...
}
```

3. Сохраните

---

## Шаг 7. Открыть админку

Откройте **`admin_supabase/index.html`** в браузере (двойной клик).

Добавьте товар — CORS-ошибок быть не должно.

---

## Шаг 8. Запустить приложение

```
cd c:\Users\GG\telemost12_app
flutter run
```

Товары из Supabase появятся в каталоге.

---

## Кратко

| Где | Что |
|-----|-----|
| supabase.com | Создать проект, таблицу, bucket |
| Authentication → Providers | Включить Email, отключить Confirm email (для теста) |
| admin_supabase/config.js | URL и anon key |
| lib/supabase_config.dart | Те же URL и anon key |
| admin_supabase/index.html | Админка (открыть в браузере) |

---

## Авторизация и сессия

- **Supabase Auth** — вход и регистрация через email/пароль
- **Сохранение сессии** — при выходе из приложения пользователь остаётся авторизованным
- **Локальный режим** — если Supabase не настроен, используется локальное хранилище (SharedPreferences)

---

## Промокоды (только вы создаёте)

1. В Supabase → SQL Editor выполните скрипт из **`admin_supabase/promo_codes_setup.sql`**
2. В конце выполните: `insert into admin_secret (secret) values ('ВАШ_СЕКРЕТНЫЙ_ПАРОЛЬ');`
3. В **`admin_supabase/config.js`** добавьте:
   - `adminPassword` — пароль для входа в админку (опционально)
   - `adminSecret` — тот же пароль, что в admin_secret (для создания промокодов)
4. Во вкладке «Промокоды» создавайте промокоды. Только вы (с правильным adminSecret) можете их добавлять — без секрета запрос не пройдёт.
