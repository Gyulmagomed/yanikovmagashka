# Включить Firebase Hosting

Ошибка при деплое часто связана с тем, что Hosting ещё не включён в проекте.

## Что сделать

1. Откройте **https://console.firebase.google.com**
2. Выберите проект **yanikov-shop**
3. В левом меню нажмите **«Сборка»** (Build) → **«Hosting»**
4. Нажмите **«Начать»** (Get started)
5. Пройдите шаги мастера (можно нажать «Далее» и «Готово»)

После этого Hosting будет включён. Вернитесь в терминал и выполните:

```
firebase deploy --only hosting --project yanikov-shop
```
