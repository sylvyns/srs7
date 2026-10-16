# SRSP 5 + Laboratory work 7 — Registration Form + Firebase

Что делает приложение:
1. Форма регистрации с проверкой полей (из СРСП 5).
2. При отправке данные сохраняются в **Firebase Realtime Database** (`users`)
   и локально в SharedPreferences.
3. Показывается уведомление «Регистрация успешна!».
4. Открывается страница профиля, которая читает данные из Firebase
   и обновляется в реальном времени.
5. Приложение получает push-уведомления через Firebase Cloud Messaging.

## Перед запуском (один раз)

### 1. Firebase Console
1. Открыть проект (например `lab7`).
2. Realtime Database должна быть создана (test mode).
3. ⚙️ Project settings → Your apps → **Add app → Android**
   - Android package name: **`com.example.srsp5`**
   - Register app → **Download google-services.json**
4. Положить файл в `android/app/google-services.json`.

> Если у тебя уже есть google-services.json от проекта lab7_firebase — он НЕ подойдёт,
> там другой package name. Нужно добавить ещё одно Android-приложение с `com.example.srsp5`
> и скачать новый файл (Firebase-проект можно использовать тот же).

### 2. Запуск
```
flutter clean
flutter pub get
flutter run
```

## Проверка
- Заполнить форму → Submit → уведомление + страница профиля.
- Firebase Console → Realtime Database → Data → `users` → новая запись.
- Поменять `name` прямо в консоли → имя на странице профиля изменится само.
- Push: скопировать `FCM TOKEN: ...` из терминала →
  Firebase Console → Messaging → New campaign → Notifications →
  Send test message → вставить токен → Test.
