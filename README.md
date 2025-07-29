# Listify - Beautiful Todo App

A beautiful and efficient Flutter todo list app designed to help you stay organized and productive. Built with modern Material Design 3 principles and local data persistence.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

## ✨ Features

### Core Functionality
- ✅ **Create, Read, Update, Delete** todos with ease
- 🎯 **Priority Levels** - Low, Medium, High with color coding
- 📅 **Due Dates** - Set optional due dates with visual indicators
- ✔️ **Mark as Complete** - Toggle completion status
- 🗑️ **Swipe to Delete** - Intuitive gesture-based deletion
- 💾 **Local Storage** - Data persists using SQLite database

### User Experience
- 🎨 **Material Design 3** - Modern, beautiful UI
- 🌙 **Dark/Light Mode** - Automatic theme switching
- 📊 **Statistics Dashboard** - Track your productivity
- 🔍 **Search & Filter** - Find tasks quickly
- 📱 **Responsive Design** - Works on all screen sizes
- ⚡ **Fast Performance** - Smooth animations and interactions

### Advanced Features
- 🏷️ **Priority-based Color Coding** - Visual task organization
- 📈 **Progress Tracking** - See completed vs pending tasks
- 🔄 **State Management** - Efficient Provider pattern
- 💾 **Persistent Data** - SQLite local database
- 🎯 **Smart Due Date Indicators** - Overdue, due today, due soon

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.1.0 or higher)
- Dart SDK (3.1.0 or higher)
- Android Studio / VS Code
- Android device or emulator / iOS Simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/listify.git
   cd listify
   ```

2. **Navigate to the app directory**
   ```bash
   cd listify_app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

### Adding Tasks
1. Tap the floating **"Add Task"** button
2. Enter a task title (required)
3. Add an optional description
4. Set priority level (Low/Medium/High)
5. Optionally set a due date
6. Tap **"Create Task"** to save

### Managing Tasks
- **Complete Task**: Tap the circular checkbox
- **Edit Task**: Tap on any task card
- **Delete Task**: Swipe left on a task
- **View Statistics**: Check the stats bar at the top

### Additional Actions
- **Clear Completed**: Use the menu (⋮) → "Clear Completed"
- **Clear All**: Use the menu (⋮) → "Clear All"

## 🏗️ Architecture

The app follows clean architecture principles with a clear separation of concerns:

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget
├── models/
│   └── todo_item.dart        # Data model
├── providers/
│   └── item_provider.dart    # State management
├── screens/
│   └── add_item_screen.dart  # Add/Edit screen
└── widgets/
    ├── todo_item_card.dart   # Task card widget
    └── empty_state.dart      # Empty state widget
```

### Key Components

- **State Management**: Provider pattern for reactive state updates
- **Local Storage**: SQLite database for data persistence  
- **UI Components**: Custom widgets following Material Design 3
- **Data Layer**: Repository pattern with model classes

## 🛠️ Dependencies

### Core Dependencies
- `flutter` - UI framework
- `provider` - State management
- `sqflite` - Local SQLite database
- `google_fonts` - Beautiful typography

### UI & UX
- `flutter_slidable` - Swipe gestures
- `intl` - Date formatting
- `cupertino_icons` - iOS-style icons

### Utilities
- `uuid` - Unique ID generation
- `path` - File path utilities
- `shared_preferences` - Simple key-value storage

## 🎨 Design System

### Color Palette
- **Primary**: Indigo (#6366F1)
- **Secondary**: Dynamic based on system
- **Priority Colors**:
  - High: Red (#EF4444)
  - Medium: Orange (#F97316) 
  - Low: Green (#22C55E)

### Typography
- **Font**: Inter (via Google Fonts)
- **Scale**: Material Design 3 type scale

## 📂 Project Structure

```
listify_app/
├── android/           # Android-specific files
├── ios/              # iOS-specific files  
├── lib/              # Dart source code
├── assets/           # Images, icons, fonts
├── test/             # Unit tests
├── pubspec.yaml      # Dependencies & metadata
└── README.md         # This file
```

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 🚀 Building for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- The open-source community for inspiration

## 📞 Contact

- **Email**: your.email@example.com
- **GitHub**: [@yourusername](https://github.com/yourusername)
- **LinkedIn**: [Your Name](https://linkedin.com/in/yourname)

---

Made with ❤️ and Flutter