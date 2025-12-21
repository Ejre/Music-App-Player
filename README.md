# μRhythm (Miku Rhythm) 🎵

A premium, aesthetic music player application built with Flutter, themed around Hatsune Miku. Featuring a seamless library experience, synchronized lyrics, and a modern cyberpunk-inspired UI.

<div align="center">
  <img src="assets/icon/miku_anime.png" alt="App Icon" width="120">
</div>

## ✨ Features

- **Hatsune Miku Theme**: Custom app icon and teal-accented dark UI.
- **Smooth Library**: Optimized scrolling with 60-120fps performance using fixed-height tiles and efficient image loading.
- **Lyrics Support**: Automatically reads `.lrc` files. Includes a smart retry mechanism to ensure lyrics load instantly on the first play.
- **Premium Audio**: Built on top of `just_audio` for reliable playback.
- **Background Playback**: Full notification control and background audio support.
- **Adaptive Icons**: Proper adaptive icon support for Android using Miku teal background.

## 📱 Screenshots

| Library | Player | Lyrics |
|:---:|:---:|:---:|
| <!-- Add Screenshots Here --> | <!-- Add Screenshots Here --> | <!-- Add Screenshots Here --> |

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: BLoC (Business Logic Component)
- **Audio Engine**: `just_audio` + `audio_service`
- **Storage**: `hive` (Local database)
- **Dependency Injection**: `get_it` + `injectable`

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/Ejre/Music-App-Player.git
    cd Music-App-Player
    ```

2.  Install dependencies:
    ```bash
    flutter pub get
    ```

3.  Run the app:
    ```bash
    flutter run
    ```
