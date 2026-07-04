import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/models/session.dart';
import 'package:tpmentorship/models/message.dart';

class SampleData {
  static List<Mentor> getMentors() {
    return [
      Mentor(
        id: '1',
        name: 'Damian Tan',
        specialization: 'Code',
        rating: 4.8,
        reviewCount: 45,
        isOnline: true,
      ),
      Mentor(
        id: '2',
        name: 'Jovan Tan',
        specialization: 'Cybersecurity',
        rating: 4.9,
        reviewCount: 62,
        isOnline: true,
      ),
      Mentor(
        id: '3',
        name: 'Alsagoff Tan',
        specialization: 'Web Dev',
        rating: 4.6,
        reviewCount: 38,
        isOnline: false,
      ),
      Mentor(
        id: '4',
        name: 'Ashin Tan',
        specialization: 'AI/ML',
        rating: 4.7,
        reviewCount: 51,
        isOnline: true,
      ),
    ];
  }

  static List<Session> getUpcomingSessions() {
    return [
      Session(
        id: '1',
        title: 'Web Development Basics',
        mentorName: 'Marcus Lim',
        date: DateTime.now().add(const Duration(days: 3)),
        time: '3:00 PM',
        status: 'Pending',
      ),
      Session(
        id: '2',
        title: 'Data Analytics 101',
        mentorName: 'Nur Adilah',
        date: DateTime.now().add(const Duration(days: 5)),
        time: '4:30 PM',
        status: 'Pending',
      ),
    ];
  }

  static List<Message> getMessages() {
    return [
      Message(
        id: '1',
        senderName: 'Marcus Lim',
        content: 'Hey John! Looking forward to our session!',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        isOnline: true,
      ),
      Message(
        id: '2',
        senderName: 'Nur Adilah',
        content: 'Here are the notes from today\'s session...',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
        isOnline: true,
      ),
      Message(
        id: '3',
        senderName: 'Daniel Wong',
        content: 'Let me know if you need any help!',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        unreadCount: 0,
        isOnline: false,
      ),
    ];
  }

  static List<Map<String, String>> getReviews() {
    return [
      {
        'name': 'Nur Adilah',
        'subject': 'Data Analytics',
        'rating': '5.0',
        'review': 'Great mentor! Explained everything clearly and helped me understand complex concepts.',
        'timeAgo': '2 days ago',
      },
      {
        'name': 'Daniel Wong',
        'subject': 'Cybersecurity',
        'rating': '4.8',
        'review': 'Very patient and knowledgeable. The session was super helpful!',
        'timeAgo': '1 week ago',
      },
    ];
  }
}
