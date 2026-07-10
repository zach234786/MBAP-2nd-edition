import 'package:flutter/material.dart';
// built in ui widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/data/sample_data.dart';
// sample data still used for the messages preview only
import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/models/session.dart';
// the data types
import 'package:tpmentorship/providers/ai_provider.dart';
import 'package:tpmentorship/providers/data_providers.dart';
// live firestore + AI providers
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/widgets/mentor_card.dart';
// the small mentor card widget
import 'package:tpmentorship/widgets/session_card.dart';
// the session card widget

class HomeScreen extends ConsumerWidget {
// the main landing screen after logging in
// ConsumerWidget so it can watch the live firestore providers
  final String userName;
  // the logged in username shown in greeting

  // used to handle taps and navigation
  final ValueChanged<Mentor>? onMentorTap;
  final ValueChanged<Session>? onSessionTap;
  final VoidCallback? onViewAllSessions;
  final VoidCallback? onViewAllAiMatches;
  final VoidCallback? onViewAllMessages;
  final VoidCallback? onNavigateToSearch;
  final VoidCallback? onNavigateToMessages;

  const HomeScreen({
    super.key,
    required this.userName,
    this.onMentorTap,
    this.onSessionTap,
    this.onViewAllSessions,
    this.onViewAllAiMatches,
    this.onViewAllMessages,
    this.onNavigateToSearch,
    this.onNavigateToMessages,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // AI-ranked mentor recommendations (the applied AI feature)
    final matchesAsync = ref.watch(mentorMatchesProvider);
    // this student's booked sessions, live from firestore
    final sessionsAsync = ref.watch(mySessionsProvider);
    // messages stay as sample data (messaging is not the CRUD domain)
    final messages = SampleData.getMessages();

    return SingleChildScrollView(
    // whole screen scrolls
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top bar with the logo, app name and a notification bell
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // the "TP" logo box
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.tpRedLight, AppTheme.tpRed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.tpRed.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Text(
                              'TP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(Icons.people,
                                color: Colors.white.withValues(alpha: 0.9), size: 9),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // TP Mentorship title
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'TP ',
                            style: TextStyle(
                              color: AppTheme.tpRed,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: 'Mentorship',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Icon(Icons.notifications_outlined,
                    color: AppTheme.textPrimary, size: 26),
              ],
            ),
          ),

          // greeting with the user name in red
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Hello ',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: userName,
                    style: TextStyle(
                      color: AppTheme.tpRed,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'Connect. Learn. Grow Together',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),

          // recommended mentors, ranked by the AI, scrolls sideways
          _sectionHeader('Recommended Mentors', 'View all >', onViewAllAiMatches,
              aiBadge: true),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: matchesAsync.when(
              // the AI ranking gives us loading / error / data states
              data: (matches) {
                if (matches.isEmpty) {
                  return Center(
                    child: Text(
                      'No mentors yet - check back soon!',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: matches.length > 5 ? 5 : matches.length,
                  // only the top 5 matches on the home screen
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 100,
                        child: MentorCard(
                          mentor: match.mentor,
                          onTap: () => onMentorTap?.call(match.mentor),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(
                  child: CircularProgressIndicator(color: AppTheme.tpRed)),
              error: (e, _) => Center(
                child: Text(
                  'Could not load mentors',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.search,
                    title: 'Find a Mentor',
                    subtitle: 'Explore and connect with mentors',
                    onTap: onNavigateToSearch,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.calendar_month,
                    title: 'Upcoming Sessions',
                    subtitle: 'View your upcoming sessions',
                    onTap: onViewAllSessions,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // upcoming sessions list, live from firestore
          _sectionHeader('Upcoming Sessions', 'View all >', onViewAllSessions),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: sessionsAsync.when(
              data: (sessions) {
                // only sessions that havent happened yet, next 2
                final upcoming = sessions
                    .where((s) => s.date.isAfter(DateTime.now()))
                    .take(2)
                    .toList();
                if (upcoming.isEmpty) {
                  // friendly empty state instead of a blank gap
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardBg,
                      border: Border.all(color: AppTheme.darkBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.event_available,
                            color: AppTheme.textSecondary, size: 28),
                        const SizedBox(height: 8),
                        Text(
                          'No upcoming sessions - find a mentor and book one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: upcoming
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SessionCard(
                                session: s,
                                onTap: () => onSessionTap?.call(s)),
                          ))
                      .toList(),
                      // one session card per session
                );
              },
              loading: () => Center(
                  child: CircularProgressIndicator(color: AppTheme.tpRed)),
              error: (e, _) => Text(
                'Could not load sessions',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // messages preview
          _sectionHeader('Messages', 'View all >', onNavigateToMessages),
          const SizedBox(height: 8),
          ...messages.take(3).map(
                (message) => GestureDetector(
                  onTap: onNavigateToMessages,
                  // tapping any message opens the messages screen
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.darkCardBg,
                      border: Border.all(color: AppTheme.darkBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        // profile picture
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.tpRed, width: 2),
                                color: AppTheme.darkBg,
                              ),
                              child: Icon(Icons.person,
                                  color: AppTheme.textSecondary, size: 20),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: message.isOnline
                                      ? Colors.green
                                      : Colors.grey,
                                  border: Border.all(
                                      color: AppTheme.darkCardBg, width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        // sender name and message preview
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.senderName,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                message.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        // unread count bubble only if there are unread messages
                        if (message.unreadCount > 0)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.tpRed,
                            ),
                            child: Center(
                              child: Text(
                                '${message.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback? onTap,
      {bool aiBadge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (aiBadge) ...[
                // small badge showing this section is AI powered
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.tpRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppTheme.tpRed.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppTheme.tpRed, size: 10),
                      const SizedBox(width: 3),
                      Text(
                        'AI',
                        style: TextStyle(
                          color: AppTheme.tpRed,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: TextStyle(
                color: AppTheme.tpRed,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.darkCardBg,
          border: Border.all(color: AppTheme.darkBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // the icon box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.tpRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.tpRed.withValues(alpha: 0.4)),
              ),
              child: Icon(icon, color: AppTheme.tpRed, size: 18),
            ),
            const SizedBox(width: 10),
            // title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
