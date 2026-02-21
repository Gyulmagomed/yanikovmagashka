# Edge Function: delete-user

Нужна для удаления аккаунта пользователя из приложения (Настройки → Удаление аккаунта).

## Депой в Supabase

1. Установите [Supabase CLI](https://supabase.com/docs/guides/cli).
2. В корне проекта выполните:
   ```bash
   supabase login
   supabase link --project-ref ВАШ_PROJECT_REF
   supabase functions deploy delete-user
   ```
3. `SUPABASE_URL` и `SUPABASE_SERVICE_ROLE_KEY` подставляются автоматически в среде Supabase.

Если функцию не деплоить, при нажатии «Удалить аккаунт» приложение покажет ошибку (например, что функция не найдена). В этом случае пользователь может обратиться в поддержку для ручного удаления.
