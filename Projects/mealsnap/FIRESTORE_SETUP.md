# Firebase Firestore Setup Guide

## 1. Firestore Collection Structure

```
firestore/
├── users/{userId}                          # User profile and settings
│   ├── name: string
│   ├── email: string
│   ├── photoUrl: string (optional)
│   ├── createdAt: timestamp
│   ├── settings: {
│   │   ├── dailyCalorieGoal: number (2000)
│   │   ├── monthlyBudget: number (100000)
│   │   ├── dietaryPreferences: array ["vegetarian", "low-carb"]
│   │   ├── healthGoal: string ("lose_weight", "maintain", "gain_muscle")
│   │   ├── preferredCuisines: array ["african", "international"]
│   │   ├── age: number (optional)
│   │   ├── height: number (optional)
│   │   ├── currentWeight: number (optional)
│   │   └── targetWeight: number (optional)
│   │
│   ├── meals/{mealId}                     # Subcollection of meals
│   │   ├── foodName: string
│   │   ├── calories: number
│   │   ├── protein: number
│   │   ├── carbs: number
│   │   ├── fats: number
│   │   ├── timestamp: timestamp
│   │   ├── imageUrl: string (optional)
│   │   ├── source: string ("camera", "gallery", "receipt", "voice")
│   │   ├── verified: boolean
│   │   └── notes: string (optional)
│   │
│   ├── dailyStats/{YYYY-MM-DD}            # Daily aggregates
│   │   ├── totalCalories: number
│   │   ├── totalSpent: number
│   │   ├── mealCount: number
│   │   ├── protein: number
│   │   ├── carbs: number
│   │   └── fats: number
│   │
│   └── expenses/{expenseId}                # Expense tracking
│       ├── amount: number
│       ├── category: string ("groceries", "restaurant", "snacks")
│       ├── mealId: string (optional)
│       ├── timestamp: timestamp
│       └── description: string (optional)
```

## 2. Firestore Indexes (Required for Performance)

### Index 1: Meals Query
**Collection:** `users/{userId}/meals`

| Field | Type | Direction |
|-------|------|-----------|
| timestamp | Firestore | Descending |

**Query:** Fast recent meals lookup

```dart
db.collection('users')
  .doc(userId)
  .collection('meals')
  .orderBy('timestamp', descending: true)
  .limit(10)
```

---

### Index 2: Meals by Date Range
**Collection:** `users/{userId}/meals`

| Field | Type | Direction |
|-------|------|-----------|
| timestamp | Firestore | Ascending |
| timestamp | Firestore | Descending |

**Query:** Range queries for weekly/monthly stats

```dart
db.collection('users')
  .doc(userId)
  .collection('meals')
  .where('timestamp', isGreaterThanOrEqualTo: startDate)
  .where('timestamp', isLessThanOrEqualTo: endDate)
  .orderBy('timestamp', descending: true)
```

---

### Index 3: Expenses by Date Range
**Collection:** `users/{userId}/expenses`

| Field | Type | Direction |
|-------|------|-----------|
| timestamp | Firestore | Descending |

**Query:** Monthly spending analysis

```dart
db.collection('users')
  .doc(userId)
  .collection('expenses')
  .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
  .where('timestamp', isLessThanOrEqualTo: endOfMonth)
```

---

## 3. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Allow authenticated users to access their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Meals subcollection
      match /meals/{mealId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Daily stats subcollection
      match /dailyStats/{date} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Expenses subcollection
      match /expenses/{expenseId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Deny access to anything else
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**How it works:**
- Users can only read/write their own documents
- Subcollection rules inherit parent permissions
- All other access is denied

## 4. Setup Steps in Firebase Console

### Step 1: Create Cloud Firestore Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Select "Start in test mode" (for development)
   - **WARNING:** Change to production mode before deploying!
4. Choose region (preferably close to your users)

### Step 2: Create Indexes
1. Go to Firestore → Indexes
2. Create composite indexes for:
   - meals query (timestamp)
   - expenses query (timestamp)
3. Create other indexes as Firestore suggests during development

### Step 3: Set Security Rules
1. Go to Firestore → Rules
2. Replace default rules with the security rules above
3. Click "Publish"

### Step 4: Enable Authentication
1. Go to Firebase → Authentication
2. Enable Email/Password
3. Enable Google Sign-In
4. Copy Web Client ID to your Android/iOS configs

## 5. Performance Optimization Tips

### A. Use Batch Writes for Multiple Operations
```dart
// Instead of individual writes
for (var meal in meals) {
  await db.collection('users').doc(userId).collection('meals').add(meal);
}

// Use batch write
final batch = db.batch();
for (var meal in meals) {
  final ref = db.collection('users').doc(userId).collection('meals').doc();
  batch.set(ref, meal);
}
await batch.commit(); // Single operation
```

### B. Cache Frequently Accessed Data
```dart
// Cache user settings locally
final prefs = await SharedPreferences.getInstance();
await prefs.setString('userSettings', jsonEncode(settings.toMap()));
```

### C. Use Pagination for Large Lists
```dart
// Instead of fetching all meals
final meals = await db.collection('users').doc(userId)
  .collection('meals')
  .limit(10)  // Fetch 10 at a time
  .get();
```

### D. Create Aggregate Documents
```dart
// Update daily stats instead of querying all meals
await db.collection('users').doc(userId)
  .collection('dailyStats').doc(dateStr)
  .set({totalCalories: FieldValue.increment(calories)}, merge: true);
```

## 6. Monitoring & Troubleshooting

### Check Firestore Usage
Firebase Console → Firestore → Usage tab

**Warning signs:**
- High read count → Add indexes, use caching
- High write count → Use batch writes, aggregate data
- High data storage → Archive old data, delete unused records

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "permission-denied" | Wrong security rules | Check security rules |
| "index-not-found" | Missing composite index | Create index in console |
| "not-found" | Wrong collection path | Verify collection structure |
| "deadline-exceeded" | Query too slow | Add indexes, optimize query |

## 7. Dart Integration in Code

### Basic Setup
```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';
import 'models/firebase_models.dart';

// Use the service
final db = FirestoreService();

// Create a user
await db.setUser(userId, UserModel(
  id: userId,
  email: email,
  name: name,
  createdAt: DateTime.now(),
  settings: UserSettings(),
));

// Add a meal
await db.addMeal(userId, MealModel(
  id: '',
  userId: userId,
  foodName: 'Rice and Beans',
  calories: 350,
  protein: 12,
  carbs: 50,
  fats: 8,
  timestamp: DateTime.now(),
  source: 'camera',
));
```

## 8. Testing the Setup

### Run Integration Tests
```bash
flutter test --integration
```

### Manual Testing Checklist
- [ ] User can create account and save profile
- [ ] Meals appear in Firestore after logging
- [ ] Daily stats update automatically
- [ ] Monthly spending calculates correctly
- [ ] Queries return data in < 1 second
- [ ] Offline mode caches data locally

## 9. Before Going to Production

- [ ] Change Firestore from test mode to production rules
- [ ] Review and optimize all indexes
- [ ] Set backup schedule
- [ ] Implement data retention policies
- [ ] Test error handling and fallbacks
- [ ] Monitor initial usage patterns
- [ ] Set up alerts for unusual activity

