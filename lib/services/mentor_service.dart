import 'package:cloud_firestore/cloud_firestore.dart';
// the firestore database package
import 'package:tpmentorship/models/mentor.dart';
// the mentor data type

class MentorService {
// handles everything to do with the "mentors" collection in Firestore
// screens never talk to Firestore directly, they go through this service
// (same pattern as AuthService so UI and database logic stay separate)

  final CollectionReference<Map<String, dynamic>> _mentors =
      FirebaseFirestore.instance.collection('mentors');
  // a reference to the "mentors" collection, private so only this class touches it

  // SELECT ALL with SORT ORDER (advanced query: sort)
  // streams every mentor ordered by rating, best first
  // a stream means the UI updates live whenever the data changes in Firestore
  Stream<List<Mentor>> streamAllMentors() {
    return _mentors
        .orderBy('rating', descending: true)
        .snapshots()
        .map(_toMentorList);
  }

  // SELECT with FILTER criteria other than the identifier (advanced query: filter)
  // finds mentors that teach a specific subject
  // arrayContains checks if the subject is inside the mentor's subjects list
  Stream<List<Mentor>> streamMentorsBySubject(String subject) {
    return _mentors
        .where('subjects', arrayContains: subject)
        .snapshots()
        .map(_toMentorList);
  }

  // SELECT with FILTER criteria (advanced query: filter on a single field)
  // finds mentors in one specialization area, eg "Development"
  Stream<List<Mentor>> streamMentorsBySpecialization(String specialization) {
    return _mentors
        .where('specialization', isEqualTo: specialization)
        .snapshots()
        .map(_toMentorList);
  }

  // SELECT with MULTIPLE FILTER criteria on the SAME field (advanced query)
  // finds mentors whose rating falls inside a range, eg between 4.0 and 4.5
  Stream<List<Mentor>> streamMentorsByRatingRange(double min, double max) {
    return _mentors
        .where('rating', isGreaterThanOrEqualTo: min)
        .where('rating', isLessThan: max)
        // two conditions on the same "rating" field = a range query
        .orderBy('rating', descending: true)
        .snapshots()
        .map(_toMentorList);
  }

  // SELECT ONE - gets a single mentor by document id
  Future<Mentor?> getMentor(String id) async {
    final doc = await _mentors.doc(id).get();
    if (!doc.exists) return null;
    // return null if the mentor was deleted or the id is wrong
    return Mentor.fromMap(doc.data()!, doc.id);
  }

  // helper that converts a firestore snapshot into a list of Mentor objects
  List<Mentor> _toMentorList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Mentor.fromMap(doc.data(), doc.id))
        .toList();
  }

  // fills the mentors collection with starting data the first time the app runs
  // so the database always has meaningful records to demo with
  Future<void> seedMentorsIfEmpty() async {
    final existing = await _mentors.limit(1).get();
    if (existing.docs.isNotEmpty) return;
    // collection already has data, do nothing

    // a batch groups many writes into one operation so its faster
    // and either all succeed or none do
    final batch = FirebaseFirestore.instance.batch();
    for (final mentor in _seedMentors) {
      batch.set(_mentors.doc(), mentor.toMap());
      // .doc() with no id makes firestore generate a random unique id
    }
    await batch.commit();
  }

  // the starting mentor records (10 meaningful mentors across TP subjects)
  static final List<Mentor> _seedMentors = [
    Mentor(
      id: '',
      name: 'Damian Tan',
      specialization: 'Development',
      rating: 4.8,
      reviewCount: 45,
      isOnline: true,
      subjects: ['DAVA', 'COMT'],
      availability: 'Mon 4-6pm',
      bio: 'Year 3 IT student who loves building apps. Happy to walk through code line by line.',
    ),
    Mentor(
      id: '',
      name: 'Jovan Tan',
      specialization: 'Cybersecurity',
      rating: 4.9,
      reviewCount: 62,
      isOnline: true,
      subjects: ['GSOST', 'COMT'],
      availability: 'Tue 3-5pm',
      bio: 'CTF player and security enthusiast. Ask me about networks and secure coding.',
    ),
    Mentor(
      id: '',
      name: 'Alsagoff Tan',
      specialization: 'Development',
      rating: 4.6,
      reviewCount: 38,
      isOnline: false,
      subjects: ['ECOMM', 'DAVA'],
      availability: 'Wed 2-4pm',
      bio: 'Full-stack web developer. I make HTML, CSS and JS actually make sense.',
    ),
    Mentor(
      id: '',
      name: 'Ashin Tan',
      specialization: 'AI & Machine Learning',
      rating: 4.7,
      reviewCount: 51,
      isOnline: true,
      subjects: ['LOMA', 'DAVA'],
      availability: 'Thu 5-7pm',
      bio: 'Fascinated by machine learning. I explain models with drawings, not math dumps.',
    ),
    Mentor(
      id: '',
      name: 'Marcus Lim',
      specialization: 'Development',
      rating: 4.5,
      reviewCount: 29,
      isOnline: true,
      subjects: ['COMT', 'ECOMM'],
      availability: 'Fri 4-6pm',
      bio: 'Web development tutor for 2 years. Patient with beginners, promise.',
    ),
    Mentor(
      id: '',
      name: 'Nur Adilah',
      specialization: 'Data',
      rating: 5.0,
      reviewCount: 74,
      isOnline: true,
      subjects: ['DAVA', 'LOMA'],
      availability: 'Mon 2-4pm',
      bio: 'Data analytics is my thing. Excel, Python, dashboards - bring your questions.',
    ),
    Mentor(
      id: '',
      name: 'Daniel Wong',
      specialization: 'Cybersecurity',
      rating: 4.3,
      reviewCount: 21,
      isOnline: false,
      subjects: ['GSOST'],
      availability: 'Sat 10am-12pm',
      bio: 'Focused on governance and security operations. Great for GSOST revision.',
    ),
    Mentor(
      id: '',
      name: 'Sarah Chen',
      specialization: 'Data',
      rating: 4.4,
      reviewCount: 33,
      isOnline: true,
      subjects: ['LOMA', 'ECOMM'],
      availability: 'Tue 6-8pm',
      bio: 'Logistics and maths tutor. I turn scary formulas into simple steps.',
    ),
    Mentor(
      id: '',
      name: 'Irfan Hakim',
      specialization: 'AI & Machine Learning',
      rating: 4.2,
      reviewCount: 18,
      isOnline: true,
      subjects: ['DAVA', 'GSOST'],
      availability: 'Wed 5-7pm',
      bio: 'Year 2 AAI student. Best at explaining things I struggled with myself.',
    ),
    Mentor(
      id: '',
      name: 'Rachel Ng',
      specialization: 'Development',
      rating: 3.9,
      reviewCount: 12,
      isOnline: false,
      subjects: ['ECOMM'],
      availability: 'Thu 3-5pm',
      bio: 'E-commerce project survivor. I can help you plan and build your storefront.',
    ),
  ];
}
