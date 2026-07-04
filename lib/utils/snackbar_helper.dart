import 'package:flutter/material.dart';
import 'package:tpmentorship/theme/app_theme.dart';

/// Shows the app's standard SnackBar: red for errors, green for success.
/// One shared helper so feedback looks identical on every screen.
/// Callers inside a State should still guard with `if (!mounted) return;`
/// before calling this after an await.
void showAppSnackBar(BuildContext context, String message,
    {bool success = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : AppTheme.tpRed,
      duration: const Duration(seconds: 3),
    ),
  );
}
