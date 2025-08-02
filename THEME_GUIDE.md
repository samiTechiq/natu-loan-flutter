# Staff Loan Management App

A Flutter application for managing staff loans with a beautiful theme system supporting both light and dark modes.

## Theme System

### Features

- **Complete Theme Support**: Both light and dark themes with purple as the primary color
- **Persistent Storage**: Theme preference is saved using GetStorage
- **System UI Integration**: Status bar and navigation bar colors automatically adjust
- **GetX Integration**: Reactive theme switching using GetX state management

### Theme Components

#### Colors

- **Primary Purple**: `#6A4C93` - Used for AppBar, buttons, and primary elements
- **Light Purple**: `#8B68B3` - Used for secondary elements and accents
- **Dark Purple**: `#4A3269` - Used for darker variants

#### Light Theme

- Background: `#FAFAFA`
- Surface: `#FFFFFF`
- Card Background: `#FFFFFF`
- Text Primary: `#1D1D1D`
- Text Secondary: `#757575`

#### Dark Theme

- Background: `#121212`
- Surface: `#1E1E1E`
- Card Background: `#2D2D2D`
- Text Primary: `#FFFFFF`
- Text Secondary: `#B3B3B3`

### Usage

#### Accessing Theme Controller

```dart
final themeController = Get.find<ThemeController>();
```

#### Toggle Theme

```dart
themeController.toggleTheme();
```

#### Check Current Theme

```dart
bool isDark = themeController.isDarkMode.value;
```

#### Get Current Theme Data

```dart
ThemeData currentTheme = themeController.currentTheme;
```

### File Structure

```
lib/
├── controllers/
│   └── theme_controller.dart    # Theme management logic
├── screens/
│   └── home_screen.dart        # Demo screen showing theme features
├── utils/
│   └── constants.dart          # App constants
└── main.dart                    # App entry point
```

### Dependencies

- `get: ^4.6.6` - State management
- `get_storage: ^2.1.1` - Persistent storage

### Getting Started

1. Install dependencies:

```bash
flutter pub get
```

2. Run the app:

```bash
flutter run
```

3. Toggle between themes using:
   - The moon/sun icon in the AppBar
   - The switch in the Theme Settings card

### Customization

To customize the theme colors, modify the `AppColors` class in `lib/controllers/theme_controller.dart`:

```dart
class AppColors {
  // Change these values to customize your theme
  static const Color primaryPurple = Color(0xFF6A4C93);
  static const Color primaryPurpleLight = Color(0xFF8B68B3);
  static const Color primaryPurpleDark = Color(0xFF4A3269);
  // ... other colors
}
```

### Next Steps

This is the foundation for the staff loan management system. Future features will include:

- User authentication
- Loan management
- Employee management
- Reports and analytics
- Settings and preferences

The theme system is fully implemented and ready to be used throughout the application development process.
