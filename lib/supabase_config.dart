/// Конфиг Supabase. Заполните после создания проекта на supabase.com
class SupabaseConfig {
  static const String url = 'https://irtfzvbisnrbqjsunelo.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlydGZ6dmJpc25yYnFqc3VuZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExMDMwOTMsImV4cCI6MjA4NjY3OTA5M30.LWugbs6stfQ4VfY_afvkVHC1LwdfexMIC9dgMlwao7E';

  static bool get isConfigured =>
      url.isNotEmpty &&
      !url.startsWith('YOUR_') &&
      anonKey.isNotEmpty &&
      !anonKey.startsWith('YOUR_');
}