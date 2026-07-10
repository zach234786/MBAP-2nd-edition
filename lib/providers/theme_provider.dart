import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:shared_preferences/shared_preferences.dart';
// saves small values on the device so they survive app restarts
import 'package:tpmentorship/theme/app_theme.dart';
// the palettes

class ThemeController extends StateNotifier<AppPalette> {
// part 3 personalisation: remembers and switches the app's theme
// StateNotifier holds one value (the active palette) and tells
// every listener when it changes

  static const _prefsKey = 'selected_theme';
  // the key the choice is saved under on the device

  ThemeController() : super(AppTheme.current);
  // start with whatever palette main() loaded before the app ran

  // switches the theme and saves the choice for next launch
  Future<void> setPalette(AppPalette palette) async {
    AppTheme.applyPalette(palette);
    // swap all the colour values
    state = palette;
    // tell the app to rebuild with them

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, palette.name);
    // remember the choice on the device
  }

  // reads the saved choice - called once in main() BEFORE the app builds
  // so the very first frame already has the right colours
  static Future<void> loadSavedPalette() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefsKey);
    if (name != null) {
      AppTheme.applyPalette(AppTheme.paletteByName(name));
    }
  }
}

// the provider screens watch to know the active theme
final themeProvider =
    StateNotifierProvider<ThemeController, AppPalette>((ref) {
  return ThemeController();
});
