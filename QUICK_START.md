# 🚀 Quick Start: Flutter + Android Emulator

## Выберите вашу операционную систему:

---

## 🐧 **Linux / macOS**

### 1️⃣ Убедитесь, что установлены:
```bash
java -version                 # Java 11 или выше
which curl                     # curl
which unzip                    # unzip
```

Если чего-то нет, установите (Ubuntu/Debian):
```bash
sudo apt install default-jdk curl unzip
```

На macOS (Homebrew):
```bash
brew install java curl unzip
```

### 2️⃣ Запустите скрипт:
```bash
chmod +x setup-android-emulator.sh
./setup-android-emulator.sh
```

### 3️⃣ Готово! 
Эмулятор должен открыться автоматически. Откройте новый терминал и выполните:

```bash
flutter devices                # Должен увидеть эмулятор
cd /path/to/tapball
flutter run                    # Запустить приложение на эмуляторе
```

---

## 🪟 **Windows**

### 1️⃣ Убедитесь, что установлены:
- **Java 11+**: https://adoptium.net/
- **PowerShell 5.0+** (обычно уже есть)

Проверьте Java:
```powershell
java -version
```

### 2️⃣ Откройте PowerShell как Администратор

![Windows Start → PowerShell → Run as Administrator](https://imgur.com/example.png)

### 3️⃣ Перейдите в папку проекта и запустите скрипт:
```powershell
cd C:\path\to\tapball
.\setup-android-emulator.ps1
```

Если возникнет ошибка с выполнением скриптов, выполните один раз:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 4️⃣ Готово!
Эмулятор должен открыться автоматически. Откройте новый PowerShell и выполните:

```powershell
flutter devices                # Должен увидеть эмулятор
cd C:\path\to\tapball
flutter run                    # Запустить приложение на эмуляторе
```

---

## ✅ Что должно получиться

```bash
$ flutter devices
testAVD (mobile) • emulator-5554 • android-x86_64 • Android 13 (API 33)
```

```bash
$ flutter run
Launching lib/main.dart on testAVD in debug mode...
```

---

## 🆘 Проблемы?

### ❌ "emulator: command not found"
Добавьте Android SDK в PATH. Смотрите `ANDROID_SETUP.md` → "Переменные окружения"

### ❌ "Emulator requires hardware acceleration"
**Linux:** включите KVM:
```bash
sudo apt install qemu-kvm
sudo usermod -a -G kvm $USER
# Выйдите и войдите заново
```

### ❌ Медленно запускается
Первый запуск может занять 1-2 минуты. Дальше быстрее.

### ❌ Эмулятор не подключается
```bash
adb kill-server
adb start-server
flutter devices
```

---

## 📚 Дополнительно

- **Полный гайд:** `ANDROID_SETUP.md`
- **Flutter документация:** https://flutter.dev/docs
- **Android документация:** https://developer.android.com/studio

---

## 🎯 Следующие шаги

После успешного запуска эмулятора:

1. ✅ `flutter run` — запустить приложение
2. 🔍 `flutter devices` — список подключённых устройств
3. 📝 `adb logcat` — логи приложения
4. 🔄 `adb shell` — доступ к оболочке устройства

---

**Версия:** 1.0 | **Обновлено:** 2026-06-16
