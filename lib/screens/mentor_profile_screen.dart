import 'package:flutter/material.dart';
// built in ui widgets
import 'package:tpmentorship/data/sample_data.dart';
// fake sample data (reviews) used to fill the screen
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling

class MentorProfileScreen extends StatelessWidget {
// the users own mentor profile page 
  final String userName;
  // the mentors name, shown at the top
  final VoidCallback? onBack;
  // run when the back arrow is tapped

  const MentorProfileScreen({super.key, required this.userName, this.onBack});

  @override
  Widget build(BuildContext context) {
    final reviews = SampleData.getReviews();
    // the student reviews listed at the bottom

    return SingleChildScrollView(
    // whole screen scrolls
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // back arrow and title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Icon(Icons.arrow_back_ios,
                      color: AppTheme.textPrimary, size: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  'My Mentor Profile',
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

          // mentor data
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkCardBg,
              border: Border.all(color: AppTheme.darkBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // profile picture 
                Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.tpRed, width: 3),
                        color: AppTheme.darkBg,
                      ),
                      child: Icon(Icons.person,
                          color: AppTheme.textSecondary, size: 40),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 18,
                        height: 18,
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
                // more mentor data
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Coding Mentor',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(86 Reviews)',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          // show how many sessions taught
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.tpRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.tpRed.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              '107 Sessions',
                              style: TextStyle(
                                color: AppTheme.tpRed,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Specialisations',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.tpRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.edit, color: AppTheme.tpRed, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // one box per specialisation
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['C++', 'LDMA', 'DAVA', 'LDAD', 'LDDA']
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.tpRed),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                color: AppTheme.tpRed,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // about me section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Me',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'I like AAI, I am pretty good at coding, and I am excited to connect with others! I enjoy learning new technologies, solving problems through programming, and helping other students understand complex concepts.',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // availability section 
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Availability',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkCardBg,
                    border: Border.all(color: AppTheme.darkBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      // one row per available day, divided by lines
                      _availabilityRow('Monday', '2PM - 6PM'),
                      Divider(color: AppTheme.darkBorder, height: 1),
                      _availabilityRow('Tuesday', '9AM - 12PM'),
                      Divider(color: AppTheme.darkBorder, height: 1),
                      _availabilityRow('Friday', '1PM - 8PM'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // student reviews section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Student Reviews',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'View all',
                      style: TextStyle(
                        color: AppTheme.tpRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // build one review card per review
                ...reviews.map((review) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.darkCardBg,
                        border: Border.all(color: AppTheme.darkBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // reviewer data
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: AppTheme.tpRed, width: 2),
                                  color: AppTheme.darkBg,
                                ),
                                child: Icon(Icons.person,
                                    color: AppTheme.textSecondary, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review['name']!,
                                      style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      review['subject']!,
                                      style: TextStyle(
                                          color: AppTheme.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                review['timeAgo']!,
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // star rating 
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (_) => const Icon(Icons.star,
                                    color: Colors.amber, size: 13),
                                // always shows 5 stars
                              ),
                              const SizedBox(width: 6),
                              Text(
                                review['rating']!,
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // the review text
                          Text(
                            review['review']!,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _availabilityRow(String day, String time) {
  // one line in the availability box showing a day and its time slot
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.access_time, color: AppTheme.tpRed, size: 16),
          const SizedBox(width: 10),
          Text(
            day,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // pushes the time to the far right
          Text(
            time,
            style: TextStyle(
              color: AppTheme.tpRed,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
