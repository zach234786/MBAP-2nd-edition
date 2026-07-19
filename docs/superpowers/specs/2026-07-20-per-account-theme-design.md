# Per-account theme sync

## Problem

App theme is currently a device-wide setting stored in `SharedPreferences`
(`lib/providers/theme_provider.dart:13`), loaded once in `main()` before any
auth check happens. It has no connection to which Firebase account is
logged in. Reported symptom: changing the theme while logged into one
account, then logging into a different account, keeps showing the
previously-selected theme instead of that account's own theme - because
theme was never tied to the account at all.

## Design

### Storage: `themeName` field on the user's Firestore profile

`lib/models/user_profile.dart`:
- Add `final String? themeName;` (nullable - `null` means "never chosen,
  use the default palette").
- Constructor: add `this.themeName,` (no default, stays nullable).
- `UserProfile.fromMap`: add `themeName: data['themeName'] as String?,`
- `toMap()`: add `'themeName': themeName,`

`lib/services/user_service.dart`:
- Add:
  ```dart
  Future<void> updateTheme(String uid, String themeName) {
    return _users.doc(uid).update({'themeName': themeName});
  }
  ```

No `firestore.rules` change needed - `match /users/{uid} { allow read,
write: if request.auth != null && request.auth.uid == uid; }` already
permits the owner to write any field on their own document.

### Sync: `ThemeController` listens to the logged-in profile

`lib/providers/theme_provider.dart` is reworked so `ThemeController` holds
the `Ref` from its provider and listens to `userProfileProvider` for the
app's lifetime:

- On every emission from `userProfileProvider` (fresh login, switching
  accounts, logout, or the same account's theme changing on another
  device), apply `next.value?.themeName` - or `AppTheme.tpDark` if that's
  `null` (no user logged in, or the account never picked a theme).
- `setPalette(AppPalette palette)` (still called the same way from
  `main.dart`'s existing `_openThemePicker()` - `ref.read(themeProvider.notifier).setPalette(palette)`)
  applies the palette immediately (so the UI feels instant) then calls
  `UserService.updateTheme(uid, palette.name)` to persist it. The uid comes
  from `ref.read(authStateProvider).value?.uid`; if somehow null (should
  never happen since the theme picker is only reachable from settings,
  which requires being logged in), it's a no-op after the local apply.
- The old `SharedPreferences`-based storage (`_prefsKey`,
  `loadSavedPalette()`) is removed entirely - Firestore is now the only
  source of truth once logged in, and the hardcoded `AppTheme.tpDark`
  default covers the logged-out case.

`lib/main.dart`: remove the `await ThemeController.loadSavedPalette();`
line from `main()` (and its comment) - no longer needed since
`ThemeController` self-syncs via the provider listener as soon as
`userProfileProvider` resolves.

## Net effect

- Logging into an account shows that account's saved theme (or the
  default, TP Dark, if it never chose one).
- Logging out resets the app to the default theme.
- Changing the theme from Settings still works exactly the same from the
  user's perspective - same picker, same UI - it just now persists to the
  account instead of the device.

## Scope

- `lib/models/user_profile.dart`
- `lib/services/user_service.dart`
- `lib/providers/theme_provider.dart`
- `lib/main.dart` (one line + comment removed)

No screen/UI changes - `_openThemePicker()` in `main.dart` is untouched.

## Out of scope

- Removing the now-unused `shared_preferences` package dependency from
  `pubspec.yaml` (left in place; not part of this change).
- Any migration of previously-saved device-level theme choices - accounts
  simply start from the default the first time this ships, until each
  user picks a theme again.
