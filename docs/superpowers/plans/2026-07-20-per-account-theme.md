# Per-Account Theme Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move theme selection from a device-wide `SharedPreferences` setting to a per-account setting stored in Firestore, so logging into an account always shows that account's own saved theme.

**Architecture:** Add a nullable `themeName` field to `UserProfile` and a `UserService.updateTheme()` write method. Rework `ThemeController` (a Riverpod `StateNotifier<AppPalette>`) to hold a `Ref` and listen to the existing `userProfileProvider` stream for the app's lifetime, applying whichever theme the current profile has saved (or the default if none/no user). `setPalette()` keeps its existing call site in `main.dart` unchanged - it just persists to Firestore instead of `SharedPreferences` now.

**Tech Stack:** Flutter, flutter_riverpod (`StateNotifierProvider`, `ProviderContainer` for tests), cloud_firestore.

## Global Constraints

- Spec reference: `docs/superpowers/specs/2026-07-20-per-account-theme-design.md`.
- No `firestore.rules` change - the existing `users/{uid}` owner-write rule already covers a new field.
- `main.dart`'s `_openThemePicker()` and its call `ref.read(themeProvider.notifier).setPalette(palette)` must NOT change - only what `setPalette()` does internally changes.
- Removing the now-unused `shared_preferences` pubspec dependency is explicitly out of scope (per spec) - leave `pubspec.yaml` untouched.
- `UserService.updateTheme()`'s actual Firestore write is not unit-testable in this project (no Firestore emulator/mock is set up - consistent with `upgradeToPremium`/`cancelPremium`/`setRole`, none of which have tests either, because `UserService`'s `_users` field eagerly calls `FirebaseFirestore.instance` at construction, which throws outside a real Firebase app). Task 2's automated tests cover the profile-listening/palette-derivation logic only; the Firestore write itself gets a manual verification step instead.

---

### Task 1: Add `themeName` to the user profile

**Files:**
- Modify: `lib/models/user_profile.dart`
- Modify: `lib/services/user_service.dart`
- Test: `test/user_profile_test.dart` (new file)

**Interfaces:**
- Consumes: nothing new
- Produces: `UserProfile.themeName` (`String?`, new field), `UserProfile({..., String? themeName})` constructor param, `UserService.updateTheme(String uid, String themeName)` (`Future<void>`) - Task 2 calls this exact method name/signature.

- [ ] **Step 1: Write the failing test**

Create `test/user_profile_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tpmentorship/models/user_profile.dart';

void main() {
  group('UserProfile themeName', () {
    test('defaults to null when not provided', () {
      final profile = UserProfile(
        uid: 'u1',
        fullName: 'Ada',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(profile.themeName, isNull);
    });

    test('round-trips through toMap/fromMap', () {
      final profile = UserProfile(
        uid: 'u1',
        fullName: 'Ada',
        createdAt: DateTime(2026, 1, 1),
        themeName: 'TP Light',
      );

      final rebuilt = UserProfile.fromMap(profile.toMap(), profile.uid);

      expect(rebuilt.themeName, 'TP Light');
    });

    test('fromMap defaults themeName to null when the field is missing', () {
      final profile = UserProfile.fromMap({
        'fullName': 'Ada',
        'createdAt': null,
      }, 'u1');

      expect(profile.themeName, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/user_profile_test.dart`
Expected: FAIL with a compile error - `themeName` is not a named parameter / not a getter on `UserProfile` yet.

- [ ] **Step 3: Add `themeName` to `UserProfile`**

In `lib/models/user_profile.dart`, add the field next to the other simple fields (after `final bool premiumCancelled;` / `final DateTime? premiumCancelledAt;` block):

```dart
  final String? themeName;
  // which AppPalette this account has chosen (matches AppPalette.name,
  // e.g. 'TP Light') - null means the account never picked one, so the
  // app falls back to the default palette
```

Add it to the constructor:

```dart
  UserProfile({
    required this.uid,
    required this.fullName,
    this.studentId = '',
    this.course = '',
    this.academicYear = '',
    this.bio = '',
    this.isPremium = false,
    this.subjects = const [],
    required this.createdAt,
    this.role = 'Student',
    this.onboardingComplete = false,
    this.premiumCancelled = false,
    this.premiumCancelledAt,
    this.themeName,
  });
```

Add it to `fromMap`:

```dart
      premiumCancelledAt: data['premiumCancelledAt'] is Timestamp
          ? (data['premiumCancelledAt'] as Timestamp).toDate()
          : null,
      themeName: data['themeName'] as String?,
    );
  }
```

Add it to `toMap`:

```dart
      'premiumCancelledAt': premiumCancelledAt == null
          ? null
          : Timestamp.fromDate(premiumCancelledAt!),
      'themeName': themeName,
    };
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/user_profile_test.dart`
Expected: PASS

- [ ] **Step 5: Add `UserService.updateTheme()`**

In `lib/services/user_service.dart`, add this method after `setRole`:

```dart
  // saves the user's chosen theme (AppPalette.name) to their profile so it
  // follows them across logins and devices
  Future<void> updateTheme(String uid, String themeName) {
    return _users.doc(uid).update({'themeName': themeName});
  }
```

No test for this method (see Global Constraints - not unit-testable without a Firestore emulator, consistent with the untested `upgradeToPremium`/`cancelPremium`/`setRole` methods already in this file).

- [ ] **Step 6: Run the full test suite and analyzer**

Run: `flutter test && flutter analyze lib/models/user_profile.dart lib/services/user_service.dart test/user_profile_test.dart`
Expected: all tests pass, `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/models/user_profile.dart lib/services/user_service.dart test/user_profile_test.dart
git commit -m "feat: add themeName field to user profile"
```

---

### Task 2: Sync `ThemeController` from the logged-in profile

**Files:**
- Modify: `lib/providers/theme_provider.dart`
- Modify: `lib/main.dart:47-48` (remove the `loadSavedPalette()` call)
- Test: `test/theme_provider_test.dart` (new file)

**Interfaces:**
- Consumes: `UserProfile.themeName` (from Task 1), `userProfileProvider` (existing `StreamProvider<UserProfile?>`, `lib/providers/data_providers.dart:133`), `authStateProvider` (existing `StreamProvider<User?>`, `lib/providers/auth_provider.dart:13`), `userServiceProvider` (existing `Provider<UserService>`, `lib/providers/data_providers.dart:30`), `UserService.updateTheme` (from Task 1)
- Produces: `themeProvider` keeps its existing type (`StateNotifierProvider<ThemeController, AppPalette>`) and its existing `setPalette(AppPalette palette)` method signature - `main.dart`'s call site is unaffected.

- [ ] **Step 1: Write the failing tests**

Create `test/theme_provider_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tpmentorship/models/user_profile.dart';
import 'package:tpmentorship/providers/data_providers.dart';
import 'package:tpmentorship/providers/theme_provider.dart';
import 'package:tpmentorship/theme/app_theme.dart';

UserProfile _profileWithTheme(String? themeName) {
  return UserProfile(
    uid: 'test-uid',
    fullName: 'Test User',
    createdAt: DateTime(2026, 1, 1),
    themeName: themeName,
  );
}

void main() {
  group('ThemeController syncs from the logged in profile', () {
    test("applies the profile's saved theme", () async {
      final container = ProviderContainer(overrides: [
        userProfileProvider.overrideWith(
            (ref) => Stream.value(_profileWithTheme('TP Light'))),
      ]);
      addTearDown(container.dispose);

      container.read(themeProvider);
      // reading the provider constructs ThemeController, which starts
      // listening to userProfileProvider
      await Future<void>.delayed(Duration.zero);
      // let the overridden stream's first value flow through

      expect(container.read(themeProvider), AppTheme.tpLight);
    });

    test('falls back to the default theme when the profile never chose one',
        () async {
      final container = ProviderContainer(overrides: [
        userProfileProvider
            .overrideWith((ref) => Stream.value(_profileWithTheme(null))),
      ]);
      addTearDown(container.dispose);

      container.read(themeProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(themeProvider), AppTheme.tpDark);
    });

    test('resets to the default theme when logged out', () async {
      final container = ProviderContainer(overrides: [
        userProfileProvider.overrideWith((ref) => Stream.value(null)),
      ]);
      addTearDown(container.dispose);

      container.read(themeProvider);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(themeProvider), AppTheme.tpDark);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/theme_provider_test.dart`
Expected: FAIL - today's `ThemeController` has no constructor parameter and never reads `userProfileProvider`, so `container.read(themeProvider)` stays whatever the static default/last-saved-locally value is regardless of the overridden profile stream.

- [ ] **Step 3: Rewrite `ThemeController`**

Replace the entire contents of `lib/providers/theme_provider.dart` with:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/providers/auth_provider.dart';
// gives us the logged in user's uid, to save the theme against their account
import 'package:tpmentorship/providers/data_providers.dart';
// gives us the logged in user's live firestore profile and its themeName
import 'package:tpmentorship/theme/app_theme.dart';
// the palettes

class ThemeController extends StateNotifier<AppPalette> {
// part 3 personalisation: remembers and switches the app's theme.
// the choice lives on the logged in user's Firestore profile (not the
// device), so it follows the account across logins and devices, and
// resets to the default the moment nobody is logged in
  ThemeController(this._ref) : super(AppTheme.tpDark) {
    _ref.listen(userProfileProvider, (previous, next) {
      _applyFromProfile(next.value?.themeName);
    }, fireImmediately: true);
  }

  final Ref _ref;

  // applies whatever theme the logged in profile has saved - or the
  // default if it never chose one, or nobody is logged in
  void _applyFromProfile(String? themeName) {
    final palette = themeName == null
        ? AppTheme.tpDark
        : AppTheme.paletteByName(themeName);
    AppTheme.applyPalette(palette);
    state = palette;
  }

  // called when the user picks a theme in settings - applies it straight
  // away so the UI feels instant, then saves it to their Firestore profile
  // so it follows them next time they log in (this device or another)
  Future<void> setPalette(AppPalette palette) async {
    AppTheme.applyPalette(palette);
    state = palette;

    final uid = _ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    // not logged in - shouldn't happen since the theme picker only opens
    // from settings, which requires being logged in, but guard anyway

    await _ref.read(userServiceProvider).updateTheme(uid, palette.name);
  }
}

// the provider screens watch to know the active theme
final themeProvider =
    StateNotifierProvider<ThemeController, AppPalette>((ref) {
  return ThemeController(ref);
});
```

- [ ] **Step 4: Remove the old `loadSavedPalette()` call from `main()`**

In `lib/main.dart`, remove these two lines (they're no longer needed - `ThemeController` now syncs itself as soon as `userProfileProvider` resolves):

```dart
  await ThemeController.loadSavedPalette();
  // apply the user's saved theme before the first frame draws
```

So `main()` becomes:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialise flutter so firebase can be initialised
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    // connect to firebase project
  );
  await NotificationService.instance.init();
  // set up local notifications (does nothing on web)
  runApp(const ProviderScope(child: MyApp()));
  // enable riverpod state management for the app
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/theme_provider_test.dart`
Expected: PASS (all 3 tests)

- [ ] **Step 6: Run the full test suite and analyzer**

Run: `flutter test && flutter analyze lib/providers/theme_provider.dart lib/main.dart test/theme_provider_test.dart`
Expected: all tests pass (this file's 3 + Task 1's 3 + the pre-existing suites), `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/providers/theme_provider.dart lib/main.dart test/theme_provider_test.dart
git commit -m "feat: sync app theme from the logged in user's Firestore profile"
```

- [ ] **Step 8: Manual verification (Firestore write path)**

Automated tests cover the profile-listening/derivation logic but not the
actual Firestore write (see Global Constraints). Verify by hand:

1. `flutter run` on an emulator, log into an account.
2. Settings > App Theme > pick "TP Light". Confirm the UI switches
   immediately.
3. In the Firebase console, open Firestore > `users/<that account's uid>`
   and confirm the `themeName` field is `"TP Light"`.
4. Log out, log into a *different* account (or the same one after
   manually setting its Firestore `themeName` to `"TP Dark"` in the
   console) - confirm the app shows that account's own theme, not the
   previous account's.
5. Log out entirely - confirm the login screen shows the default (TP
   Dark) theme.
