# Search Hamburger Lock Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the search screen's hamburger (mentor/student mode) icon always visible, with the "A Student to Mentor" option shown but locked (greyed out, lock icon, tooltip, snackbar) for users who haven't signed up as a mentor.

**Architecture:** Single-file UI change in `lib/screens/search_screen.dart`. `isMentorProvider` (a plain `Provider<bool>`, already in the codebase) is read once when the mode-picker bottom sheet opens to decide whether the student-mode `ListTile` renders locked or interactive. No provider, model, or navigation changes.

**Tech Stack:** Flutter, flutter_riverpod (`ConsumerStatefulWidget` / `ProviderScope` overrides for tests), flutter_test.

## Global Constraints

- Locked-option message text is exactly: `Sign up as a mentor to unlock this` (used for both the `Tooltip` and the snackbar, per the approved spec).
- Tapping the locked option must NOT change `_mode` and must NOT close the bottom sheet.
- Tapping the locked option must NOT navigate anywhere (explicitly out of scope per spec).
- Spec reference: `docs/superpowers/specs/2026-07-19-search-hamburger-lock-design.md`.

---

### Task 1: Always show the hamburger icon

**Files:**
- Modify: `lib/screens/search_screen.dart:162-213` (the `build()` method's header `Row`)
- Test: `test/search_screen_test.dart` (new file)

**Interfaces:**
- Consumes: `isMentorProvider` (existing `Provider<bool>` from `lib/providers/data_providers.dart:141`), `SearchScreen` widget (existing, `lib/screens/search_screen.dart:20`)
- Produces: no new public interface — this task only changes when the existing hamburger `GestureDetector` renders.

- [ ] **Step 1: Write the failing test**

Create `test/search_screen_test.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/models/student.dart';
import 'package:tpmentorship/providers/auth_provider.dart';
import 'package:tpmentorship/providers/data_providers.dart';
import 'package:tpmentorship/screens/search_screen.dart';

// builds the SearchScreen with every Firestore-backed provider it reads
// stubbed out, so the widget tree can build without a real Firebase app
Widget _buildTestApp({required bool isMentor}) {
  return ProviderScope(
    overrides: [
      isMentorProvider.overrideWithValue(isMentor),
      authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
      mentorsProvider.overrideWith((ref) => Stream.value(<Mentor>[])),
      studentsProvider.overrideWith((ref) => Stream.value(<Student>[])),
      mentorsByRatingProvider.overrideWith(
          (ref, range) => Stream.value(<Mentor>[])),
    ],
    child: MaterialApp(
      home: Scaffold(body: SearchScreen()),
    ),
  );
}

void main() {
  group('SearchScreen hamburger menu', () {
    testWidgets('menu icon is visible even when the user is not a mentor',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(isMentor: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/search_screen_test.dart`
Expected: FAIL — `find.byIcon(Icons.menu)` finds nothing, because the icon is currently wrapped in `if (isMentor)` at `lib/screens/search_screen.dart:195`.

- [ ] **Step 3: Remove the `if (isMentor)` gate**

In `lib/screens/search_screen.dart`, inside `build()`, replace:

```dart
                  if (isMentor)
                    // hamburger menu - only shown once the user has
                    // signed up as a mentor (role includes "Mentor")
                    GestureDetector(
                      onTap: _openModeMenu,
                      child: Icon(Icons.menu, color: AppTheme.tpRed, size: 24),
                    ),
```

with:

```dart
                  GestureDetector(
                    onTap: _openModeMenu,
                    child: Icon(Icons.menu, color: AppTheme.tpRed, size: 24),
                  ),
```

Also remove the now-unused local variable at the top of `build()` (it will trigger an `unused_local_variable` analyzer warning since Task 2 moves the read into `_openModeMenu` itself):

```dart
    final isMentor = ref.watch(isMentorProvider);
```

Delete that line and its leading comment (`// the hamburger toggle only makes sense for users who can mentor -` / `// a student-only account never needs to browse for mentees`).

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/search_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/screens/search_screen.dart test/search_screen_test.dart
git commit -m "feat: always show search screen hamburger menu icon"
```

---

### Task 2: Lock the "A Student to Mentor" option for non-mentors

**Files:**
- Modify: `lib/screens/search_screen.dart:104-160` (`_openModeMenu()`)
- Test: `test/search_screen_test.dart` (extend the file from Task 1)

**Interfaces:**
- Consumes: `isMentorProvider` (read via `ref.read` inside `_openModeMenu`, same provider as Task 1), `showAppSnackBar` (existing helper, `lib/utils/snackbar_helper.dart:6`, signature `void showAppSnackBar(BuildContext context, String message, {bool success = false})`)
- Produces: no new public interface — `_openModeMenu()`'s rendered output changes based on mentor status.

- [ ] **Step 1: Write the failing tests**

Append to `test/search_screen_test.dart`, inside the existing `group('SearchScreen hamburger menu', ...)` block (add these two `testWidgets` after the one from Task 1):

```dart
    testWidgets(
        'non-mentor sees a locked student option and tapping it shows a snackbar without switching mode',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(isMentor: false));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // locked visual state
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.ancestor(
        of: find.text('A Student to Mentor'),
        matching: find.byType(Tooltip),
      ));
      expect(tooltip.message, 'Sign up as a mentor to unlock this');

      await tester.tap(find.text('A Student to Mentor'));
      await tester.pump(); // start the snackbar animation
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Sign up as a mentor to unlock this'), findsWidgets);
      // sheet stays open - the "Looking for..." header is still present
      expect(find.text('Looking for...'), findsOneWidget);
      // mode did not change
      expect(find.text('Find Mentors, Topics and Availability slots'),
          findsOneWidget);
    });

    testWidgets(
        'mentor can tap the student option to switch mode and close the sheet',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(isMentor: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsNothing);

      await tester.tap(find.text('A Student to Mentor'));
      await tester.pumpAndSettle();

      // sheet closed
      expect(find.text('Looking for...'), findsNothing);
      // mode switched
      expect(find.text('Find students looking for mentoring help'),
          findsOneWidget);
    });
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/search_screen_test.dart`
Expected: FAIL on both new tests — today every user sees the same interactive `ListTile` with no `Icons.lock_outline` and no `Tooltip`, and tapping it always switches `_mode` and pops the sheet regardless of mentor status.

- [ ] **Step 3: Implement the locked/unlocked student-mode tile**

In `lib/screens/search_screen.dart`, add the import for the snackbar helper near the top with the other imports:

```dart
import 'package:tpmentorship/utils/snackbar_helper.dart';
// shared snackbar styling used across the app
```

Replace the whole `_openModeMenu()` method with:

```dart
  // opens the menu letting a user switch between browsing for mentors and
  // browsing for students - the student option is shown to everyone for
  // header consistency, but stays locked until the user has signed up as
  // a mentor (isMentorProvider)
  void _openModeMenu() {
    final isMentor = ref.read(isMentorProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Looking for...'),
              ),
              ListTile(
                leading: Icon(Icons.school, color: AppTheme.tpRed),
                title: Text('A Mentor',
                    style: TextStyle(color: AppTheme.textPrimary)),
                trailing: _mode == 'mentor'
                    ? Icon(Icons.check, color: AppTheme.tpRed)
                    : null,
                onTap: () {
                  setState(() {
                    _mode = 'mentor';
                    _query = '';
                    _searchController.clear();
                  });
                  Navigator.pop(sheetContext);
                },
              ),
              _buildStudentModeTile(isMentor, sheetContext),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // the "A Student to Mentor" row - greyed out with a lock icon and a
  // tooltip when the user hasn't signed up as a mentor yet; tapping it
  // while locked shows a snackbar instead of switching mode
  Widget _buildStudentModeTile(bool isMentor, BuildContext sheetContext) {
    final tile = ListTile(
      leading: Icon(Icons.people,
          color: isMentor ? AppTheme.tpRed : AppTheme.textSecondary),
      title: Text('A Student to Mentor',
          style: TextStyle(
              color:
                  isMentor ? AppTheme.textPrimary : AppTheme.textSecondary)),
      trailing: !isMentor
          ? Icon(Icons.lock_outline, color: AppTheme.textSecondary)
          : (_mode == 'student'
              ? Icon(Icons.check, color: AppTheme.tpRed)
              : null),
      onTap: () {
        if (!isMentor) {
          showAppSnackBar(context, 'Sign up as a mentor to unlock this');
          return;
          // sheet stays open - this is not a valid selection yet
        }
        setState(() {
          _mode = 'student';
          _query = '';
          _searchController.clear();
        });
        Navigator.pop(sheetContext);
      },
    );

    if (isMentor) return tile;
    return Tooltip(
      message: 'Sign up as a mentor to unlock this',
      child: tile,
    );
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/search_screen_test.dart`
Expected: PASS (all 3 tests)

- [ ] **Step 5: Run the full test suite**

Run: `flutter test`
Expected: PASS (this file's 3 tests + the existing `test/widget_test.dart` tests, no regressions)

- [ ] **Step 6: Run static analysis**

Run: `flutter analyze lib/screens/search_screen.dart test/search_screen_test.dart`
Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/screens/search_screen.dart test/search_screen_test.dart
git commit -m "feat: lock student-mode search option until user is a mentor"
```
