# Настройка админ-панели и Firebase

## 1. Создание проекта Firebase

1. Перейдите на [console.firebase.google.com](https://console.firebase.google.com)
2. Нажмите «Создать проект» или выберите существующий
3. Включите **Firestore Database** (Режим тестовый для начала)
4. Включите **Storage** (Начать в тестовом режиме)

## 2. Настройка приложения Flutter

```bash
# Установите FlutterFire CLI
dart pub global activate flutterfire_cli

# Настройте Firebase (создаст firebase_options.dart)
flutterfire configure
```

Выберите ваш проект Firebase и платформы (Android, iOS, Web).

## 3. Настройка админ-панели

1. В Firebase Console: Настройки проекта → Ваши приложения → Добавить приложение → Web
2. Скопируйте объект `firebaseConfig`
3. Откройте `admin/config.js` и вставьте ваши данные:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.firebasestorage.app",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

## 4. Запуск админ-панели

Откройте `admin/index.html` в браузере (двойной клик или через локальный сервер):

```bash
cd admin
npx serve .
# или: python -m http.server 8080
```

Перейдите на http://localhost:8080 (или указанный порт).

## 5. Добавление товара

1. Заполните форму: название, цена, категория, описание, размеры
2. Выберите фото
3. Нажмите «Добавить товар»

Товар появится в приложении после обновления каталога (pull-to-refresh или перезапуск).

## 6. Правила безопасности (для продакшена)

В `firestore.rules` и `storage.rules` сейчас разрешён полный доступ. Для продакшена добавьте аутентификацию:

```javascript
// Firestore — только чтение для всех, запись только для админов
allow read: if true;
allow write: if request.auth != null && request.auth.token.admin == true;
```

## Структура товара в Firestore

- `title` (string) — название
- `price` (number) — цена в рублях
- `category` (string) — Одежда, Обувь, Аксессуары, Новая коллекция
- `description` (string, optional)
- `sizes` (array of strings, optional) — например ["S", "M", "L", "XL"]
- `imageUrl` (string) — URL фото из Storage
- `createdAt` (timestamp) — дата добавления
