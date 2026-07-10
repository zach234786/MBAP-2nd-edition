import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/models/session.dart';
import 'package:tpmentorship/models/user_profile.dart';
// the data types
import 'package:tpmentorship/providers/auth_provider.dart';
// gives us the logged in user
import 'package:tpmentorship/services/mentor_service.dart';
import 'package:tpmentorship/services/appointment_service.dart';
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

// ---------- mentors ----------

// all mentors sorted by rating (SELECT ALL + SORT)
// StreamProvider gives the UI loading / error / data states for free
final mentorsProvider = StreamProvider<List<Mentor>>((ref) {
  return ref.watch(mentorServiceProvider).streamAllMentors();
});

// mentors that teach one subject (SELECT with FILTER)
// .family lets the UI pass in which subject it wants, eg 'DAVA'
final mentorsBySubjectProvider =
    StreamProvider.family<List<Mentor>, String>((ref, subject) {
  return ref.watch(mentorServiceProvider).streamMentorsBySubject(subject);
});

// mentors in one specialization area (SELECT with FILTER)
final mentorsBySpecializationProvider =
    StreamProvider.family<List<Mentor>, String>((ref, specialization) {
  return ref
      .watch(mentorServiceProvider)
      .streamMentorsBySpecialization(specialization);
});

// mentors inside a rating range (MULTIPLE FILTERS on the SAME field)
// the parameter is a record holding both ends of the range
final mentorsByRatingProvider =
    StreamProvider.family<List<Mentor>, ({double min, double max})>(
        (ref, range) {
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
final mySessionsByStatusProvider =
    StreamProvider.family<List<Session>, String>((ref, status) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(const <Session>[]);
  return ref
      .watch(appointmentServiceProvider)
      .streamMySessionsByStatus(user.uid, status);
});

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
