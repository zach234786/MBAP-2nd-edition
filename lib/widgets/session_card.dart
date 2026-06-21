import 'package:flutter/material.dart';
import 'package:tpmentorship/models/session.dart';
import 'package:tpmentorship/theme/app_theme.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  IconData _sessionIcon() {
    final t = session.title.toLowerCase();
    if (t.contains('web') || t.contains('development')) return Icons.code;
    if (t.contains('data') || t.contains('analytics')) return Icons.bar_chart;
    if (t.contains('security') || t.contains('cyber')) return Icons.security;
    if (t.contains('ai') || t.contains('machine')) return Icons.psychology;
    return Icons.school;
  }

  String _formattedDate() {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${session.date.day} ${months[session.date.month - 1]} ${session.date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.tpRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.tpRed.withValues(alpha: 0.4)),
              ),
              child: Icon(_sessionIcon(), color: AppTheme.tpRed, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      text: 'with ',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      children: [
                        TextSpan(
                          text: session.mentorName,
                          style: const TextStyle(
                            color: AppTheme.tpRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 11, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formattedDate(),
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time, size: 11, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        session.time,
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.tpRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.tpRed.withValues(alpha: 0.5)),
              ),
              child: Text(
                session.status,
                style: const TextStyle(
                  color: AppTheme.tpRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
