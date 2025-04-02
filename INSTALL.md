# Установка Менеджера задач

## ⚙️ Требования

- Flutter SDK версии 3.0.0 или выше
- Для Android: Android Studio с установленным Android SDK
- Для iOS: Xcode 12 или выше
- Git (для клонирования репозитория)

## 🛠️ Установка зависимостей

1. Убедитесь, что у вас установлен Flutter:
```bash
flutter --version
```

2. Если Flutter не установлен, скачайте его с [официального сайта](https://flutter.dev) и добавьте в PATH

3. Установите Android Studio или Xcode в зависимости от целевой платформы

## 🚀 Запуск проекта

1. Клонируйте репозиторий:
```bash
git clone https://github.com/ваш-репозиторий/task_manager_app.git
```

2. Перейдите в директорию проекта:
```bash
cd task_manager_app
```

3. Установите зависимости:
```bash
flutter pub get
```

## ▶️ Запуск на разных платформах

### Android
```bash
flutter run -d android
```

### iOS
```bash
flutter run -d ios
```

### Web
```bash
flutter run -d chrome
```

### Windows
```bash
flutter run -d windows
```

## 🏗️ Сборка релизных версий

### Android APK
```bash
flutter build apk
```

### Android App Bundle
```bash
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

### Windows
```bash
flutter build windows
```

## 🔧 Устранение неполадок

Если возникают проблемы:
1. Проверьте версию Flutter:
```bash
flutter doctor
```

2. Обновите зависимости:
```bash
flutter pub upgrade
```

3. Очистите кеш:
```bash
flutter clean
