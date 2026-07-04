import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tpmentorship/firebase_options.dart';
import 'package:tpmentorship/providers/auth_provider.dart';
import 'package:tpmentorship/services/auth_service.dart';
import 'package:tpmentorship/theme/app_theme.dart';
import 'package:tpmentorship/utils/snackbar_helper.dart';
import 'package:tpmentorship/screens/home_screen.dart';
import 'package:tpmentorship/screens/search_screen.dart';
import 'package:tpmentorship/screens/messages_screen.dart';
import 'package:tpmentorship/screens/profile_screen.dart';
import 'package:tpmentorship/screens/mentor_profile_screen.dart';
import 'package:tpmentorship/screens/login_screen.dart';
import 'package:tpmentorship/screens/register_screen.dart';
import 'package:tpmentorship/screens/forgot_password_screen.dart';
import 'package:tpmentorship/screens/change_password_screen.dart';

/// Global handle to the app's Navigator so AuthGate can clear any pushed
/// screens (e.g. Change Password) when the user signs out.
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Make sure Flutter is ready before we talk to Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ProviderScope turns on Riverpod for the whole app.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TP Mentorship',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Removes the stretchy / elastic overscroll effect on all screens.
      scrollBehavior: const NoStretchScrollBehavior(),
      home: const AuthGate(),
    );
  }
}

/// A scroll behaviour that disables the bouncy/stretchy overscroll so the
/// screens do not visually "stretch" when you drag past the top or bottom.
class NoStretchScrollBehavior extends MaterialScrollBehavior {
  const NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return the child as-is = no glow and no stretch indicator.
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Clamping = stops firmly at the edges, no elastic bounce.
    return const ClampingScrollPhysics();
  }
}

/// AuthGate decides what to show based on REAL Firebase login state.
/// - Logged in  -> MainNavigator (the 5-tab app)
/// - Logged out -> AuthFlow (login / register / forgot password)
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // When the user signs out (or their account is deleted), swap back to the
    // login flow AND pop any screens that were pushed on top (e.g. Change
    // Password) - otherwise a pushed route would stay visible above AuthGate.
    ref.listen(authStateProvider, (previous, next) {
      if (next.hasValue && next.value == null) {
        _navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });

    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigator();
        }
        return const AuthFlow();
      },
      loading: () => const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.tpRed),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: Text(
            'Something went wrong: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Handles switching between the three auth screens.
class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});

  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  String _screen = 'login'; // login, register, forgot_password

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case 'register':
        return RegisterScreen(
          onGoToLogin: () => setState(() => _screen = 'login'),
        );
      case 'forgot_password':
        return ForgotPasswordScreen(
          onGoToLogin: () => setState(() => _screen = 'login'),
        );
      case 'login':
      default:
        return LoginScreen(
          onGoToRegister: () => setState(() => _screen = 'register'),
          onGoToForgotPassword: () =>
              setState(() => _screen = 'forgot_password'),
        );
    }
  }
}

/// The main app shell with the 5-tab BottomNavigationBar.
class MainNavigator extends ConsumerStatefulWidget {
  const MainNavigator({super.key});

  @override
  ConsumerState<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends ConsumerState<MainNavigator> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // After the first frame, ask Google/GitHub users without a display name
    // what the app should call them. Email/password users already set a
    // name on the register form, so they are never prompted.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _promptForNameIfNeeded());
  }

  /// The name the app greets the user with (from Firebase's displayName).
  String get _greetingName {
    final name = ref.read(authServiceProvider).displayName;
    return name.isNotEmpty ? name : 'Student';
  }

  Future<void> _promptForNameIfNeeded() async {
    final authService = ref.read(authServiceProvider);
    if (!mounted ||
        authService.isEmailPasswordAccount ||
        authService.displayName.isNotEmpty) {
      return;
    }

    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // the app needs a name to greet them with
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCardBg,
        title: const Text(
          'What should TPMentorship call you?',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return; // need a name
              Navigator.pop(dialogContext);
            },
            child: const Text('Save',
                style: TextStyle(
                    color: AppTheme.tpRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    final name = controller.text.trim();
    controller.dispose();
    if (name.isEmpty) return;
    try {
      await ref.read(authServiceProvider).updateDisplayName(name);
    } catch (e) {
      if (mounted) _showSnackBar(AuthService.friendlyError(e));
    }
    // Rebuild so the Home greeting and Mentor Profile pick up the new name.
    if (mounted) setState(() {});
  }

  void _onNavItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showSnackBar(String message) {
    // The mounted guard matters here: some callers await first (e.g. resend
    // verification), and this State could be disposed by then.
    if (!mounted) return;
    showAppSnackBar(context, message);
  }

  void _logout() {
    ref.read(authServiceProvider).logout().catchError((Object e) {
      if (mounted) _showSnackBar(AuthService.friendlyError(e));
    });
  }

  /// Confirms with the user, then permanently deletes their Firebase account.
  /// On success the auth state changes and AuthGate returns to the login screen.
  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.darkCardBg,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This permanently deletes your account. This cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppTheme.tpRed, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(authServiceProvider).deleteAccount();
      // Success: user is signed out, AuthGate swaps back to the login screen.
    } catch (e) {
      if (mounted) _showSnackBar(AuthService.friendlyError(e));
    }
  }

  /// Opens a Settings sheet with the account-management features:
  /// change password, email verification, and delete account.
  void _openSettings() {
    final authService = ref.read(authServiceProvider);
    // Show the sheet immediately, then refresh the user in the background so
    // the "Email Verified" status updates once fresh data arrives (it's cached
    // locally until we reload). A one-time guard keeps it to a single reload.
    var reloadStarted = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (!reloadStarted) {
              reloadStarted = true;
              authService.reloadUser().then((_) {
                if (sheetContext.mounted) setSheetState(() {});
              }).catchError((_) {
                // Ignore refresh failures; keep showing cached status.
              });
            }
            return SafeArea(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Account Settings',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: AppTheme.tpRed),
                title: const Text('Change Password',
                    style: TextStyle(color: AppTheme.textPrimary)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (!authService.isEmailPasswordAccount) {
                    _showSnackBar('Only available for email/password accounts');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangePasswordScreen(
                          onForgotPassword: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordScreen(
                                  // Here "back" returns to Change Password
                                  // (the user is logged in), so don't label
                                  // the link "Back to Login".
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
                },
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
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () async {
                  Navigator.pop(sheetContext);
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
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_forever, color: AppTheme.tpRed),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(color: AppTheme.tpRed),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _deleteAccount();
                },
              ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(
              userName: _greetingName,
              // Tapping a mentor card just shows a small popup for now -
              // browsing OTHER mentors' profiles is Part 3 scope.
              onMentorTap: (mentor) =>
                  _showSnackBar("Opening ${mentor.name}'s profile"),
              onSessionTap: () => _showSnackBar('Session details'),
              onViewAllSessions: () => _showSnackBar('Viewing all sessions'),
              onViewAllMessages: () => setState(() => _selectedIndex = 2),
              onNavigateToSearch: () => setState(() => _selectedIndex = 1),
              onNavigateToMessages: () => setState(() => _selectedIndex = 2),
            ),
            SearchScreen(
              onMentorTap: (mentor) =>
                  _showSnackBar("Opening ${mentor.name}'s profile"),
              onBack: () => setState(() => _selectedIndex = 0),
            ),
            MessagesScreen(
              onBack: () => setState(() => _selectedIndex = 0),
            ),
            ProfileScreen(
              userName: _greetingName,
              onEditProfile: () => _showSnackBar('Edit profile - coming soon'),
              onSettings: _openSettings,
              onLogout: _logout,
              onSeeMore: () => _showSnackBar('See more features'),
              onBack: () => setState(() => _selectedIndex = 0),
            ),
            MentorProfileScreen(
              // The tab shows the LOGGED-IN user's own mentor profile,
              // greeting them by their chosen display name.
              userName: _greetingName,
              onBack: () => setState(() => _selectedIndex = 0),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Mentor Profile'),
        ],
      ),
    );
  }
}
