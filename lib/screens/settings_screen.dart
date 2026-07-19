import 'package:flutter/foundation.dart' show kIsWeb;
// detect web vs mobile (notifications are mobile-only)
import 'package:flutter/material.dart';
// built in ui widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/providers/auth_provider.dart';
import 'package:tpmentorship/providers/data_providers.dart';
import 'package:tpmentorship/providers/theme_provider.dart';
// the app's providers
import 'package:tpmentorship/services/auth_service.dart';
// for friendly error messages
import 'package:tpmentorship/services/notification_service.dart';
// the test notification + permission request
import 'package:tpmentorship/screens/change_password_screen.dart';
import 'package:tpmentorship/screens/forgot_password_screen.dart';
// pushed from the change-password row
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/utils/snackbar_helper.dart';
// helper to show popup messages

class SettingsScreen extends ConsumerStatefulWidget {
// the account settings, moved out of main.dart's bottom sheet into a
// dedicated screen grouped into ACCOUNT / APPEARANCE / NOTIFICATIONS
// sections plus a separated Delete Account danger card
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  // local mirror of the profile's notificationsEnabled, so the switch
  // reacts instantly while the write happens in the background

  @override
  void initState() {
    super.initState();
    _notificationsEnabled =
        ref.read(userProfileProvider).value?.notificationsEnabled ?? true;
    // reload the user so the email-verified row shows the latest state
    ref.read(authServiceProvider).reloadUser().then((_) {
      if (mounted) setState(() {});
    }).catchError((_) {});
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    showAppSnackBar(context, message);
  }

  // change password - only works for email/password accounts
  void _openChangePassword() {
    final authService = ref.read(authServiceProvider);
    if (!authService.isEmailPasswordAccount) {
      _showSnackBar('Only available for email/password accounts');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordScreen(
          onForgotPassword: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ForgotPasswordScreen(
                  backLabel: 'Back',
                  onGoToLogin: () => Navigator.pop(context),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // resend the verification email (with the same gates as before)
  Future<void> _handleEmailVerification() async {
    final authService = ref.read(authServiceProvider);
    if (!authService.isEmailPasswordAccount) {
      _showSnackBar('Only available for email/password accounts');
    } else if (authService.isEmailVerified) {
      _showSnackBar('Your email is already verified!');
    } else {
      try {
        await authService.sendEmailVerification();
        _showSnackBar('Verification email sent!');
      } catch (e) {
        _showSnackBar(AuthService.friendlyError(e));
      }
    }
  }

  // lets the user pick one of the app's colour themes (personalisation)
  void _openThemePicker() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCardBg,
        title: Text('App Theme',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          // one row per available palette
          children: AppTheme.palettes.map((palette) {
            final isActive = ref.read(themeProvider).name == palette.name;
            return ListTile(
              leading: CircleAvatar(
                radius: 10,
                backgroundColor: palette.accent,
                // little dot previewing the palette's accent colour
              ),
              title: Text(palette.name,
                  style: TextStyle(color: AppTheme.textPrimary)),
              trailing: isActive
                  ? Icon(Icons.check, color: AppTheme.tpRed)
                  : null,
              onTap: () {
                ref.read(themeProvider.notifier).setPalette(palette);
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // persists the notifications choice and requests the OS permission when
  // turning it on
  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    await ref.read(userServiceProvider).updateNotificationsEnabled(uid, value);
    if (value) {
      await NotificationService.instance.requestPermission();
    }
  }

  // fires a sample notification, unless notifications are turned off
  Future<void> _testNotification() async {
    if (!_notificationsEnabled) {
      _showSnackBar('Enable notifications first to test');
      return;
    }
    await NotificationService.instance.showTestNotification();
  }

  // confirmation dialog then permanent account deletion
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCardBg,
        title: Text('Delete Account',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'This permanently deletes your account. This cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete',
                style: TextStyle(
                    color: AppTheme.tpRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(authServiceProvider).deleteAccount();
      // AuthGate listens to authStateProvider and pops back to the login
      // screen once the user is gone, so no manual navigation here
    } catch (e) {
      if (mounted) _showSnackBar(AuthService.friendlyError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);
    final themeName = ref.watch(themeProvider).name;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- account -----
              _sectionHeader('Account'),
              _settingsCard([
                ListTile(
                  leading: Icon(Icons.lock_reset, color: AppTheme.tpRed),
                  title: Text('Change Password',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  onTap: _openChangePassword,
                ),
                ListTile(
                  leading: Icon(
                    authService.isEmailVerified
                        ? Icons.verified
                        : Icons.mark_email_unread,
                    color: AppTheme.tpRed,
                  ),
                  title: Text(
                    authService.isEmailVerified
                        ? 'Email Verified'
                        : 'Resend Verification Email',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: _handleEmailVerification,
                ),
              ]),

              // ----- appearance -----
              _sectionHeader('Appearance'),
              _settingsCard([
                ListTile(
                  leading:
                      Icon(Icons.palette_outlined, color: AppTheme.tpRed),
                  title: Text('App Theme',
                      style: TextStyle(color: AppTheme.textPrimary)),
                  subtitle: Text(themeName,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  trailing: Icon(Icons.chevron_right,
                      color: AppTheme.textSecondary),
                  onTap: _openThemePicker,
                ),
              ]),

              // ----- notifications (mobile only) -----
              if (!kIsWeb) ...[
                _sectionHeader('Notifications'),
                _settingsCard([
                  SwitchListTile(
                    secondary: Icon(Icons.notifications_outlined,
                        color: AppTheme.tpRed),
                    activeThumbColor: AppTheme.tpRed,
                    title: Text('Notifications',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                  ListTile(
                    leading: Icon(Icons.notifications_active_outlined,
                        color: AppTheme.tpRed),
                    title: Text('Test Notification',
                        style: TextStyle(color: AppTheme.textPrimary)),
                    onTap: _testNotification,
                  ),
                ]),
              ],

              // ----- danger zone -----
              const SizedBox(height: 28),
              _settingsCard([
                ListTile(
                  leading: Icon(Icons.delete_forever, color: AppTheme.tpRed),
                  title: Text('Delete Account',
                      style: TextStyle(color: AppTheme.tpRed)),
                  onTap: _deleteAccount,
                ),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // small uppercase grey label above each grouped card
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // a rounded card grouping the given rows with hairline dividers between
  // consecutive rows (not after the last one)
  Widget _settingsCard(List<Widget> children) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(Divider(height: 1, color: AppTheme.darkBorder));
      }
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.darkCardBg,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}
