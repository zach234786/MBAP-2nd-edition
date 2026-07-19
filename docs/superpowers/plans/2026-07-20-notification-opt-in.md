# Notification Opt-In + Mandatory Onboarding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the notification permission request from an unconditional app-launch popup to an onboarding opt-in (reconfigurable later in Settings), and lock the first-time onboarding form so it can't be skipped and requires every field except Bio.

**Architecture:** Add `notificationsEnabled` to `UserProfile`/`UserService` (mirrors the existing `themeName` field exactly). Split `NotificationService.init()` (silent plugin setup) from a new `requestPermission()` (the actual OS popup), and thread a `notificationsEnabled` bool into `scheduleSessionReminder()` so callers decide whether to schedule. Give `EditProfileScreen` an `isOnboarding` flag that locks navigation, requires Subjects, and shows a notifications toggle - only when it's the first-time onboarding push from `main.dart`, not the regular Settings > Edit Profile flow.

**Tech Stack:** Flutter, flutter_riverpod, cloud_firestore, flutter_local_notifications.

## Global Constraints

- Spec reference: `docs/superpowers/specs/2026-07-20-notification-opt-in-design.md`.
- No `firestore.rules` change needed.
- The "can't skip / all fields except Bio required" rule applies ONLY when `EditProfileScreen`'s `isOnboarding` is `true` (the first-time push at `lib/main.dart:227`). The regular Edit Profile flow (`lib/main.dart:369`, called with the default `isOnboarding: false`) is unchanged: still cancellable, Subjects still optional, no notifications toggle shown.
- `NotificationService` (native plugin/platform-channel calls) and `UserService`'s Firestore writes are NOT unit-tested in this project - no plugin mock or Firestore emulator is set up (same constraint as `UserService.updateTheme` in the per-account-theme plan). Automated tests cover pure logic and widget structure only; the actual persisted/native behavior gets a manual verification checklist at the end of Task 3.
- Turning notifications off does NOT retroactively cancel already-scheduled reminders - explicitly out of scope.

---

### Task 1: Add `notificationsEnabled` to the user profile

**Files:**
- Modify: `lib/models/user_profile.dart`
- Modify: `lib/services/user_service.dart`
- Test: `test/user_profile_test.dart` (existing file from the per-account-theme plan - extend it)

**Interfaces:**
- Consumes: nothing new
- Produces: `UserProfile.notificationsEnabled` (`bool`, defaults to `true`), `UserService.updateNotificationsEnabled(String uid, bool enabled)` (`Future<void>`) - Task 3 and Task 4 call this exact method name/signature.

- [ ] **Step 1: Write the failing tests**

Append to `test/user_profile_test.dart` (add a new `group` after the existing `UserProfile themeName` group):

```dart
  group('UserProfile notificationsEnabled', () {
    test('defaults to true when not provided', () {
      final profile = UserProfile(
        uid: 'u1',
        fullName: 'Ada',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(profile.notificationsEnabled, isTrue);
    });

    test('round-trips through toMap/fromMap', () {
      final profile = UserProfile(
        uid: 'u1',
        fullName: 'Ada',
        createdAt: DateTime(2026, 1, 1),
        notificationsEnabled: false,
      );

      final rebuilt = UserProfile.fromMap(profile.toMap(), profile.uid);

      expect(rebuilt.notificationsEnabled, isFalse);
    });

    test('fromMap defaults to true when the field is missing', () {
      final profile = UserProfile.fromMap({
        'fullName': 'Ada',
        'createdAt': null,
      }, 'u1');

      expect(profile.notificationsEnabled, isTrue);
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/user_profile_test.dart`
Expected: FAIL with a compile error - `notificationsEnabled` is not a named parameter / not a getter on `UserProfile` yet.

- [ ] **Step 3: Add `notificationsEnabled` to `UserProfile`**

In `lib/models/user_profile.dart`, add the field after `themeName`:

```dart
  final String? themeName;
  // which AppPalette this account has chosen (matches AppPalette.name,
  // e.g. 'TP Light') - null means the account never picked one, so the
  // app falls back to the default palette
  final bool notificationsEnabled;
  // whether this account wants session reminder notifications - set
  // during onboarding (defaults to true), reconfigurable in Settings
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
    this.notificationsEnabled = true,
  });
```

Add it to `fromMap`:

```dart
      themeName: data['themeName'] as String?,
      notificationsEnabled: (data['notificationsEnabled'] ?? true) as bool,
    );
  }
```

Add it to `toMap`:

```dart
      'themeName': themeName,
      'notificationsEnabled': notificationsEnabled,
    };
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/user_profile_test.dart`
Expected: PASS (all 6 tests - 3 existing `themeName` tests + 3 new `notificationsEnabled` tests)

- [ ] **Step 5: Add `UserService.updateNotificationsEnabled()`**

In `lib/services/user_service.dart`, add this method after `updateTheme`:

```dart
  // saves whether this account wants session reminder notifications
  Future<void> updateNotificationsEnabled(String uid, bool enabled) {
    return _users.doc(uid).update({'notificationsEnabled': enabled});
  }
```

No test for this method (see Global Constraints).

- [ ] **Step 6: Run the full test suite and analyzer**

Run: `flutter test && flutter analyze lib/models/user_profile.dart lib/services/user_service.dart test/user_profile_test.dart`
Expected: all tests pass, `No issues found!`

- [ ] **Step 7: Commit**

```bash
git add lib/models/user_profile.dart lib/services/user_service.dart test/user_profile_test.dart
git commit -m "feat: add notificationsEnabled field to user profile"
```

---

### Task 2: Split `NotificationService` init from permission request

**Files:**
- Modify: `lib/services/notification_service.dart`
- Modify: `lib/screens/book_session_screen.dart:155`
- Modify: `lib/screens/session_detail_screen.dart:127`

**Interfaces:**
- Consumes: `UserProfile.notificationsEnabled` (from Task 1, via `ref.read(userProfileProvider).value?.notificationsEnabled`)
- Produces: `NotificationService.requestPermission()` (`Future<void>`, new method) - Task 3 and Task 4 call it. `NotificationService.scheduleSessionReminder(...)` gains a required `bool notificationsEnabled` parameter - no other call sites exist besides the two modified here.

- [ ] **Step 1: Remove the permission request from `init()`, add `requestPermission()`**

In `lib/services/notification_service.dart`, replace:

```dart
    await _plugin.initialize(settings: initSettings);

    // Android 13+ needs the user to allow notifications (a system popup)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _ready = true;
  }
```

with:

```dart
    await _plugin.initialize(settings: initSettings);

    _ready = true;
  }

  // pops the Android 13+ system permission dialog - called only once the
  // user has actually opted in (onboarding toggle, or later in Settings),
  // never unconditionally at app launch
  Future<void> requestPermission() async {
    if (kIsWeb || !_ready) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
```

- [ ] **Step 2: Add the `notificationsEnabled` parameter to `scheduleSessionReminder`**

In the same file, change the method signature and add the guard as its first line:

```dart
  Future<void> scheduleSessionReminder({
    required String sessionId,
    required String title,
    required String mentorName,
    required DateTime sessionTime,
    required bool notificationsEnabled,
  }) async {
    if (!notificationsEnabled) return;
    // this account has turned notifications off - nothing to schedule
    if (kIsWeb || !_ready) return;
    // web, or init failed - skip quietly
```

- [ ] **Step 3: Pass the flag from `book_session_screen.dart`**

In `lib/screens/book_session_screen.dart`, change the existing call:

```dart
      await NotificationService.instance.scheduleSessionReminder(
        sessionId: sessionId,
        title: session.title,
        mentorName: session.mentorName,
        sessionTime: sessionDateTime,
      );
```

to:

```dart
      await NotificationService.instance.scheduleSessionReminder(
        sessionId: sessionId,
        title: session.title,
        mentorName: session.mentorName,
        sessionTime: sessionDateTime,
        notificationsEnabled:
            ref.read(userProfileProvider).value?.notificationsEnabled ?? true,
      );
```

Add the import if not already present: `import 'package:tpmentorship/providers/data_providers.dart';` (check the top of the file first - it likely already imports this for other providers used on the same screen; only add if missing).

- [ ] **Step 4: Pass the flag from `session_detail_screen.dart`**

In `lib/screens/session_detail_screen.dart`, change the existing call:

```dart
      await NotificationService.instance.scheduleSessionReminder(
        sessionId: updated.id,
        title: updated.title,
        mentorName: updated.mentorName,
        sessionTime: newDateTime,
      );
```

to:

```dart
      await NotificationService.instance.scheduleSessionReminder(
        sessionId: updated.id,
        title: updated.title,
        mentorName: updated.mentorName,
        sessionTime: newDateTime,
        notificationsEnabled:
            ref.read(userProfileProvider).value?.notificationsEnabled ?? true,
      );
```

Add the import if not already present: `import 'package:tpmentorship/providers/data_providers.dart';` (check first - only add if missing).

- [ ] **Step 5: Run the full test suite and analyzer**

No new automated tests for this task (see Global Constraints - no plugin mock exists).

Run: `flutter test && flutter analyze lib/services/notification_service.dart lib/screens/book_session_screen.dart lib/screens/session_detail_screen.dart`
Expected: all existing tests still pass (nothing in this task should break them), `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/services/notification_service.dart lib/screens/book_session_screen.dart lib/screens/session_detail_screen.dart
git commit -m "feat: gate session reminders behind the account's notification preference"
```

---

### Task 3: Lock the onboarding form and add the notifications toggle

**Files:**
- Modify: `lib/screens/edit_profile_screen.dart`
- Test: `test/edit_profile_screen_test.dart` (new file)

**Interfaces:**
- Consumes: `UserProfile.notificationsEnabled` (Task 1), `UserService.updateNotificationsEnabled` (Task 1), `NotificationService.requestPermission()` (Task 2)
- Produces: `EditProfileScreen({super.key, required UserProfile profile, bool isOnboarding = false})` - Task 4 passes `isOnboarding: true` at the onboarding call site in `main.dart`; the existing Settings call site is unaffected by the default.

- [ ] **Step 1: Write the failing tests**

Create `test/edit_profile_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tpmentorship/models/user_profile.dart';
import 'package:tpmentorship/screens/edit_profile_screen.dart';

// a profile with every onboarding-required field already valid, so tests
// can isolate the one behaviour they're checking (e.g. the subjects gate)
// without tripping the form's other validators
UserProfile _validProfile({List<String> subjects = const []}) {
  return UserProfile(
    uid: 'u1',
    fullName: 'Ada Lovelace',
    studentId: '2501587F',
    course: 'Diploma in AAI',
    academicYear: 'Year 1',
    createdAt: DateTime(2026, 1, 1),
    subjects: subjects,
  );
}

Widget _wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: child));
}

void main() {
  group('EditProfileScreen onboarding lock', () {
    testWidgets('onboarding mode hides the back button and blocks popping',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile(), isOnboarding: true),
      ));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.automaticallyImplyLeading, isFalse);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });

    testWidgets('regular edit mode keeps the back button and allows popping',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile()),
      ));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.automaticallyImplyLeading, isTrue);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isTrue);
    });

    testWidgets(
        'onboarding mode blocks saving with no subjects selected',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(
            profile: _validProfile(subjects: const []), isOnboarding: true),
      ));

      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // let the snackbar animate in

      expect(find.text('Please select at least one subject'), findsOneWidget);
      // still on the same screen - Navigator never popped
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets(
        'onboarding mode does not block saving when a subject is selected',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(
            profile: _validProfile(subjects: const ['DAVA']),
            isOnboarding: true),
      ));

      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
          find.text('Please select at least one subject'), findsNothing);
    });

    testWidgets('shows the notifications toggle only in onboarding mode',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile(), isOnboarding: true),
      ));
      final onboardingSwitch =
          tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(onboardingSwitch.value, isTrue);

      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile()),
      ));
      expect(find.byType(SwitchListTile), findsNothing);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/edit_profile_screen_test.dart`
Expected: FAIL - `EditProfileScreen` has no `isOnboarding` parameter yet (compile error), no `PopScope`, no subjects validation, no `SwitchListTile`.

- [ ] **Step 3: Add the `isOnboarding` parameter and notifications toggle state**

In `lib/screens/edit_profile_screen.dart`, change the widget declaration:

```dart
class EditProfileScreen extends ConsumerStatefulWidget {
// a validated form for editing the user's Firestore profile
// the subjects picked here are what the AI matching feature uses
  final UserProfile profile;
  // the current profile values to pre-fill the form with
  final bool isOnboarding;
  // true only for the first-time setup push from main.dart - locks
  // navigation, requires Subjects, and shows the notifications toggle.
  // false (default) for the regular Settings > Edit Profile flow, which
  // stays cancellable exactly as before

  const EditProfileScreen({
    super.key,
    required this.profile,
    this.isOnboarding = false,
  });

  @override
  ConsumerState<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}
```

Add a notifications toggle state field next to `_saving`:

```dart
  bool _saving = false;
  // true while saving, shows the button spinner
  bool _notificationsEnabled = true;
  // only shown/used when widget.isOnboarding is true
```

- [ ] **Step 4: Add the subjects-required check and the notifications persistence to `_save()`**

Replace the start of `_save()`:

```dart
  // checks the form then saves the changes to Firestore
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // stop if any field is invalid

    setState(() => _saving = true);
```

with:

```dart
  // checks the form then saves the changes to Firestore
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    // stop if any field is invalid
    if (widget.isOnboarding && _selectedSubjects.isEmpty) {
      showAppSnackBar(context, 'Please select at least one subject');
      return;
    }

    setState(() => _saving = true);
```

Then, still inside `_save()`'s `try` block, right after the existing `updateProfile(...)` call (before the display-name sync block), add the notifications persistence - replace:

```dart
      await ref.read(userServiceProvider).updateProfile(
            uid: widget.profile.uid,
            fullName: fullName,
            studentId: _studentIdController.text.trim().toUpperCase(),
            course: course,
            academicYear: _academicYear ?? '',
            bio: bio,
            subjects: _selectedSubjects,
          );
```

with:

```dart
      await ref.read(userServiceProvider).updateProfile(
            uid: widget.profile.uid,
            fullName: fullName,
            studentId: _studentIdController.text.trim().toUpperCase(),
            course: course,
            academicYear: _academicYear ?? '',
            bio: bio,
            subjects: _selectedSubjects,
          );

      if (widget.isOnboarding) {
        await ref
            .read(userServiceProvider)
            .updateNotificationsEnabled(widget.profile.uid, _notificationsEnabled);
        if (_notificationsEnabled) {
          await NotificationService.instance.requestPermission();
        }
      }
```

Add the import at the top of the file (alongside the other imports):

```dart
import 'package:tpmentorship/services/notification_service.dart';
// requests the OS notification permission when onboarding opts in
```

- [ ] **Step 5: Add the `PopScope`, remove the back arrow, and add the toggle to `build()`**

Replace:

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
```

with:

```dart
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.isOnboarding,
      child: Scaffold(
        backgroundColor: AppTheme.darkBg,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          automaticallyImplyLeading: !widget.isOnboarding,
        ),
        body: SafeArea(
```

This changes the indentation of everything inside the old `Scaffold(...)` by one level and requires closing both the new `PopScope(` and the `Scaffold(` at the end of `build()`. Replace the end of `build()`:

```dart
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
```

with:

```dart
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
```

(one extra level of closing to match the new `PopScope`/`Scaffold` nesting - re-indent the whole `build()` body consistently rather than only patching the two ends, since Dart doesn't require exact indentation but the file should stay readable).

Add the notifications `SwitchListTile` right before the "save button" comment block, still inside the `Form`'s `Column` children, after the Subjects section's `SizedBox(height: 24)`:

```dart
                  const SizedBox(height: 24),

                  // ----- notifications opt-in (onboarding only) -----
                  if (widget.isOnboarding) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: AppTheme.tpRed,
                      value: _notificationsEnabled,
                      onChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                      title: Text('Enable session reminder notifications',
                          style: TextStyle(color: AppTheme.textPrimary)),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // ----- save button with loading spinner -----
```

- [ ] **Step 6: Run tests to verify they pass**

Run: `flutter test test/edit_profile_screen_test.dart`
Expected: PASS (all 5 tests)

- [ ] **Step 7: Run the full test suite and analyzer**

Run: `flutter test && flutter analyze lib/screens/edit_profile_screen.dart test/edit_profile_screen_test.dart`
Expected: all tests pass, `No issues found!`

- [ ] **Step 8: Commit**

```bash
git add lib/screens/edit_profile_screen.dart test/edit_profile_screen_test.dart
git commit -m "feat: lock onboarding form and add notifications opt-in toggle"
```

---

### Task 4: Wire up the onboarding entry point and Settings toggle

**Files:**
- Modify: `lib/main.dart:227` (onboarding push passes `isOnboarding: true`)
- Modify: `lib/main.dart` `_openSettings()` (new toggle)

**Interfaces:**
- Consumes: `EditProfileScreen`'s `isOnboarding` parameter (Task 3), `UserProfile.notificationsEnabled` / `UserService.updateNotificationsEnabled` (Task 1), `NotificationService.requestPermission()` (Task 2)
- Produces: nothing new for later tasks - this is the last task.

- [ ] **Step 1: Pass `isOnboarding: true` at the first-time push**

In `lib/main.dart`, inside `_MainNavigatorState.initState()`'s `ref.listenManual` callback, change:

```dart
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditProfileScreen(profile: profile)),
        );
```

to:

```dart
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  EditProfileScreen(profile: profile, isOnboarding: true)),
        );
```

- [ ] **Step 2: Add the notifications toggle to `_openSettings()`**

In `lib/main.dart`, `_openSettings()` currently starts with:

```dart
  void _openSettings() {
    final authService = ref.read(authServiceProvider);
    var reloadStarted = false;
```

Change it to also seed the local toggle state:

```dart
  void _openSettings() {
    final authService = ref.read(authServiceProvider);
    var reloadStarted = false;
    var notificationsEnabled =
        ref.read(userProfileProvider).value?.notificationsEnabled ?? true;
```

Then add the new `ListTile` right after the existing "App Theme" `ListTile` and before the `if (!kIsWeb)` "Test Notification" block:

```dart
              if (!kIsWeb)
                SwitchListTile(
                  secondary: Icon(Icons.notifications_outlined,
                      color: AppTheme.tpRed),
                  activeThumbColor: AppTheme.tpRed,
                  title: Text('Notifications',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  value: notificationsEnabled,
                  onChanged: (value) async {
                    setSheetState(() => notificationsEnabled = value);
                    final uid = ref.read(authStateProvider).value?.uid;
                    if (uid == null) return;
                    await ref
                        .read(userServiceProvider)
                        .updateNotificationsEnabled(uid, value);
                    if (value) {
                      await NotificationService.instance.requestPermission();
                    }
                  },
                ),
```

(placed alongside the existing `if (!kIsWeb)` "Test Notification" `ListTile` a few lines below it - both are mobile-only, matching the existing pattern in this sheet.)

- [ ] **Step 3: Run the full test suite and analyzer**

No new automated test for this task (wiring only - `main.dart`'s `AuthGate`/`MainNavigator`/settings sheet aren't under any existing test harness, and the pieces it wires together are already covered by Tasks 1-3's tests).

Run: `flutter test && flutter analyze lib/main.dart`
Expected: all existing tests still pass, `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/main.dart
git commit -m "feat: wire notifications opt-in into onboarding and settings"
```

- [ ] **Step 5: Manual verification**

Automated tests cover the pure logic and widget structure but not the native
plugin/Firestore-write paths (see Global Constraints). Verify by hand:

1. `flutter run` on an emulator, register a brand new account.
2. Confirm the onboarding Edit Profile screen has no back arrow and the
   Android back button does nothing on it.
3. Try Save with no subjects selected - confirm the
   "Please select at least one subject" snackbar appears and you're still
   on the screen.
4. Fill in Name, Student ID, Course, Academic Year, at least one subject,
   leave Bio empty, leave the notifications toggle on, tap Save - confirm
   it succeeds, the screen closes, and the Android system notification
   permission dialog appears.
5. In the Firebase console, confirm `users/<uid>` has
   `notificationsEnabled: true` and `onboardingComplete: true`.
6. Book a session - confirm a reminder notification fires ~15 minutes
   before (or check `adb shell dumpsys notification` / just trust the
   existing "Test Notification" button in Settings works as before).
7. Go to Settings, flip Notifications off - confirm
   `users/<uid>.notificationsEnabled` becomes `false` in the console, and
   book another session - confirm no reminder gets scheduled (no
   permission dialog, no crash).
8. Flip Notifications back on in Settings - confirm the OS permission
   dialog reappears (if previously denied) or nothing visible happens (if
   already granted), and `notificationsEnabled` returns to `true`.
