# Search screen hamburger menu: always visible, student-mode locked for non-mentors

## Problem

The search screen's hamburger menu (mentor/student mode toggle) is currently
hidden entirely for non-mentor users (`lib/screens/search_screen.dart:195-201`,
gated on `isMentorProvider`). This is inconsistent: a new student user sees a
different header layout than a mentor user, and there's no visible path
suggesting "browse students" is a feature that exists at all.

## Design

**Always show the hamburger icon**, regardless of `isMentorProvider`. Remove
the `if (isMentor)` gate around the icon in `build()`.

**Inside `_openModeMenu()`**, both options are always listed. The
"A Student to Mentor" `ListTile` gets a locked visual treatment when
`!isMentor`:

- Icon and text color: `AppTheme.textSecondary` instead of `AppTheme.tpRed` /
  `AppTheme.textPrimary` (matches the muted style used elsewhere for disabled
  states)
- Trailing widget: `Icon(Icons.lock_outline, color: AppTheme.textSecondary)`
  instead of the checkmark
- Wrapped in a `Tooltip(message: 'Sign up as a mentor to unlock this')` — shown
  on long-press on mobile
- `onTap`: does NOT change `_mode`. Instead calls
  `showAppSnackBar(context, 'Sign up as a mentor to unlock this')`. The bottom
  sheet stays open (no `Navigator.pop`).

When `isMentor` is true, behavior is unchanged from today (tap switches mode,
closes sheet, shows checkmark on the active option).

## Scope

Single-file change: `lib/screens/search_screen.dart`. No provider, data model,
or navigation changes.

## Out of scope

- Deep-linking the locked row to the "become a mentor" flow (explicitly
  declined by user — locked row is inert except for the tooltip/snackbar)
- Any change to `isMentorProvider` or how mentor status is determined
