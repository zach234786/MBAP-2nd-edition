# Dedicated Settings screen

## Problem

The account settings currently live in a `showModalBottomSheet` inside
`_MainNavigatorState._openSettings()` (`lib/main.dart:470-649`). It has grown
to six items (Change Password, Email Verification, App Theme, Notifications
toggle, Test Notification, Delete Account) plus reload-on-open logic, all
crammed into one bottom sheet built inline in `main.dart`. It's cramped and
`main.dart` is carrying UI + helper methods (`_openThemePicker`,
`_deleteAccount`) that only exist to serve this sheet.

## Design

### New file: `lib/screens/settings_screen.dart`

A self-contained `SettingsScreen extends ConsumerStatefulWidget` (const
constructor, no parameters). It reads everything it needs directly from
providers, so no callbacks are threaded in:
- `authServiceProvider` - email verification state, change-password gating,
  `reloadUser()`, `sendEmailVerification()`
- `authStateProvider` - the current uid (for the notifications write)
- `userProfileProvider` - the current `notificationsEnabled` value and the
  active theme name
- `userServiceProvider` - `updateNotificationsEnabled()`
- `themeProvider` - current palette name + `setPalette()` via the theme
  picker

Standard `Scaffold` with `backgroundColor: AppTheme.darkBg` and an
`AppBar(title: const Text('Settings'))` (the default back arrow returns to
the Profile screen). Body is a `SingleChildScrollView` inside `SafeArea`.

### Visual structure: grouped sectioned cards

Instead of one flat list, items are grouped into labelled sections. Two
private helpers:

- `Widget _sectionHeader(String title)` - small uppercase-styled label
  (`AppTheme.textSecondary`, fontSize 12, `letterSpacing: 0.5`,
  `FontWeight.w700`) with `EdgeInsets.fromLTRB(20, 20, 20, 8)`.
- `Widget _settingsCard(List<Widget> children)` - a `Container`
  (`color: AppTheme.darkCardBg`, `border: Border.all(color:
  AppTheme.darkBorder)`, `borderRadius: BorderRadius.circular(14)`,
  `margin: EdgeInsets.symmetric(horizontal: 16)`, `clipBehavior:
  Clip.antiAlias`) wrapping a `Column` of the passed children, with a
  `Divider(height: 1, color: AppTheme.darkBorder)` inserted between
  consecutive rows (not after the last).

Sections, in order:

1. **ACCOUNT** card:
   - Change Password (`Icons.lock_reset`) - same behaviour as today: if not
     `authService.isEmailPasswordAccount`, show snackbar "Only available for
     email/password accounts"; otherwise push `ChangePasswordScreen` (with
     its existing `onForgotPassword` wiring pushing `ForgotPasswordScreen`).
   - Email Verification - icon and title depend on
     `authService.isEmailVerified` (`Icons.verified` + "Email Verified" vs
     `Icons.mark_email_unread` + "Resend Verification Email"). Same tap
     behaviour: gate on email/password account, already-verified check, else
     `sendEmailVerification()` + snackbar.

2. **APPEARANCE** card:
   - App Theme (`Icons.palette_outlined`), subtitle = current theme name
     (`ref.watch(themeProvider).name`), trailing `Icons.chevron_right`.
     Tapping opens the theme-picker dialog (moved from `main.dart`, behaviour
     unchanged: lists `AppTheme.palettes`, tick beside the active one, taps
     call `setPalette` and close the dialog).

3. **NOTIFICATIONS** card - only rendered when `!kIsWeb`:
   - Notifications `SwitchListTile` - same behaviour as today: local state
     seeded from `userProfileProvider`, on change persists via
     `updateNotificationsEnabled(uid, value)` and calls
     `NotificationService.instance.requestPermission()` when turning on.
   - Test Notification (`Icons.notifications_active_outlined`) - same gate:
     if notifications are off, snackbar "Enable notifications first to
     test"; otherwise `showTestNotification()`.

4. **Delete Account** - its own standalone danger card at the bottom
   (separate from the ACCOUNT card, after a larger gap). Red-tinted:
   `Icons.delete_forever` and title text both `AppTheme.tpRed`. Tapping runs
   the delete-confirmation dialog (moved from `main.dart`, behaviour
   unchanged). After the section, a bottom `SizedBox(height: 24)`.

### State handling

- The email-verification reload that the bottom sheet did on open (the
  `reloadStarted` + `authService.reloadUser()` dance) moves into the
  screen's `initState`: call `reloadUser()` once, and `setState(() {})` when
  it completes (guarded by `mounted`) so the verified/unverified row
  refreshes. Errors are swallowed exactly as before (`.catchError((_) {})`).
- The notifications toggle keeps a local `bool _notificationsEnabled` field,
  initialised in `initState` from
  `ref.read(userProfileProvider).value?.notificationsEnabled ?? true`.
- A private `void _showSnackBar(String message)` mirrors the one in
  `main.dart` (guard on `mounted`, delegate to `showAppSnackBar`).

### Changes to `lib/main.dart`

- `_openSettings()` collapses to:
  ```dart
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
  ```
- Remove `_openThemePicker()` and `_deleteAccount()` from
  `_MainNavigatorState` - both move into `SettingsScreen` and have no other
  callers.
- Add the `settings_screen.dart` import; remove any imports left unused by
  the deletions (e.g. `ChangePasswordScreen`, `ForgotPasswordScreen` if they
  are no longer referenced in `main.dart` - verify with the analyzer and
  only remove genuinely-unused ones).
- The `ProfileScreen(onSettings: _openSettings, ...)` wiring is unchanged.

## Net effect

- Settings is a full screen with the standard app back-arrow, grouped into
  ACCOUNT / APPEARANCE / NOTIFICATIONS sections plus a separated Delete
  Account danger card - more room and a cleaner look than the cramped sheet.
- Every action behaves exactly as it did in the sheet.
- `main.dart` sheds the inline settings UI and its two helper methods.

## Scope

- Create: `lib/screens/settings_screen.dart`
- Modify: `lib/main.dart` (replace `_openSettings` body, remove
  `_openThemePicker`/`_deleteAccount`, fix imports)

## Out of scope

- Moving Edit Profile or Log Out into Settings (they stay as their own
  Profile-screen buttons - user chose "just move the 6 pop-up items as-is").
- Any change to what the six actions do, or to the theme picker / delete
  confirmation dialogs beyond relocating them.
- Redesigning the theme picker into an inline list - it stays a dialog
  opened from the App Theme row.
