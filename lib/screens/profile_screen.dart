import 'package:flutter/material.dart';
import 'package:tpmentorship/data/sample_data.dart';
import 'package:tpmentorship/theme/app_theme.dart';
import 'package:tpmentorship/widgets/session_card.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;

  final VoidCallback? onEditProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  final VoidCallback? onSeeMore;
  final VoidCallback? onBack;

  const ProfileScreen({
    super.key,
    required this.userName,
    this.onEditProfile,
    this.onSettings,
    this.onLogout,
    this.onSeeMore,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final sessions = SampleData.getUpcomingSessions();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: const Icon(Icons.arrow_back_ios,
                      color: AppTheme.textPrimary, size: 20),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCardBg,
              border: Border.all(color: AppTheme.darkBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.tpRed, width: 3),
                            color: AppTheme.darkBg,
                          ),
                          child: const Icon(Icons.person,
                              color: AppTheme.textSecondary, size: 36),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.all(color: AppTheme.darkCardBg, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Diploma in AAI (Year 2)',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          RichText(
                            text: TextSpan(
                              text: 'I like AAI, I am pretty good at Coding, and am excited to connect! ',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: onEditProfile,
                                    child: const Text(
                                      '...Read More',
                                      style: TextStyle(
                                        color: AppTheme.tpRed,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.calendar_today, color: AppTheme.tpRed, size: 16),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Created At:',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary, fontSize: 10)),
                                Text('17 May 2026',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.badge, color: AppTheme.tpRed, size: 16),
                            SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Student ID:',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary, fontSize: 10)),
                                Text('2501587F',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _ProfileActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit Profile',
                        onPressed: onEditProfile,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ProfileActionButton(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onPressed: onSettings,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ProfileActionButton(
                        icon: Icons.logout,
                        label: 'Logout',
                        onPressed: onLogout,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sessions',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: onSeeMore,
                  child: Row(
                    children: const [
                      Icon(Icons.filter_list, color: AppTheme.tpRed, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Filter by: Pending',
                        style: TextStyle(
                          color: AppTheme.tpRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.keyboard_arrow_down,
                          color: AppTheme.tpRed, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: sessions
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SessionCard(session: s),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCardBg,
              border: Border.all(color: AppTheme.darkBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            'TPMentorship',
                            style: TextStyle(
                              color: AppTheme.tpRed,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.workspace_premium, color: Colors.amber, size: 18),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _premiumBullet('Priority When booking sessions as a Student.'),
                      const SizedBox(height: 4),
                      _premiumBullet('Instant Messages without needing to book'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '\$2.99',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      '/mo',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onSeeMore,
                      child: const Text(
                        'See More >',
                        style: TextStyle(
                          color: AppTheme.tpRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkCardBg,
              border: Border.all(color: AppTheme.darkBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'NETS',
                      style: TextStyle(
                        color: Color(0xFF003087),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment via NETS QR Code',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Cancel Anytime in your Settings',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                      Text(
                        'First time Purchase, +3 Months free!',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _premiumBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppTheme.tpRed),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.tpRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
