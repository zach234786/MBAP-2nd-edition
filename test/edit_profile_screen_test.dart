import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tpmentorship/models/user_profile.dart';
import 'package:tpmentorship/screens/edit_profile_screen.dart';

// a profile with every onboarding-required field already valid, so tests
// can isolate the one behaviour they're checking (e.g. the subjects gate)
// without tripping the form's other validators
UserProfile _validProfile({List<String> subjects = const []}) {
  return UserProfile(
    uid: 'u1',
    fullName: 'Ada Lovelace',
    studentId: '2501587F',
    course: 'Diploma in AAI',
    academicYear: 'Year 1',
    createdAt: DateTime(2026, 1, 1),
    subjects: subjects,
  );
}

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      // NoSplash avoids Material 3's default ink-sparkle splash, whose
      // fragment shader fails to decode in this test environment
      // ("Unsupported runtime stages format version") whenever a tap
      // animation is left to run to completion
      theme: ThemeData(splashFactory: NoSplash.splashFactory),
      home: child,
    ),
  );
}

void main() {
  group('EditProfileScreen onboarding lock', () {
    testWidgets('onboarding mode hides the back button and blocks popping',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile(), isOnboarding: true),
      ));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.automaticallyImplyLeading, isFalse);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isFalse);
    });

    testWidgets('regular edit mode keeps the back button and allows popping',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile()),
      ));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.automaticallyImplyLeading, isTrue);

      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, isTrue);
    });

    testWidgets('onboarding mode blocks saving with no subjects selected',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(
            profile: _validProfile(subjects: const []), isOnboarding: true),
      ));

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      // let the snackbar animate in

      expect(find.text('Please select at least one subject'), findsOneWidget);
      // still on the same screen - Navigator never popped
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets(
        'onboarding mode does not block saving when a subject is selected',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(
            profile: _validProfile(subjects: const ['DAVA']),
            isOnboarding: true),
      ));

      await tester.ensureVisible(find.text('Save Changes'));
      await tester.tap(find.text('Save Changes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
          find.text('Please select at least one subject'), findsNothing);
    });

    testWidgets('shows the notifications toggle only in onboarding mode',
        (tester) async {
      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile(), isOnboarding: true),
      ));
      final onboardingSwitch =
          tester.widget<SwitchListTile>(find.byType(SwitchListTile));
      expect(onboardingSwitch.value, isTrue);

      await tester.pumpWidget(_wrap(
        EditProfileScreen(profile: _validProfile()),
      ));
      expect(find.byType(SwitchListTile), findsNothing);
    });
  });
}
