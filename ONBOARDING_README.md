# Interview Preparation App - Onboarding System

This Flutter app now includes a comprehensive onboarding system designed specifically for interview preparation, similar to IndiaBIX. The onboarding experience introduces users to all the key features of the app with beautiful animations and user-friendly design.

## 🚀 Features Implemented

### 1. **Animated Splash Screen**

- Beautiful gradient background with app branding
- Smooth logo animation with scale and fade effects
- Loading indicator with proper timing
- Automatic routing based on onboarding status

### 2. **Interactive Onboarding Screens**

- **5 comprehensive onboarding pages** covering all app features:
  1. **Technical Interviews** - Coding problems and algorithms
  2. **Aptitude Tests** - Quantitative and logical reasoning
  3. **System Design** - Scalability and architecture
  4. **Behavioral Interviews** - STAR method and scenarios
  5. **Progress Tracking** - Analytics and recommendations

### 3. **Advanced Animations**

- **Page transitions** with smooth curves
- **Floating feature badges** that slide in with staggered timing
- **Scale and fade animations** for main icons
- **Gradient backgrounds** with dynamic colors
- **Custom animated indicators** for page progress

### 4. **User Experience Features**

- **Skip functionality** for returning users
- **Smooth navigation** between pages
- **Persistent onboarding state** using SharedPreferences
- **Theme-aware design** supporting light/dark modes
- **Responsive layout** for different screen sizes

## 📱 Onboarding Flow

```
Splash Screen (2.5s) → Check Onboarding Status →
├── First Time User → Onboarding Screens → Home
└── Returning User → Direct to Home
```

## 🎨 Design Elements

### Color Scheme

Each onboarding page has its own thematic color:

- **Technical Interviews**: Blue (#2196F3)
- **Aptitude Tests**: Green (#4CAF50)
- **System Design**: Orange (#FF9800)
- **Behavioral Interviews**: Purple (#9C27B0)
- **Progress Tracking**: Teal (#03DAC6)

### Animation Details

- **Logo Animation**: Scale from 0.5x to 1.0x with elastic curve
- **Fade Animation**: Smooth opacity transition over 1.2s
- **Feature Badges**: Staggered slide-in from right side
- **Page Transitions**: 300ms easeInOut curves
- **Progress Dots**: Smooth scaling and color transitions

## 🛠 Technical Implementation

### Dependencies Added

```yaml
dependencies:
  introduction_screen: ^4.0.0 # Onboarding screen package
  shared_preferences: ^2.2.2 # Persistent storage
```

### File Structure

```
lib/
├── core/
│   ├── models/
│   │   └── onboarding_model.dart      # Data models
│   └── controllers/
│       └── onboarding_controller.dart  # State management
├── feature/
│   ├── splash/
│   │   └── view/
│   │       └── splash_screen.dart     # Animated splash
│   └── onboarding/
│       └── view/
│           └── onboarding_screen.dart # Main onboarding
└── main.dart                          # Updated routing
```

### Key Components

#### 1. **OnboardingPageModel**

```dart
class OnboardingPageModel {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final Color backgroundColor;
  final List<String> features;
}
```

#### 2. **OnboardingController**

- Manages page navigation
- Handles onboarding completion
- Persists user state
- Controls animations

#### 3. **SplashScreen**

- Animated logo and branding
- Checks onboarding status
- Routes to appropriate screen

#### 4. **OnboardingScreen**

- Uses introduction_screen package
- Custom animated widgets
- Feature badge animations
- Theme integration

## 🎯 Interview Preparation Focus

### Content Strategy

Each onboarding page is specifically designed for interview preparation:

1. **Technical Interviews**

   - 500+ coding problems
   - Multiple programming languages
   - Step-by-step solutions
   - Time complexity analysis

2. **Aptitude Tests**

   - Quantitative aptitude
   - Logical reasoning
   - Verbal ability
   - Mock tests available

3. **System Design**

   - Scalability patterns
   - Database design
   - Load balancing
   - Real-world case studies

4. **Behavioral Interviews**

   - STAR method framework
   - Common scenarios
   - Leadership examples
   - Teamwork stories

5. **Progress Tracking**
   - Performance analytics
   - Weakness identification
   - Study recommendations
   - Achievement badges

## 🔧 Customization

### Adding New Pages

```dart
OnboardingPageModel(
  title: "New Feature",
  description: "Description of the feature",
  imagePath: "assets/images/new_feature.png",
  icon: Icons.new_feature,
  backgroundColor: const Color(0xFF123456),
  features: ["Feature 1", "Feature 2", "Feature 3"],
)
```

### Modifying Animations

- Adjust animation durations in `TweenAnimationBuilder`
- Change curve types for different effects
- Modify stagger delays for feature badges
- Customize page transition speeds

### Theme Integration

- All colors use `AppColors` constants
- Supports light/dark theme switching
- Consistent with app-wide design system
- Responsive to system theme changes

## 🚀 Usage

### First Launch

1. App shows animated splash screen
2. Checks if user has seen onboarding
3. Shows onboarding screens for new users
4. Saves completion state
5. Routes to home screen

### Returning Users

1. Splash screen appears briefly
2. Checks onboarding status
3. Directly routes to home screen
4. Skips onboarding process

### Manual Reset

To reset onboarding for testing:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('has_seen_onboarding');
```

## 🎨 Visual Highlights

- **Smooth animations** throughout the experience
- **Professional color scheme** matching interview prep theme
- **Feature badges** that highlight key capabilities
- **Gradient backgrounds** for visual appeal
- **Consistent typography** and spacing
- **Responsive design** for all screen sizes

The onboarding system creates an engaging first impression while effectively communicating the app's value proposition for interview preparation. The animations and design elements work together to create a professional, modern user experience that builds confidence in the app's capabilities.
