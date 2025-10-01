# AptiMaster - Theme Setup

This Flutter app has been configured with a comprehensive theme system that includes both light and dark themes with consistent colors and styling throughout the application.

## Theme Structure

### Files Created/Modified:

1. **`lib/core/theme/app_colors.dart`** - Color constants and gradients
2. **`lib/core/theme/app_theme.dart`** - Light and dark theme configurations
3. **`lib/core/controllers/theme_controller.dart`** - Theme switching controller
4. **`lib/main.dart`** - Updated to use theme system
5. **`lib/feature/home/view/home_page.dart`** - Demo page showing theme usage

## Color Palette

### Primary Colors

- **Primary**: Blue (#2196F3)
- **Primary Dark**: Darker Blue (#1976D2)
- **Primary Light**: Lighter Blue (#64B5F6)

### Secondary Colors

- **Secondary**: Teal (#03DAC6)
- **Secondary Dark**: Darker Teal (#018786)
- **Secondary Light**: Lighter Teal (#66FFF9)

### Accent Colors

- **Accent**: Orange (#FF9800)
- **Accent Dark**: Darker Orange (#F57C00)
- **Accent Light**: Lighter Orange (#FFB74D)

### Status Colors

- **Success**: Green (#4CAF50)
- **Warning**: Orange (#FF9800)
- **Error**: Red (#F44336)
- **Info**: Blue (#2196F3)

### Background Colors

- **Background**: Light Gray (#F5F5F5)
- **Surface**: White (#FFFFFF)
- **Surface Dark**: Dark (#121212)

### Text Colors

- **Primary Text**: Dark Gray (#212121)
- **Secondary Text**: Medium Gray (#757575)
- **Hint Text**: Light Gray (#BDBDBD)
- **Text on Primary**: White (#FFFFFF)

## Theme Features

### Light Theme

- Clean, modern design with light backgrounds
- High contrast text for readability
- Subtle shadows and elevations
- Professional color scheme

### Dark Theme

- Dark backgrounds with light text
- Reduced eye strain in low-light conditions
- Consistent with Material Design 3 guidelines
- Automatic system theme detection

### Components Themed

- AppBar with consistent styling
- Cards with rounded corners and shadows
- Buttons (Elevated, Outlined, Text)
- Input fields with proper focus states
- Bottom navigation bar
- Floating action button
- Text styles with proper hierarchy
- Icons with consistent sizing

## Usage

### Using Colors in Your Code

```dart
import 'package:aptimaster/core/theme/app_colors.dart';

// Use predefined colors
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.textOnPrimary),
  ),
)

// Use gradients
Container(
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
  ),
)
```

### Using Theme Styles

```dart
// Use theme text styles
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
)

// Use theme colors
Container(
  color: Theme.of(context).colorScheme.primary,
)
```

### Theme Switching

The app includes a theme controller that allows switching between light and dark themes:

```dart
// Toggle theme
Get.find<ThemeController>().toggleTheme();

// Set specific theme mode
Get.find<ThemeController>().setThemeMode(ThemeMode.dark);
```

## Customization

### Adding New Colors

Add new colors to `app_colors.dart`:

```dart
static const Color customColor = Color(0xFF123456);
```

### Modifying Theme Components

Update the theme configurations in `app_theme.dart`:

```dart
// Modify button theme
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.customColor,
    // ... other properties
  ),
),
```

### Adding Custom Text Styles

Add custom text styles to the theme:

```dart
textTheme: const TextTheme(
  // ... existing styles
  customStyle: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  ),
),
```

## Best Practices

1. **Always use theme colors** instead of hardcoded colors
2. **Use semantic color names** (primary, secondary, error, etc.)
3. **Test both light and dark themes** for all components
4. **Maintain consistency** across all screens
5. **Use theme-aware components** when possible

## Demo

The home page (`lib/feature/home/view/home_page.dart`) demonstrates various theme components including:

- Welcome section with gradient background
- Different button types
- Card layouts
- Input fields
- Status color indicators
- Theme toggle functionality

Run the app to see the theme in action and test the light/dark mode switching!
