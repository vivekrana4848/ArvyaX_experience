<div align="center">

# ✦ ArvyaX

### *Immersive Session App*

> **Focus deeper. Rest better. Stay present.**
> A premium Flutter app for guided audio sessions, mindful timers, and reflective journaling — all in one seamless experience.

<br>

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-Local%20DB-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Mgmt-00BCD4?style=for-the-badge&logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-brightgreen?style=for-the-badge)

</div>

---

## 📱 Preview

> 📂 Place your screenshots inside `/assets/screenshots/` and update the paths below.

<div align="center">

| Home | Player | Journal | History |
|------|--------|---------|---------|
| ![Home](assets/screenshots/home.png) | ![Player](assets/screenshots/player.png) | ![Journal](assets/screenshots/journal.png) | ![History](assets/screenshots/history.png) |

</div>

> **NOTE:** Use `800×1600px` PNG screenshots at 2× density for best results on GitHub.

---

## ✨ Features

### 🎵 Audio Player
- 🔁 Seamless audio looping with zero-gap playback
- ⏱️ Timer-based auto-stop (5 min → 120 min)
- 🎚️ Smooth volume control
- 🌙 Background playback support

### 📓 Journal
- ✍️ Write reflections after every session
- 🗓️ Auto-tagged with date & session type
- 🔍 Searchable journal entries
- 💾 Persisted locally with SQLite

### 📊 Session History
- 📅 View all past sessions in a clean timeline
- ⏳ Track total focus/rest time
- 🏷️ Filter by session type

### ⚙️ General
- 🌗 Light & Dark mode
- 📴 Fully offline — no account needed
- 🔔 End-of-session notifications

---

## 📦 Feature Highlights

| Feature | Description | Status |
|---------|-------------|--------|
| 🔁 Audio Loop | Gapless looping engine via `just_audio` | ✅ Live |
| ⏱️ Session Timer | Countdown with auto-dismiss | ✅ Live |
| 📓 Journaling | Post-session reflective notes | ✅ Live |
| 📊 History View | Timeline of all sessions | ✅ Live |
| 🌗 Theming | Dynamic light/dark switch | ✅ Live |
| ☁️ Cloud Sync | Backup to cloud | 🔜 Planned |

---

## 🛠 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| 🎯 Framework | Flutter 3.x | Cross-platform UI |
| 💻 Language | Dart 3.x | App logic |
| 🗄️ Database | SQLite (via `sqflite`) | Local persistence |
| 🔄 State | Riverpod | Reactive state management |
| 🎵 Audio | `just_audio` | Looping playback engine |
| 🔔 Notifications | `flutter_local_notifications` | Session end alerts |
| 📁 Storage | `path_provider` | File system access |

---

## 🏗 Architecture

ArvyaX follows a clean **Feature-First** folder structure with separation of concerns across `data`, `domain`, and `presentation` layers.

```
arvyax/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart              # Root widget & theme
│   │   └── router.dart           # Navigation
│   ├── core/
│   │   ├── constants/            # App-wide constants
│   │   ├── theme/                # Light & dark themes
│   │   └── utils/                # Helpers & extensions
│   ├── features/
│   │   ├── player/
│   │   │   ├── data/             # Audio service, DB queries
│   │   │   ├── domain/           # Models, use cases
│   │   │   └── presentation/     # UI + Riverpod providers
│   │   ├── journal/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── history/
│   │       ├── data/
│   │       └── presentation/
│   └── shared/
│       ├── widgets/              # Reusable UI components
│       └── providers/            # Shared Riverpod providers
├── assets/
│   ├── audio/                    # Bundled audio tracks
│   └── screenshots/              # README preview images
└── pubspec.yaml
```

---

## 🧠 Key Logic

### 🔁 Audio Looping
ArvyaX uses `just_audio` with `LoopMode.one` to enable seamless, zero-gap looping. The audio engine is initialized once and kept alive across the session lifecycle.

```dart
final player = AudioPlayer();
await player.setAsset('assets/audio/rain_loop.mp3');
await player.setLoopMode(LoopMode.one);
await player.play();
```

### ⏱️ Timer-Based Session
Sessions use a `Riverpod` `StateNotifier` that ticks every second, emits countdown updates, and triggers a stop + notification when it reaches zero. The timer is fully isolated from the UI layer.

```dart
class SessionTimerNotifier extends StateNotifier<int> {
  Timer? _timer;

  void start(int durationSeconds) {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state <= 0) { _onSessionEnd(); return; }
      state = state - 1;
    });
  }

  void _onSessionEnd() {
    _timer?.cancel();
    // Trigger notification + stop audio
  }
}
```

### 🧱 Separation of Concerns
| Layer | Responsibility |
|-------|---------------|
| `data/` | SQLite queries, audio service wrappers |
| `domain/` | Pure Dart models and use-case logic |
| `presentation/` | Flutter widgets + Riverpod providers only |

> **IMPORTANT:** No business logic lives inside widgets. Providers mediate all state changes.

---

## 🚀 Installation

> Requires **Flutter 3.x** and **Dart 3.x**. Run `flutter --version` to verify.

```bash
# 1. Clone the repository
git clone https://github.com/your-username/arvyax.git

# 2. Navigate into the project
cd arvyax

# 3. Get all dependencies
flutter pub get

# 4. Run on your device or emulator
flutter run
```

```bash
# Build release APK
flutter build apk --release

# Build for iOS
flutter build ipa --release
```

---

## 📱 Screens

| Screen | Description |
|--------|-------------|
| 🏠 **Home** | Choose a session type and set duration |
| 🎵 **Player** | Active session with audio controls & live timer |
| ✍️ **Journal Entry** | Post-session reflection form |
| 📓 **Journal List** | Browse all past journal entries |
| 📅 **History** | Timeline of completed sessions |
| ⚙️ **Settings** | Theme toggle, notification prefs |

---

## 🔮 Future Improvements

- ☁️ Cloud sync via Firebase for cross-device journal access
- 📈 Weekly/monthly session analytics dashboard
- 🎵 Custom audio upload support
- 🧘 Guided voice session mode
- 🏆 Streak tracking and milestone badges
- 🌐 Localization (multi-language support)

---

## 👤 Author

<div align="center">

**Vivek** — Flutter Developer

[![GitHub](https://img.shields.io/badge/GitHub-@vivekrana4848-181717?style=for-the-badge&logo=github)](https://github.com/vivekrana4848)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/vivek-rana-a3401823a)

*Built with 🖤 using Flutter & clean architecture principles.*

</div>
