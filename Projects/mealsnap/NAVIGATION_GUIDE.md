# MealSnap+ Navigation & Routing Guide

## Current Navigation Architecture

The app uses a **Bottom Navigation Bar** approach with 5 main sections:

```
┌─────────────────────────────────────┐
│  Home | Analytics | Scan | Suggest | Profile │
└─────────────────────────────────────┘
```

---

## Screen Navigation Map

### 1. **Home Screen** (HomeContent)
- **Route**: Index 0 (Default)
- **Components**:
  - Greeting section
  - Nutrition tracking card
  - Quick action buttons
  - Suggested meal card
  - Recent activity feed

### 2. **Analytics Screen** (AnalyticsScreen)
- **Route**: Index 1
- **Tabs**:
  - Nutrition tab: 7-day calorie intake chart
  - Financial tab: Budget tracking
- **Features**:
  - Weekly average calculation
  - Export to PDF

### 3. **Meal Suggestions Screen** (MealSuggestionsScreen)
- **Route**: Index 2 (labeled "Scan" in bottom nav)
- **Features**:
  - Selected ingredients chips
  - Meal recommendations with match percentage
  - Add to meal plan button

### 4. **Suggestions/Recommendations** (Index 3)
- **Route**: Index 3 (labeled "Suggest")
- **Note**: Currently uses MealSuggestionsScreen as placeholder
- **TODO**: Create dedicated SuggestionsScreen

### 5. **Profile Screen** (ProfileScreen)
- **Route**: Index 4 (Default)
- **Sections**:
  - Profile header
  - Health goals
  - Dietary preferences
  - Settings menu
  - Logout button

---

## Screen Structure File Organization

```
lib/
├── main.dart                          # App entry point & navigation hub
├── firebase_config.dart               # Firebase initialization
├── firebase_options.dart              # Auto-generated Firebase config
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart         # TODO: Integrate with Firebase
│   │   └── signup_screen.dart        # TODO: Integrate with Firebase
│   ├── profile_screen.dart           # Profile & settings
│   ├── analytics_screen.dart         # Analytics & dashboard
│   └── meal_suggestions_screen.dart  # Meal recommendations
├── models.dart                        # Data models
└── logic.dart                         # Business logic
```

---

## Future Routing Enhancement: GoRouter Setup

For more advanced routing (not currently implemented), here's how to set up GoRouter:

### 1. Update main.dart

```dart
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: 'suggestions',
          builder: (context, state) => const MealSuggestionsScreen(),
        ),
      ],
    ),
  ],
);

void main() {
  runApp(const MealSnapApp());
}

class MealSnapApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      // ... other config
    );
  }
}
```

### 2. Navigation Examples

```dart
// Navigate to Profile
context.go('/home/profile');

// Navigate with parameters
context.go('/meal-details/12345');

// Go back
context.pop();

// Replace route
context.replace('/home');
```

---

## Current Navigation Usage

### Bottom Navigation Bar

```dart
void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });
}

BottomNavigationBar(
  items: const <BottomNavigationBarItem>[
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
    BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scan'),
    BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Suggest'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
)
```

---

## Authentication Flow (To Be Implemented)

```
┌─────────────────────────────────────────┐
│  Launch App                             │
│  (Check Firebase Auth Status)           │
└────────────────┬────────────────────────┘
                 │
         ┌───────┴─────────┐
         │                 │
    ✅ Logged In      ❌ Not Logged In
         │                 │
         ├────────────┐    └─► LoginScreen/SignUpScreen
         │            │              │
    HomePage       Any Other    ┌────┴─────────┐
    (Bottom Nav)    Screen      │              │
                              Google      Email/Password
                              Sign-In     Sign-In
```

### Implementation Steps

1. **Check Authentication State in main()**
   ```dart
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await FirebaseConfig.init();
     
     User? user = FirebaseAuth.instance.currentUser;
     
     runApp(MealSnapApp(isLoggedIn: user != null));
   }
   ```

2. **Show Login/Home based on auth state**
   ```dart
   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       home: isLoggedIn ? const HomePage() : const LoginScreen(),
     );
   }
   ```

3. **Update LoginScreen**
   ```dart
   Future<void> _login() async {
     try {
       await FirebaseAuth.instance.signInWithEmailAndPassword(
         email: _emailController.text,
         password: _passwordController.text,
       );
       // Navigate to home
       if (mounted) Navigator.of(context).pushReplacementNamed('/home');
     } catch (e) {
       // Show error
     }
   }
   ```

---

## Navigation Best Practices

### 1. **Use Named Routes**
```dart
Navigator.pushNamed(context, '/profile');
```

### 2. **Handle Back Button**
```dart
WillPopScope(
  onWillPop: () async {
    // Handle back navigation
    return true; // Allow back
  },
  child: Scaffold(...),
)
```

### 3. **Pass Data Between Screens**
```dart
// Option 1: Using arguments
Navigator.pushNamed(
  context,
  '/meal-details',
  arguments: {'mealId': 123},
);

// Option 2: Using models
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(meal: meal),
  ),
);
```

### 4. **Deep Linking (Future)**
```dart
// android/app/AndroidManifest.xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="mealsnap" android:host="app" />
</intent-filter>
```

---

## Screens Checklist

| Screen | Status | Firebase Integration | Notes |
|--------|--------|----------------------|-------|
| Home | ✅ Complete | Pending | Main dashboard |
| Analytics | ✅ Complete | Pending | Charts & metrics |
| Meal Suggestions | ✅ Complete | Pending | Recommendations |
| Profile | ✅ Complete | Pending | User settings |
| Login | ✅ UI Ready | ❌ TODO | Email/Google auth |
| Sign Up | ✅ UI Ready | ❌ TODO | User registration |
| Scan | ⚠️ Placeholder | ❌ TODO | Camera integration |
| Settings | ⚠️ Partial | ❌ TODO | App preferences |

---

## Next Implementation Steps

1. **Implement Authentication**
   - [ ] Complete LoginScreen Firebase integration
   - [ ] Complete SignUpScreen Firebase integration
   - [ ] Add authentication state management

2. **Implement Navigation Transitions**
   - [ ] Add page transitions/animations
   - [ ] Implement deep linking

3. **Create Missing Screens**
   - [ ] Scan screen (camera + ML Kit OCR)
   - [ ] Settings screen

4. **Add State Management**
   - [ ] Consider Provider package (already in pubspec)
   - [ ] Implement auth state provider
   - [ ] Implement meal data provider

---

## File References

- **Main Navigation**: `lib/main.dart`
- **Auth Screens**: `lib/screens/auth/`
- **Other Screens**: `lib/screens/`
- **Navigation Config**: (Currently in main.dart, can be extracted to router.dart)
