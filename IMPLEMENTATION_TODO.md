# 🚀 MealSnap+ MVP — Implementation Roadmap

**Total Estimated Time:** 36-46 hours  
**Priority Order:** By dependency and core value  
**Last Updated:** April 14, 2026

---

## 📋 Priority Implementation Order

### 🔴 **FOUNDATION TASKS** (Must do first)

#### **[✅] PRIORITY 1: Firebase Models for Fast Data Access**

- **Status:** COMPLETED ✅
- **Time Estimate:** 4-5 hours
- **Why First:** Everything depends on this data structure
- **Subtasks:**
  - [x] Create Firestore structure for users collection (email, name, settings)
  - [x] Create meals subcollection with indexes (foodName, calories, timestamp)
  - [x] Create dailyStats subcollection for aggregates
  - [x] Set up Firestore indexes for fast queries
  - [x] Create Dart models matching Firestore structure
  - [x] Implement batch write for performance
- **Dependencies:** None
- **Blocks:** Tasks 3, 4, 6, 7, 8, 10, 11
- **Completion Date:** April 16, 2026

**Files Created:**
- `lib/models/firebase_models.dart` — 4 model classes (UserModel, MealModel, DailyStatsModel, ExpenseModel) with Firestore serialization
- `lib/services/firestore_service.dart` — Complete Firestore service with CRUD operations, batch writes, and aggregations
- `FIRESTORE_SETUP.md` — Setup guide with collection structure, indexes, security rules, and optimization tips

---

#### **[✅] PRIORITY 2: Calories Tracker with Macros Breakdown**

- **Status:** COMPLETED ✅
- **Time Estimate:** 3-4 hours
- **Why Second:** Core value proposition
- **Subtasks:**
  - [x] Create NutritionCard widget showing calories + macros
  - [x] Implement macro percentage calculations
  - [x] Add progress indicators for protein/carbs/fats
  - [x] Create nutrition lookup table (local JSON or Firestore)
  - [x] Wire up to meal data from Firestore
  - [x] Add visual indicators (color-coded bars)
- **Dependencies:** Priority 1 ✅
- **Blocks:** Tasks 3, 4, 6, 8
- **Completion Date:** April 16, 2026

**Files Created:**
- `lib/widgets/nutrition_card.dart` — NutritionCard & NutritionCompactCard widgets with macro bars, color-coded progress, and smart recommendations
- `lib/widgets/nutrition_sections.dart` — Helper widgets (DailyNutritionSection, WeeklyNutritionSummary, MealNutritionPreview) for real-time Firestore integration
- `lib/screens/home_screen_example.dart` — Complete example showing how to integrate nutrition widgets into home screen with FutureBuilder patterns

---

#### **[✅] PRIORITY 3: Recent Activities Feed on Home Screen**

- **Status:** COMPLETED ✅
- **Time Estimate:** 3-4 hours
- **Why Third:** Makes home screen functional and engaging
- **Subtasks:**
  - [x] Create query for last 7 days of meals
  - [x] Build MealHistoryItem widget
  - [x] Implement ListView with Firestore data
  - [x] Add "See all" navigation to full history
  - [x] Add quick actions (camera, gallery buttons)
  - [x] Handle empty state (no meals yet)
- **Dependencies:** Priority 1 ✅, 2 ✅
- **Blocks:** Tasks 4, 6, 10
- **Completion Date:** April 16, 2026

**Files Created:**
- `lib/widgets/meal_history_item.dart` — MealHistoryItem & MealHistoryItemCompact widgets with full meal card display, macro breakdown, source icons, and delete/edit actions
- `lib/screens/history_screen.dart` — Full HistoryScreen with date filtering (7/30/90/365 days), meal grouping by date, daily totals, and meal deletion
- `lib/widgets/recent_activities_section.dart` — RecentActivitiesSection widget for embedding in home screen with compact and full view options
- `lib/screens/home_screen_example.dart` — Updated with RecentActivitiesSection integration and navigation to HistoryScreen

---

### 🟡 **CORE FEATURES** (High value)

#### **[ ] PRIORITY 4: Extended Profile Settings & Health Goals**

- **Status:** Not Started
- **Time Estimate:** 4-5 hours
- **Why Fourth:** Users need to set preferences
- **Subtasks:**
  - [ ] Create health information fields (age, height, weight, target weight)
  - [ ] Add dietary preferences checkboxes (vegetarian, vegan, low-carb, no-pork)
  - [ ] Implement health goal selector (lose_weight, maintain, gain_muscle)
  - [ ] Add daily calorie goal input
  - [ ] Add monthly budget input
  - [ ] Create profile photo upload
  - [ ] Wire up Firestore save/load
  - [ ] Add validation for health metrics
- **Dependencies:** Priority 1
- **Blocks:** Tasks 6, 7, 10, 11

---

#### **[ ] PRIORITY 5: AI-Generated Suggestions from Preferences & Habits**

- **Status:** Not Started
- **Time Estimate:** 4-5 hours
- **Why Fifth:** Differentiator feature
- **Subtasks:**
  - [ ] Query user's top 5 most frequent meals (last 30 days)
  - [ ] Get user dietary preferences from settings
  - [ ] Implement suggestion logic (low-carb alternatives, variation suggestions)
  - [ ] Create SuggestionService class
  - [ ] Build suggestion UI cards
  - [ ] Add "suggested for you" section to home screen
  - [ ] Implement caching for suggestion results
- **Dependencies:** Priority 1, 3, 4
- **Blocks:** Task 10

---

#### **[ ] PRIORITY 6: Financial Tracking with Spending Analysis**

- **Status:** Not Started
- **Time Estimate:** 4-5 hours
- **Why Sixth:** Unique differentiator
- **Subtasks:**
  - [ ] Create expense model (amount, category, timestamp, mealId)
  - [ ] Implement addExpense() to Firestore
  - [ ] Create daily aggregate updates for spending
  - [ ] Build monthly spending query
  - [ ] Calculate spending by category breakdown
  - [ ] Show remaining budget calculation
  - [ ] Create spending visualization (charts)
  - [ ] Add expense history view
- **Dependencies:** Priority 1, 2
- **Blocks:** Task 8

---

### 🟢 **ENHANCEMENTS** (Polish & optimization)

#### **[ ] PRIORITY 7: Camera Smart Settings**

- **Status:** Not Started
- **Time Estimate:** 5-6 hours
- **Why Seventh:** Improves AI accuracy
- **Subtasks:**
  - [ ] Implement auto-focus toggle
  - [ ] Add grid overlay toggle
  - [ ] Implement flash control
  - [ ] Add image optimization/compression before sending to AI
  - [ ] Create CameraGridOverlay widget
  - [ ] Implement resolution presets
  - [ ] Add camera focus mode controls
  - [ ] Create smart camera screen with controls
- **Dependencies:** None (independent)
- **Blocks:** None

---

#### **[ ] PRIORITY 8: Analytics Screen Settings (Budget & Weight Tracking)**

- **Status:** Not Started
- **Time Estimate:** 3-4 hours
- **Why Eighth:** UI cleanup (remove profile icon from analytics)
- **Subtasks:**
  - [ ] Add settings icon to analytics appbar
  - [ ] Create analytics settings dialog
  - [ ] Implement budget input field
  - [ ] Implement current weight input
  - [ ] Implement target weight input
  - [ ] Create weight progress card
  - [ ] Wire up Firestore save/load
  - [ ] Remove profile icon from analytics view
- **Dependencies:** Priority 1, 4
- **Blocks:** None

---

#### **[ ] PRIORITY 9: Remove Settings Icon from Home View**

- **Status:** Not Started
- **Time Estimate:** 5 minutes
- **Quick Win:** Minimal effort
- **Subtasks:**
  - [ ] Remove settings icon from home appbar
  - [ ] Verify settings are accessible from profile page
  - [ ] Test navigation flow
- **Dependencies:** Priority 4
- **Blocks:** None

---

#### **[ ] PRIORITY 10: Expand Food Database (Local + International)**

- **Status:** Not Started
- **Time Estimate:** 2-3 hours
- **Why Last:** Works with current limited database initially
- **Subtasks:**
  - [ ] Extend local food keywords in recognition service
  - [ ] Add international foods to database
  - [ ] Create category field (african, international, fastfood)
  - [ ] Build nutrition lookup for 100+ common foods
  - [ ] Test recognition with diverse food images
  - [ ] Document food database sources
- **Dependencies:** All others (can work in parallel but most useful after others done)
- **Blocks:** None

---

#### **[ ] PRIORITY 11: Preferences & Habits in Settings**

- **Status:** Not Started
- **Time Estimate:** 4-5 hours
- **Why Secondary:** Complements Priority 4
- **Subtasks:**
  - [ ] Create settings screen with preferences
  - [ ] Implement toggle for low-carb preference
  - [ ] Implement health goal dropdown
  - [ ] Add dietary restrictions toggles
  - [ ] Create cuisine preference selector
  - [ ] Wire up preference-based suggestions (Priority 5)
  - [ ] Add save/load from Firestore
- **Dependencies:** Priority 1, 4
- **Blocks:** None

---

## 📊 Task Dependency Map

```
Priority 1: Firebase Models ────────────────┐
                                            ├─→ Priority 3: Recent Activities
Priority 2: Calories Tracker ───────────────┤
                                            ├─→ Priority 5: AI Suggestions
Priority 4: Profile Settings ──────────────┤
                                            ├─→ Priority 6: Financial Tracking
                                            └─→ Priority 8: Analytics Settings

Priority 7: Camera Settings (Independent)
Priority 9: Remove Settings Icon (Depends on Priority 4)
Priority 10: Expand Food Database (Can be done anytime)
Priority 11: Preferences in Settings (Depends on Priority 4)
```

---

## ⏱️ Time Breakdown

| Priority | Task | Hours | Status |
|----------|------|-------|--------|
| 1 | Firebase Models | 4-5 | ⬜ Not Started |
| 2 | Calories Tracker | 3-4 | ⬜ Not Started |
| 3 | Recent Activities | 3-4 | ⬜ Not Started |
| 4 | Profile Settings | 4-5 | ⬜ Not Started |
| 5 | AI Suggestions | 4-5 | ⬜ Not Started |
| 6 | Financial Tracking | 4-5 | ⬜ Not Started |
| 7 | Camera Settings | 5-6 | ⬜ Not Started |
| 8 | Analytics Settings | 3-4 | ⬜ Not Started |
| 9 | Remove Settings Icon | 0.1 | ⬜ Not Started |
| 10 | Expand Food Database | 2-3 | ⬜ Not Started |
| 11 | Preferences Settings | 4-5 | ⬜ Not Started |
| **TOTAL** | | **36-46** | |

---

## 🎯 Current Progress

**Completed:**

- ✅ Fixed linting issues
- ✅ Enhanced local recognition service with African dishes
- ✅ Created nutrition database service
- ✅ Created meal suggestion service
- ✅ Integrated Gemini AI for enhanced food analysis
- ✅ Implemented basic food recognition pipeline

**Next:**

- ⬜ Start with Priority 1: Firebase Models

---

## 📝 Notes for Implementation

1. **Testing:** Each priority should be tested before moving to next
2. **Git Commits:** Make a commit after completing each priority
3. **Documentation:** Update README with new features after each priority
4. **Performance:** Prioritize Firestore indexes for queries
5. **Error Handling:** Add proper error handling for Firestore operations
6. **User Feedback:** Show loading states during async operations

---

## 🚀 How to Use This List

1. When you're ready to implement a priority, I'll expand the subtasks
2. I'll create code examples for each subtask
3. We'll implement and test each one
4. Update status as we complete items: ⬜ → 🟨 → ✅
5. When a priority is done, move to the next one
