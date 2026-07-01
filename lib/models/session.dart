class Session {
  final String id;
  final String title;
  final String mentorName;
  final String mentorImage;
  final DateTime date;
  final String time;
  final String status;

  Session({
    required this.id,
    required this.title,
    required this.mentorName,
    required this.mentorImage,
    required this.date,
    required this.time,
    required this.status,
  });
}
