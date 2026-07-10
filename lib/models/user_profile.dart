import 'package:cloud_firestore/cloud_firestore.dart';
// needed for Timestamp, the date type Firestore uses

class UserProfile {
// extra info about a user that Firebase Auth does not store
// (the "users" table from the proposal), kept in the "users" collection
// the document id is the user's Firebase Auth uid so auth and firestore link up
  final String uid;
  final String fullName;
  final String studentId;
  final String course;
  final String academicYear;
  final String bio;
  final bool isPremium;
  // true after the user pays for premium via the NETS QR flow
  final List<String> subjects;
  // subjects the student wants help with (the "student needs" from the proposal)
  // this is what the AI matching feature uses to recommend mentors
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.fullName,
    this.studentId = '',
    this.course = '',
    this.academicYear = '',
    this.bio = '',
    this.isPremium = false,
    this.subjects = const [],
    required this.createdAt,
  });

  // builds a UserProfile from a Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      fullName: (data['fullName'] ?? '') as String,
      studentId: (data['studentId'] ?? '') as String,
      course: (data['course'] ?? '') as String,
      academicYear: (data['academicYear'] ?? '') as String,
      bio: (data['bio'] ?? '') as String,
      isPremium: (data['isPremium'] ?? false) as bool,
      subjects: List<String>.from((data['subjects'] ?? []) as List),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // converts this profile into a plain map so Firestore can save it
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'studentId': studentId,
      'course': course,
      'academicYear': academicYear,
      'bio': bio,
      'isPremium': isPremium,
      'subjects': subjects,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
