# Remove Midnight Purple theme

## Problem

Settings > App Theme currently offers three palettes (TP Dark, TP Light,
Midnight Purple). Only light and dark should remain.

## Design

In `lib/theme/app_theme.dart`:
- Delete the `midnightPurple` `AppPalette` const.
- Remove it from the `palettes` list, leaving `[tpDark, tpLight]`.

No other changes needed:
- `main.dart`'s `_openThemePicker()` builds its rows from `AppTheme.palettes`,
  so it automatically shows only the two remaining options.
- `AppTheme.paletteByName()` already falls back to `tpDark` when a saved name
  doesn't match any palette, so a device with `'Midnight Purple'` previously
  saved in SharedPreferences degrades gracefully to TP Dark on next launch.

## Scope

Single-file change: `lib/theme/app_theme.dart`.
