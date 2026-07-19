import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/models/student.dart';
import 'package:tpmentorship/providers/auth_provider.dart';
import 'package:tpmentorship/providers/data_providers.dart';
import 'package:tpmentorship/screens/search_screen.dart';

// builds the SearchScreen with every Firestore-backed provider it reads
// stubbed out, so the widget tree can build without a real Firebase app
Widget _buildTestApp({required bool isMentor}) {
  return ProviderScope(
    overrides: [
      isMentorProvider.overrideWithValue(isMentor),
      authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
      mentorsProvider.overrideWith((ref) => Stream.value(<Mentor>[])),
      studentsProvider.overrideWith((ref) => Stream.value(<Student>[])),
      mentorsByRatingProvider.overrideWith(
          (ref, range) => Stream.value(<Mentor>[])),
    ],
    child: MaterialApp(
      home: Scaffold(body: SearchScreen()),
    ),
  );
}

void main() {
  group('SearchScreen hamburger menu', () {
    testWidgets('menu icon is visible even when the user is not a mentor',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(isMentor: false));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });
  });
}
