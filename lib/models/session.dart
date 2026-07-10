import 'package:cloud_firestore/cloud_firestore.dart';
// needed for Timestamp, the date type Firestore uses

class Session {
// one booked mentoring session (the "appointments" table from the proposal)
// this is the CRUD domain for Part 3, stored in the "appointments" collection
  final String id;
  final String title;
  final String mentorName;
  final DateTime date;
  final String time;
  final String status;
  // Pending / Confirmed / Completed / Cancelled
  final String studentId;
  // firebase auth uid of the student who booked the session
  final String mentorId;
  // firestore document id of the mentor
  final String subject;
  // the subject the session is about (eg DAVA)
  final String notes;
  // optional extra info the student typed when booking

  Session({
    required this.id,
    required this.title,
    required this.mentorName,
    required this.date,
    required this.time,
    required this.status,
    this.studentId = '',
    this.mentorId = '',
    this.subject = '',
    this.notes = '',
  });

  // builds a Session object from a Firestore document
  factory Session.fromMap(Map<String, dynamic> data, String id) {
    return Session(
      id: id,
      title: (data['title'] ?? '') as String,
      mentorName: (data['mentorName'] ?? '') as String,
      // firestore stores dates as Timestamp so convert back to DateTime
      date: data['date'] is Timestamp
          ? (data['date'] as Timestamp).toDate()
          : DateTime.now(),
      time: (data['time'] ?? '') as String,
      status: (data['status'] ?? 'Pending') as String,
      studentId: (data['studentId'] ?? '') as String,
      mentorId: (data['mentorId'] ?? '') as String,
      subject: (data['subject'] ?? '') as String,
      notes: (data['notes'] ?? '') as String,
    );
  }

  // converts this Session into a plain map so Firestore can save it
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'mentorName': mentorName,
      // convert DateTime into Firestore's Timestamp type
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'studentId': studentId,
      'mentorId': mentorId,
      'subject': subject,
      'notes': notes,
    };
  }

  // makes a copy of this session with only some fields changed
  // used when updating (eg rescheduling keeps everything except date/time)
  Session copyWith({
    DateTime? date,
    String? time,
    String? status,
    String? notes,
  }) {
    return Session(
      id: id,
      title: title,
      mentorName: mentorName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      studentId: studentId,
      mentorId: mentorId,
      subject: subject,
      notes: notes ?? this.notes,
    );
  }
}
