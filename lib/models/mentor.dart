class Mentor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isOnline;
  final int sessionCount;

  Mentor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isOnline,
    required this.sessionCount,
  });
}
