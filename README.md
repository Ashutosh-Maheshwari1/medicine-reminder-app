<div align="center">
  <img src="assets/icons/Icon-192.png" width="120" height="120" alt="MediTrack AI Logo" />
  <h1>💊 MediTrack AI</h1>
  <p><b>State-of-the-Art Smart Medicine Reminder & Health Analytics System</b></p>

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Integrated-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)](https://flutter.dev)

  <br />
</div>

---

## 🌟 Overview

**MediTrack AI** is a premium, cross-platform health application designed to simplify medication scheduling, track daily adherence, provide actionable AI-driven health tips, and generate downloadable medical reports.

Built using **Flutter**, **Riverpod**, **Firebase Cloud Firestore**, and **Flutter Local Notifications**, MediTrack AI ensures users never miss a dose through exact background notifications, custom sound effects, and intuitive gesture controls.

---

## ✨ Key Features

### 💊 1. Smart Medicine Reminders & Sound Effects
- **Scheduled Local Alerts**: Receive pinpoint notification reminders for medicine time slots even offline.
- **Notification Action Buttons**: Complete actions directly from your notification drawer (**Take**, **Snooze 10 Min**, or **Dismiss**).
- **Custom Audio Effects**: Plays satisfaction drinking sound effects upon marking doses as taken.

### 📱 2. Interactive Medicine Management
- **3-Dot Action Menu**: Pause/Resume, Edit, or Delete medicines easily.
- **Swipe Gestures**: Swipe left to delete or swipe right to edit instantly.
- **Flexible Scheduling**: Supports daily, weekly, or specific meal-based timings (Before Meal / After Meal).

### 📄 3. Medical History & PDF Export
- **Adherence Analytics**: Interactive weekly and monthly adherence charts powered by `fl_chart`.
- **PDF Report Generation**: Export complete medication logs into professional PDF documents ready for doctor visits.

### 🌐 4. Multilingual & Theme Customization
- **App-Wide Language Toggle**: Supports seamless switching between **English** and **Hindi (हिन्दी)**.
- **Dynamic Dark Mode**: Sleek glassmorphism UI supporting dark and light themes with custom HSL palettes.

### 🔐 5. Secure Authentication & Sync
- **Firebase Auth**: Secure Email/Password registration and **Google Sign-In** OAuth integration.
- **Realtime Cloud Firestore**: Encrypted cloud database synchronization across devices.

---

## 📸 Screenshots & Preview

| Home Dashboard | Add Medicine | Profile & Analytics |
| :---: | :---: | :---: |
| *(Dashboard with daily progress & next reminder)* | *(Schedule dosages, frequencies & alerts)* | *(Adherence stats, PDF Export & Language settings)* |

---

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod)
- **Backend & Auth**: Firebase Core, Firebase Auth, Cloud Firestore
- **Local Notifications**: `flutter_local_notifications` + `timezone`
- **PDF Generation**: `pdf` + `printing`
- **Audio Playback**: `audioplayers`
- **Design System**: Material 3, Google Fonts (Outfit), Custom Vanilla CSS & Animations

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.19.0 or higher)
- Android Studio / VS Code
- Java JDK 17 or JDK 21
- Android device or emulator (API 23+)

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Ashutosh-Maheshwari1/medicine-reminder-app.git
   cd medicine-reminder-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Ensure `google-services.json` is placed in `android/app/`.
   - Add SHA-1 fingerprint in Firebase Console for Google Sign-In.

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 📦 Building Releases

### Android APK
To generate a standalone APK to share or install on devices:
```bash
flutter build apk --release
```
The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

### Web App
To build for web deployment:
```bash
flutter build web
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/Ashutosh-Maheshwari1/medicine-reminder-app/issues).

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>Made with ❤️ for better health and adherence.</p>
</div>
