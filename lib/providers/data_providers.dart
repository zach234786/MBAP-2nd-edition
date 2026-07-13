import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/models/review.dart';
import 'package:tpmentorship/models/session.dart';
import 'package:tpmentorship/models/student.dart';
import 'package:tpmentorship/models/user_profile.dart';
// the data types
import 'package:tpmentorship/providers/auth_provider.dart';
// gives us the logged in user
import 'package:tpmentorship/services/mentor_service.dart';
import 'package:tpmentorship/services/appointment_service.dart';
import 'package:tpmentorship/services/review_service.dart';
import 'package:tpmentorship/services/student_service.dart';
import 'package:tpmentorship/services/user_service.dart';
// the firestore services

// ---------- services ----------
// one shared instance of each service for the whole app,
// same pattern as authServiceProvider

final mentorServiceProvider = Provider<MentorService>((ref) {
  return MentorService();
});

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});

final studentServiceProvider = Provider<StudentService>((ref) {
  return StudentService();
});

// ---------- mentors ----------

// all mentors sorted by rating (SELECT ALL + SORT)
// StreamProvider gives the UI loading / error / data states for free
//
// watches authStateProvider (even though the uid isn't used) purely so
// this provider is torn down and rebuilt on every login/logout. mentors
// requires request.auth != null, so if this stream ever catches a
// permission error while briefly unauthenticated (eg mid-logout), the
// underlying Firestore listener dies for good - streams don't recover
// from an error on their own. without watching auth state, nothing tells
// Riverpod to recreate the listener on the next login, so mentors would
// stay broken until the app is fully restarted. same reasoning applies to
// every other provider below that reads an open (auth-required but not
// uid-scoped) collection: mentorsBySubject/Specialization/Rating,
// mentorReviews, and the students directory
final mentorsProvider = StreamProvider<List<Mentor>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(mentorServiceProvider).streamAllMentors();
});

// mentors that teach one subject (SELECT with FILTER)
// .family lets the UI pass in which subject it wants, eg 'DAVA'
final mentorsBySubjectProvider = StreamProvider.family<List<Mentor>, String>((
  ref,
  subject,
) {
  ref.watch(authStateProvider);
  return ref.watch(mentorServiceProvider).streamMentorsBySubject(subject);
});

// mentors in one specialization area (SELECT with FILTER)
final mentorsBySpecializationProvider =
    StreamProvider.family<List<Mentor>, String>((ref, specialization) {
      ref.watch(authStateProvider);
      return ref
          .watch(mentorServiceProvider)
          .streamMentorsBySpecialization(specialization);
    });

// mentors inside a rating range (MULTIPLE FILTERS on the SAME field)
// the parameter is a record holding both ends of the range
final mentorsByRatingProvider =
    StreamProvider.family<List<Mentor>, ({double min, double max})>((
      ref,
      range,
    ) {
      ref.watch(authStateProvider);
      return ref
          .watch(mentorServiceProvider)
          .streamMentorsByRatingRange(range.min, range.max);
    });

// ---------- sessions (appointments) ----------

// every session belonging to the logged in student (SELECT ALL)
final mySessionsProvider = StreamProvider<List<Session>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <Session>[]);
  // not logged in, just give back an empty list
  return ref.watch(appointmentServiceProvider).streamMySessions(user.uid);
});

// this student's sessions with one status
// (MULTIPLE FILTERS on DIFFERENT fields: studentId + status)
final mySessionsByStatusProvider = StreamProvider.family<List<Session>, String>(
  (ref, status) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return Stream.value(const <Session>[]);
    return ref
        .watch(appointmentServiceProvider)
        .streamMySessionsByStatus(user.uid, status);
  },
);

// how many sessions this student has completed (SELECT with AGGREGATION)
// FutureProvider because count() is a one-off request, not a live stream
final completedSessionsCountProvider = FutureProvider<int>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0;
  // watching mySessionsProvider makes this count refresh automatically
  // whenever the session list changes (eg one gets marked Completed)
  ref.watch(mySessionsProvider);
  return ref
      .watch(appointmentServiceProvider)
      .countSessionsByStatus(user.uid, 'Completed');
});

// ---------- user profile ----------

// the logged in user's firestore profile, streamed live
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(userServiceProvider).streamProfile(user.uid);
});

// true once the logged in user has signed up as a mentor - used to gate
// mentor-only UI like the search screen's browse-students toggle
final isMentorProvider = Provider<bool>((ref) {
  return ref.watch(userProfileProvider).value?.isMentor ?? false;
});

// how many sessions a mentor has completed - shown as the "N Sessions"
// badge on their profile (SELECT with AGGREGATION, same idea as
// completedSessionsCountProvider but counted per mentor instead of
// per student). watches auth state for the same reason as mentorsProvider
final mentorCompletedSessionsCountProvider = FutureProvider.family<int, String>(
  (ref, mentorId) {
    ref.watch(authStateProvider);
    return ref
        .watch(appointmentServiceProvider)
        .countSessionsByMentor(mentorId, 'Completed');
  },
);

// ---------- own mentor profile ----------

// the logged in user's OWN mentor listing (doc id == their auth uid),
// null if they have never signed up as a mentor yet
final myMentorProfileProvider = StreamProvider<Mentor?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.watch(mentorServiceProvider).streamMentor(user.uid);
});

// ---------- reviews ----------

// every review left for one mentor, newest first
final mentorReviewsProvider = StreamProvider.family<List<Review>, String>((
  ref,
  mentorId,
) {
  ref.watch(authStateProvider);
  return ref.watch(reviewServiceProvider).streamReviewsForMentor(mentorId);
});

// ---------- students (browse directory for mentors) ----------

final studentsProvider = StreamProvider<List<Student>>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(studentServiceProvider).streamAllStudents();
});

final studentsBySubjectProvider = StreamProvider.family<List<Student>, String>((
  ref,
  subject,
) {
  ref.watch(authStateProvider);
  return ref.watch(studentServiceProvider).streamStudentsBySubject(subject);
});
