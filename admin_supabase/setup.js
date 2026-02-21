/**
 * Один раз запустите: node setup.js
 * Введите пароль от БД (тот, что при создании проекта Supabase)
 * После этого удаление будет работать сразу по кнопке.
 */
const fs = require('fs');
const path = require('path');

const configPath = path.join(__dirname, 'config.js');
let projectRef = 'irtfzvbisnrbqjsunelo';
try {
  const configStr = fs.readFileSync(configPath, 'utf8');
  const m = configStr.match(/https:\/\/([^.]+)\.supabase\.co/);
  if (m) projectRef = m[1];
} catch (_) {}

const sql = `
DROP POLICY IF EXISTS "Разрешить удаление всем" ON products;
CREATE POLICY "Разрешить удаление всем"
  ON products FOR DELETE
  USING (true);
`;

async function run() {
  const readline = require('readline');
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  const ask = (q) => new Promise((r) => rl.question(q, r));

  console.log('\n=== Настройка удаления для YANIKOV ===\n');
  console.log('Проект:', projectRef);
  const password = await ask('Пароль от БД Supabase (из создания проекта): ');
  rl.close();

  if (!password.trim()) {
    console.log('Пароль не введён.');
    process.exit(1);
  }

  const { Client } = require('pg');
  const configs = [
    { host: `db.${projectRef}.supabase.co`, port: 5432, user: 'postgres' },
    { host: `aws-0-eu-central-1.pooler.supabase.com`, port: 6543, user: `postgres.${projectRef}` },
    { host: `aws-0-us-east-1.pooler.supabase.com`, port: 6543, user: `postgres.${projectRef}` }
  ];

  for (const cfg of configs) {
    try {
      const client = new Client({
        host: cfg.host,
        port: cfg.port,
        database: 'postgres',
        user: cfg.user,
        password: password.trim(),
        ssl: { rejectUnauthorized: false }
      });
      await client.connect();
      await client.query(sql);
      await client.end();
      console.log('\n✓ Готово! Теперь удаление работает — нажимайте «Удалить» и товар исчезнет сразу.\n');
      return;
    } catch (e) {
      if (e.code === 'ENOTFOUND' || e.message.includes('EAI_AGAIN')) continue;
      if (e.message.includes('password') || e.message.includes('auth')) {
        console.error('\nОшибка:', e.message);
        console.log('Проверьте пароль. Его можно сбросить: Supabase → Project Settings → Database → Reset database password');
        process.exit(1);
      }
      throw e;
    }
  }
  console.error('\nОшибка: не удалось подключиться (DNS/сеть).');
  console.log('Варианты: 1) Попробуйте VPN или другой интернет  2) Выполните SQL вручную: Supabase → SQL Editor → New query → вставьте и Run:');
  console.log('\nDROP POLICY IF EXISTS "Разрешить удаление всем" ON products;');
  console.log('CREATE POLICY "Разрешить удаление всем" ON products FOR DELETE USING (true);\n');
  process.exit(1);
}

run();
