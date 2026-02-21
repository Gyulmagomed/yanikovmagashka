// Данные из Supabase Dashboard: Project Settings → API
const supabaseConfig = {
  url: "https://irtfzvbisnrbqjsunelo.supabase.co",
  anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlydGZ6dmJpc25yYnFqc3VuZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMDMwOTMsImV4cCI6MjA4NjY3OTA5M30.LWugbs6stfQ4VfY_afvkVHC1LwdfexMIC9dgMlwao7E"
};

// Пароль для входа в админку (оставьте пустым, чтобы не требовать пароль)
const adminPassword = "1964";

// Секрет для создания промокодов (только вы знаете). Должен совпадать с admin_secret в Supabase.
const adminSecret = "LIFI";
