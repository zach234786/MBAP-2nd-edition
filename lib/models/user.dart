class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final String? course;
  final String? academicYear;
  final bool isPremium;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    this.course,
    this.academicYear,
    this.isPremium = false,
  });
}
