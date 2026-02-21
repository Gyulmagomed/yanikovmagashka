-- Включить удаление товаров в админке
-- Выполните в Supabase: SQL Editor → New query → вставьте → Run

-- 1. Политика удаления для таблицы products
DROP POLICY IF EXISTS "Разрешить удаление всем" ON products;
CREATE POLICY "Разрешить удаление всем"
  ON products FOR DELETE
  USING (true);
