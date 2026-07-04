import 'package:flutter/material.dart';
import 'package:tpmentorship/data/sample_data.dart';
import 'package:tpmentorship/models/mentor.dart';
import 'package:tpmentorship/theme/app_theme.dart';
import 'package:tpmentorship/widgets/mentor_card.dart';
import 'package:tpmentorship/widgets/session_card.dart';

class HomeScreen extends StatelessWidget {
  /// The logged-in user's display name, shown in the greeting.
  final String userName;

  /// Called with the mentor whose card was tapped, so the navigator can react
  /// to the specific mentor (currently a popup with their name).
  final ValueChanged<Mentor>? onMentorTap;
  final VoidCallback? onSessionTap;
  final VoidCallback? onViewAllSessions;
  final VoidCallback? onViewAllMessages;
  final VoidCallback? onNavigateToSearch;
  final VoidCallback? onNavigateToMessages;

  const HomeScreen({
    super.key,
    required this.userName,
    this.onMentorTap,
    this.onSessionTap,
    this.onViewAllSessions,
    this.onViewAllMessages,
    this.onNavigateToSearch,
    this.onNavigateToMessages,
  });

  @override
  Widget build(BuildContext context) {
    final mentors = SampleData.getMentors();
    final sessions = SampleData.getUpcomingSessions();
    final messages = SampleData.getMessages();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // TP Logo icon
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
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
                    RichText(
                      text: const TextSpan(
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

          // Greeting - personalised with the logged-in user's display name.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Hello ',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: userName,
                    style: const TextStyle(
                      color: AppTheme.tpRed,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'Connect. Learn. Grow Together',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),

          // Recommended Mentors
          _sectionHeader('Recommended Mentors', 'View all >', onNavigateToSearch),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mentors.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 100,
                    child: MentorCard(
                      mentor: mentors[index],
                      onTap: () => onMentorTap?.call(mentors[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Quick Actions
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

          // Upcoming Sessions
          _sectionHeader('Upcoming Sessions', 'View all >', onViewAllSessions),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: sessions
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SessionCard(session: s, onTap: onSessionTap),
                      ))
                  .toList(),
            ),
          ),

          // Messages
          _sectionHeader('Messages', 'View all >', onNavigateToMessages),
          const SizedBox(height: 8),
          ...messages.take(3).map(
                (message) => GestureDetector(
                  onTap: onNavigateToMessages,
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
                              child: const Icon(Icons.person,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.senderName,
                                style: const TextStyle(
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
                                style: const TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        if (message.unreadCount > 0)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
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

  Widget _sectionHeader(String title, String action, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: const TextStyle(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
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
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}
