# Notification opt-in during onboarding + mandatory onboarding fields

## Problem

Today `main()` unconditionally calls `NotificationService.instance.init()`,
which pops the Android 13+ system notification permission dialog at every
app launch - before the user has even logged in, let alone decided whether
they want reminders. There's no way to reconfigure this choice afterwards
either (Settings only has a "Test Notification" button, not a toggle).

Separately: the first-time onboarding form (`EditProfileScreen`, pushed
automatically for a new account - see `lib/main.dart:213-230`) can be
skipped by pressing back, and its "Subjects I need help with" field has no
required validation, so a new account can end up with an incomplete
profile.

## Design

### 1. Storage: `notificationsEnabled` on the profile

`lib/models/user_profile.dart` (same pattern as `themeName`):
- Add `final bool notificationsEnabled;` with constructor default `true`.
- `fromMap`: `notificationsEnabled: (data['notificationsEnabled'] ?? true) as bool,`
- `toMap`: `'notificationsEnabled': notificationsEnabled,`

`lib/services/user_service.dart`:
- Add:
  ```dart
  Future<void> updateNotificationsEnabled(String uid, bool enabled) {
    return _users.doc(uid).update({'notificationsEnabled': enabled});
  }
  ```

No `firestore.rules` change needed (same reasoning as `themeName`).

### 2. `NotificationService`: split init from permission request

`lib/services/notification_service.dart`:
- `init()` keeps setting up the timezone database and calling
  `_plugin.initialize(...)`, but NO LONGER calls
  `requestNotificationsPermission()`. It still runs once in `main()` -
  this part has no visible UI, so running it before login is fine.
- Add a new method:
  ```dart
  Future<void> requestPermission() async {
    if (kIsWeb || !_ready) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  ```
- `scheduleSessionReminder(...)` gains a required `bool notificationsEnabled`
  parameter and returns immediately if it's `false` (before the existing
  `kIsWeb`/`_ready` checks). This keeps `NotificationService` itself
  Riverpod-agnostic - callers pass the flag in.

Call sites that pass the new parameter (both already have `ref` -
`ConsumerState`):
- `lib/screens/book_session_screen.dart:155` -
  `notificationsEnabled: ref.read(userProfileProvider).value?.notificationsEnabled ?? true,`
- `lib/screens/session_detail_screen.dart:127` - same line added.

### 3. Onboarding form changes (`EditProfileScreen`)

`EditProfileScreen` gains a new `bool isOnboarding` constructor parameter
(default `false`, so the existing "Edit Profile" call site from Settings,
`lib/main.dart:369`, is unaffected). The first-time push at
`lib/main.dart:227` passes `isOnboarding: true`.

When `isOnboarding` is `true`:
- **Cannot skip:** wrap the `Scaffold` in
  `PopScope(canPop: !widget.isOnboarding, child: ...)` and set the
  `AppBar`'s `automaticallyImplyLeading: !widget.isOnboarding` - removes
  the back arrow and blocks the system back gesture/button. The only way
  off the screen is a successful save.
- **Subjects becomes required:** in `_save()`, if
  `widget.isOnboarding && _selectedSubjects.isEmpty`, show
  `showAppSnackBar(context, 'Please select at least one subject')` (same
  message/pattern already used in `become_mentor_screen.dart:83`) and
  return before saving. Combined with the existing required validators on
  Full Name, Student ID, Course, and Academic Year, every field except Bio
  is now mandatory during onboarding.
- **Notifications toggle:** add a `SwitchListTile` "Enable session
  reminder notifications", state defaulting to `true`, shown only when
  `isOnboarding` is `true` (the regular edit-profile screen does not show
  it - reconfiguring later happens in Settings, not here). On save, after
  `UserService.updateProfile(...)` succeeds, call
  `UserService.updateNotificationsEnabled(uid, toggleValue)`; if
  `toggleValue` is `true`, also call
  `NotificationService.instance.requestPermission()` to trigger the actual
  OS prompt at that point.

### 4. Settings: reconfigure later

`lib/main.dart`'s `_openSettings()` bottom sheet gets a new
`SwitchListTile` next to the existing "App Theme" row:
- Local state seeded once when the sheet opens:
  `var notificationsEnabled = ref.read(userProfileProvider).value?.notificationsEnabled ?? true;`
  (same pattern as the existing `reloadStarted` flag in this method).
- `onChanged`: update local state via `setSheetState`, call
  `ref.read(userServiceProvider).updateNotificationsEnabled(uid, value)`,
  and if the new value is `true`, also call
  `NotificationService.instance.requestPermission()`.
- Hidden on web (`if (!kIsWeb)`), matching the existing "Test Notification"
  row.

## Net effect

- New accounts see a notifications toggle (on by default) as part of
  filling in their profile, and can't leave that screen without
  completing every field except Bio.
- The OS permission popup only appears once the user has actually opted
  in (onboarding toggle on, or later flipping the Settings toggle on) -
  never unconditionally at app launch.
- Anyone can turn notifications on/off later from Settings.
- Turning notifications off only stops *future* reminders from being
  scheduled - it does not retroactively cancel reminders already
  scheduled for existing bookings (explicitly out of scope, see below).

## Scope

- `lib/models/user_profile.dart`
- `lib/services/user_service.dart`
- `lib/services/notification_service.dart`
- `lib/screens/edit_profile_screen.dart`
- `lib/screens/book_session_screen.dart` (one parameter added to an
  existing call)
- `lib/screens/session_detail_screen.dart` (one parameter added to an
  existing call)
- `lib/main.dart` (onboarding call site passes `isOnboarding: true`;
  `_openSettings()` gets the new toggle)

## Out of scope

- Retroactively cancelling already-scheduled reminders when notifications
  are turned off.
- Applying the "can't skip / all fields except Bio required" rule to the
  regular Edit Profile flow reachable from Settings - it stays
  cancellable and Subjects stays optional there, unchanged from today.
- Any change to how Android/iOS system-level permission denial is
  detected or surfaced back to the user (e.g. if they deny the OS prompt,
  the app doesn't currently check or react to that - unchanged).
