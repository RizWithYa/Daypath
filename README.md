# Daypath 🌙

### Neubrutalist Todo & Prayer Times Application

**Daypath** is a beautifully designed, modern productivity application built with Flutter. It combines a robust Task Management system with Islamic Prayer Times, all wrapped in a striking **Neubrutalism** UI aesthetic.

<p align="center">
  <img src="assets/logo/app_icon.png" width="150" alt="Daypath Logo" style="border-radius: 20px; border: 4px solid #1A1F2B;"/>
</p>

## ✨ Features

- **Neubrutalist UI**: A bold, high-contrast design using "raw" elements, thick borders, and vibrant colors.
- **Prayer Times & Countdown**: Real-time Islamic prayer timings based on your current location with an active countdown to the next prayer.
- **Task Management**: Organize your daily life with a comprehensive task list.
- **Habit Tracking**: Build better routines with the dedicated habits module.
- **Geolocation Integration**: Automatically detects your city and country to provide accurate prayer times.
- **Profile Customization**: Manage your personal user profile within the app.
- **Modern Performance**: Fast, responsive, and optimized for mobile devices.

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
* [Dart SDK](https://dart.dev/get-dart)
* A mobile emulator or physical device (Android/iOS)

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/RizWithYa/RTodolist.git
   cd RTodolist
   ```
2. **Install dependencies:**

   ```bash
   flutter pub get
   ```
3. **Run the application:**

   ```bash
   flutter run
   ```

## 🛠️ Built With

* [Flutter](https://flutter.dev/) - The cross-platform UI framework.
* [Google Fonts](https://pub.dev/packages/google_fonts) - Custom typography (Epilogue, Outfit).
* [Geolocator](https://pub.dev/packages/geolocator) - Real-time location services.
* [Flutter SVG](https://pub.dev/packages/flutter_svg) - High-quality vector graphics.
* [Shared Preferences](https://pub.dev/packages/shared_preferences) - Local data storage.

## 📁 Project Structure

```text
lib/
├── main.dart           # App entry point & Home Page (Prayer Times)
├── tasks_page.dart     # Task Management UI & Logic
├── habits_page.dart    # Habit tracking system
├── profile_page.dart   # User profile management
├── widgets.dart        # Reusable Neubrutalist components (NeuBox, NeuButton)
└── models.dart         # Data structures and models
```

## 🎨 Design Philosophy

Daypath leverages the **Neubrutalism** movement, characterized by:

- Solid dark shadows (hard shadows).
- Bold black borders (#1A1F2B).
- Vibrant background colors (#007BFF, #FFBA24, #FF649C).
- Unfiltered, "raw" typography.

---
