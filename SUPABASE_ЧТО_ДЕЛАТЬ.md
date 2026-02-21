# Что нужно сделать в Supabase

Пошаговая инструкция: что настроить на сайте [supabase.com](https://supabase.com) для работы приложения.

---

## 1. Открыть проект

1. Зайдите на [supabase.com](https://supabase.com) и войдите в аккаунт.
2. Откройте свой проект (или создайте новый).

---

## 2. Выполнить SQL-скрипты (таблицы и политики)

В левом меню выберите **SQL Editor** → **New query**.

### Шаг 2.1 — Устройства (сессии)

1. Откройте файл **`supabase_device_sessions.sql`** из корня проекта.
2. Скопируйте весь код и вставьте в окно запроса в Supabase.
3. Нажмите **Run** (или Ctrl+Enter).
4. Должно появиться сообщение об успешном выполнении.

Так создаётся таблица `device_sessions` и политики RLS для раздела «Устройства».

### Шаг 2.2 — Синхронизация данных и Realtime

1. Откройте файл **`supabase_user_data_sync.sql`** из корня проекта.
2. Скопируйте весь код и вставьте в новый запрос в Supabase.
3. Нажмите **Run**.

Так создаются таблицы заказов, избранного, корзины, адресов, карт и включается Realtime для них.

Если появятся ошибки вида «policy already exists» или «table already in publication» — скрипт уже выполнялся раньше, это нормально. Можно не обращать внимания или выполнять только те части, которые ещё не выполняли.

---

## 3. Проверить API-ключ в приложении

1. В Supabase: **Project Settings** (иконка шестерёнки) → **API**.
2. Скопируйте:
   - **Project URL** — должен быть в `lib/supabase_config.dart` как `url`;
   - **anon public** ключ — должен быть в `lib/supabase_config.dart` как `anonKey`.
3. Если в приложении другие значения — замените их в `lib/supabase_config.dart`.

Без правильного URL и anon-ключа приложение не сможет подключиться к проекту.

---

## 4. Удаление аккаунта — Edge Function (по желанию)

Чтобы работало **«Удаление аккаунта»** в настройках приложения, нужно задеплоить Edge Function.

### Вариант А — через Supabase CLI (рекомендуется)

1. **Установите Supabase CLI.** На Windows возможны два способа:

   **Способ 1 — через Scoop (удобно на Windows):**
   - Откройте PowerShell (не обязательно от администратора).
   - Если Scoop ещё не установлен, выполните:
     ```powershell
     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
     iwr -useb get.scoop.sh | iex
     ```
   - Затем:
     ```powershell
     scoop install supabase
     ```
   - Проверка: `supabase --version`

   **Способ 2 — через npx (если установлен Node.js):**  
   Устанавливать CLI глобально не обязательно. В папке проекта можно вызывать команды так:
   ```powershell
   npx supabase login
   npx supabase link --project-ref ВАШ_PROJECT_REF
   npx supabase functions deploy delete-user
   ```
   (при первом запуске npx скачает Supabase CLI сам).

2. Откройте терминал в папке проекта приложения (`telemost12_app`).
3. Выполните по очереди (если ставили через Scoop — просто `supabase`, если через npx — `npx supabase`):
   ```bash
   supabase login
   ```
   (откроется браузер для входа в Supabase).
   ```bash
   supabase link --project-ref ВАШ_PROJECT_REF
   ```
   **ВАШ_PROJECT_REF** — это ID проекта. Его можно взять в Supabase: **Project Settings** → **General** → **Reference ID**.
   ```bash
   supabase functions deploy delete-user
   ```
4. После успешного деплоя функция «Удаление аккаунта» в приложении начнёт удалять пользователя в Supabase Auth.

### Вариант Б — не деплоить функцию

- Если функцию не деплоить, при нажатии «Удалить аккаунт» приложение покажет ошибку (функция не найдена).
- Удалять пользователей тогда можно вручную: в Supabase **Authentication** → **Users** → выбрать пользователя → **Delete user**.

---

## 5. Краткий чеклист

| Действие | Где в Supabase | Файл/команда |
|----------|----------------|--------------|
| Создать таблицу сессий устройств и RLS | SQL Editor | `supabase_device_sessions.sql` |
| Создать таблицы заказов, корзины и т.д. + Realtime | SQL Editor | `supabase_user_data_sync.sql` |
| Проверить URL и anon-ключ | Project Settings → API | Вписать в `lib/supabase_config.dart` |
| Включить удаление аккаунта | Депой Edge Function | `supabase functions deploy delete-user` (из папки проекта) |

---

## Если что-то пошло не так

- **«supabase не распознано» / CommandNotFoundException** — Supabase CLI не установлен. См. раздел 4, шаг 1: установите через Scoop или используйте `npx supabase` (нужен Node.js).
- **Ошибка «Invalid API key»** — проверьте, что в `supabase_config.dart` вставлен именно **anon public** ключ из **Project Settings** → **API**.
- **Ошибка «relation does not exist»** — не выполнен один из SQL-скриптов. Выполните сначала `supabase_device_sessions.sql`, затем `supabase_user_data_sync.sql`.
- **«Удаление аккаунта» пишет ошибку** — задеплойте Edge Function (раздел 4) или удаляйте пользователей вручную в **Authentication** → **Users**.
