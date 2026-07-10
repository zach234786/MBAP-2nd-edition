import 'dart:convert';
// for turning JSON text into dart objects and back
import 'package:http/http.dart' as http;
// for calling the Gemini web API
import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/models/user_profile.dart';
// the data types

class MentorMatch {
// one AI recommendation: a mentor, how well they fit (0-100)
// and a short explanation of why
  final Mentor mentor;
  final int score;
  final String reason;

  MentorMatch({
    required this.mentor,
    required this.score,
    required this.reason,
  });
}

class AiMatchingService {
// the applied AI feature: recommends the best mentors for this student
//
// how it works:
// 1. if a Gemini API key is set, the student's profile and the mentor list
//    are sent to Google's Gemini model, which ranks the mentors and writes
//    a short reason for each match
// 2. if there is no key, or the API call fails (no internet, quota hit),
//    a local scoring formula ranks them instead - so the feature
//    always works, even during a live demo with no network

  // paste your free Gemini API key here (https://aistudio.google.com/apikey)
  // leave empty to always use the local scoring fallback
  static const String geminiApiKey = '';

  // the Gemini model and endpoint used for ranking
  static const String _model = 'gemini-2.0-flash';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  // main entry point - returns mentors ranked best first
  Future<List<MentorMatch>> rankMentors({
    required UserProfile profile,
    required List<Mentor> mentors,
  }) async {
    if (mentors.isEmpty) return [];

    if (geminiApiKey.isEmpty) {
      // no key pasted in yet - use the local formula
      return _localRank(profile, mentors);
    }
    try {
      return await _geminiRank(profile, mentors);
    } catch (_) {
      // API failed (offline, quota, bad response) - fall back so the
      // recommendations never break
      return _localRank(profile, mentors);
    }
  }

  // ---------- option 1: ask Gemini to rank the mentors ----------

  Future<List<MentorMatch>> _geminiRank(
      UserProfile profile, List<Mentor> mentors) async {
    // describe each mentor in a compact way the model can read
    final mentorList = mentors
        .map((m) => '- id: ${m.id}, name: ${m.name}, '
            'specialization: ${m.specialization}, '
            'subjects: ${m.subjects.join("/")}, rating: ${m.rating}, '
            'online: ${m.isOnline}')
        .join('\n');

    // the instructions we send to the model
    final prompt = '''
You match polytechnic students with peer mentors.

Student:
- course: ${profile.course.isEmpty ? 'unknown' : profile.course}
- year: ${profile.academicYear.isEmpty ? 'unknown' : profile.academicYear}
- needs help with these subjects: ${profile.subjects.isEmpty ? 'not specified' : profile.subjects.join(', ')}

Mentors:
$mentorList

Rank ALL the mentors from best to worst fit for this student.
Reply with ONLY a JSON array, no other text. Each item must be:
{"id": "<mentor id>", "score": <0-100 how good the fit is>, "reason": "<one short friendly sentence why>"}
''';

    final response = await http
        .post(
          Uri.parse('$_endpoint?key=$geminiApiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ],
            // ask the model to reply in strict JSON so parsing is reliable
            'generationConfig': {'responseMimeType': 'application/json'},
          }),
        )
        .timeout(const Duration(seconds: 15));
    // give up after 15s rather than leaving the screen loading forever

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}');
    }

    // dig the model's text reply out of the response structure
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = body['candidates'][0]['content']['parts'][0]['text']
        as String;

    // the reply text is itself JSON (the ranked array we asked for)
    final ranked = jsonDecode(text) as List<dynamic>;

    // match each ranked id back to its Mentor object
    final byId = {for (final m in mentors) m.id: m};
    final matches = <MentorMatch>[];
    for (final item in ranked) {
      final mentor = byId[item['id']];
      if (mentor == null) continue;
      // skip ids the model made up (models sometimes do that)
      matches.add(MentorMatch(
        mentor: mentor,
        score: ((item['score'] ?? 0) as num).toInt().clamp(0, 100),
        reason: (item['reason'] ?? '') as String,
      ));
    }

    if (matches.isEmpty) throw Exception('Gemini returned no usable matches');
    return matches;
  }

  // ---------- option 2: local scoring formula (the fallback) ----------

  List<MentorMatch> _localRank(UserProfile profile, List<Mentor> mentors) {
    final matches = mentors.map((mentor) {
      // count how many of the student's subjects this mentor teaches
      final shared = mentor.subjects
          .where((s) => profile.subjects.contains(s))
          .toList();

      // the score formula:
      //   subject overlap matters most (up to 50 points)
      //   then rating (up to 40 points: 5.0 stars = 40)
      //   being online now is a small bonus (10 points)
      double score = 0;
      if (profile.subjects.isNotEmpty) {
        score += 50 * shared.length / profile.subjects.length;
      }
      score += mentor.rating * 8;
      if (mentor.isOnline) score += 10;

      // build a human readable reason from the same facts
      String reason;
      if (shared.isNotEmpty) {
        reason = 'Teaches ${shared.join(" and ")} which you need help with, '
            'rated ${mentor.rating}/5';
      } else if (profile.subjects.isEmpty) {
        reason = 'Highly rated ${mentor.specialization} mentor '
            '(${mentor.rating}/5) - set your subjects for better matches';
      } else {
        reason = 'No direct subject match, but strong in '
            '${mentor.specialization} (${mentor.rating}/5)';
      }

      return MentorMatch(
        mentor: mentor,
        score: score.round().clamp(0, 100),
        reason: reason,
      );
    }).toList();

    // highest score first
    matches.sort((a, b) => b.score.compareTo(a.score));
    return matches;
  }
}
