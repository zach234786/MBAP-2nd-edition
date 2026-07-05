import 'package:flutter/material.dart';
import 'package:tpmentorship/theme/app_theme.dart';

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
