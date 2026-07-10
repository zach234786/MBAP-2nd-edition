import 'package:flutter/material.dart';
// built in ui widgets
import 'package:tpmentorship/models/mentor.dart';
// the mentor data type
import 'package:tpmentorship/screens/book_session_screen.dart';
// the booking form
import 'package:tpmentorship/services/share_service.dart';
// additional feature: sharing and opening web links
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/utils/snackbar_helper.dart';
// helper to show popup messages

class MentorDetailScreen extends StatelessWidget {
// shows one mentor's full details with a button to book a session
// (this is where tapping a mentor card anywhere in the app leads)
  final Mentor mentor;
  // the mentor to show

  const MentorDetailScreen({super.key, required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: const Text('Mentor Profile'),
        actions: [
          // additional feature: share this mentor by email
          IconButton(
            icon: Icon(Icons.share, color: AppTheme.textPrimary),
            onPressed: () async {
              final ok = await ShareService.shareMentorByEmail(mentor);
              if (!ok && context.mounted) {
                showAppSnackBar(context, 'Could not open your email app');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- top card: picture, name, rating -----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkCardBg,
                  border: Border.all(color: AppTheme.darkBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // profile picture with online dot
                    Stack(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.tpRed, width: 3),
                            color: AppTheme.darkBg,
                          ),
                          child: Icon(Icons.person,
                              color: AppTheme.textSecondary, size: 42),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mentor.isOnline
                                  ? Colors.green
                                  : Colors.grey,
                              border: Border.all(
                                  color: AppTheme.darkCardBg, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mentor.name,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mentor.specialization,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    // star rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${mentor.rating}',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '  (${mentor.reviewCount} reviews)',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ----- about section -----
              if (mentor.bio.isNotEmpty) ...[
                Text('About',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  mentor.bio,
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5),
                ),
                const SizedBox(height: 16),
              ],

              // ----- subjects as chips -----
              Text('Subjects',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: mentor.subjects
                    .map((subject) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.tpRed),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            subject,
                            style: TextStyle(
                              color: AppTheme.tpRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // ----- availability -----
              if (mentor.availability.isNotEmpty) ...[
                Text('Availability',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule,
                        color: AppTheme.tpRed, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      mentor.availability,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // additional feature: open the TP website inside the app
              GestureDetector(
                onTap: () async {
                  final ok = await ShareService.openStudyResources();
                  if (!ok && context.mounted) {
                    showAppSnackBar(context, 'Could not open the link');
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.link, color: AppTheme.tpRed, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'View TP study resources',
                      style: TextStyle(
                        color: AppTheme.tpRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.tpRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ----- book session button -----
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookSessionScreen(mentor: mentor),
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month, size: 18),
                label: const Text('Book a Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
