import 'package:flutter/material.dart';
import 'package:tpmentorship/data/sample_data.dart';
import 'package:tpmentorship/theme/app_theme.dart';
import 'package:tpmentorship/widgets/mentor_card.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback? onMentorTap;
  final VoidCallback? onBack;

  const SearchScreen({
    super.key,
    this.onMentorTap,
    this.onBack,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final mentors = SampleData.getMentors();

  static const _popularSearches = [
    ('</>', 'DAVA'),
    ('+/-', 'LOMA'),
    ('C++', 'COMT'),
    ('~~', 'ECOMM'),
    ('', 'GSOST'),
  ];

  static const _subjects = [
    ('Development', 'Explore development\nmentors & sessions', Icons.code),
    ('Data', 'Explore data analytics\nmentors & sessions', Icons.bar_chart),
    ('Cybersecurity', 'Explore cybersecurity\nmentors & sessions', Icons.security),
    ('AI & Machine Learning', 'Explore AI/ML\nmentors & sessions', Icons.psychology),
    ('Year 1', 'Explore Year 1\nmentors & sessions', Icons.school),
    ('Year 2', 'Explore Year 2\nmentors & sessions', Icons.school_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final groupA = mentors.take(2).toList();
    final groupB = mentors.skip(2).take(2).toList();

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: const Icon(Icons.arrow_back_ios,
                        color: AppTheme.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Search',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Find Mentors, Topics and Availability slots',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search mentors, specialisations or rating....',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
              fillColor: AppTheme.darkCardBg,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.tpRed, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Popular Searches
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Popular Searches',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _popularSearches
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.tpRed),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag.$1.isEmpty ? tag.$2 : '${tag.$1}  ${tag.$2}',
                                style: const TextStyle(
                                  color: AppTheme.tpRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Browse By Subject
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Browse By Subject',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _subjects.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.0,
                    ),
                    itemBuilder: (context, index) {
                      final s = _subjects[index];
                      return _buildSubjectCard(s.$1, s.$2, s.$3);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Browse By Mentor Ratings
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Browse By Mentor Ratings',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _mentorGroup('TPFUN', groupA),
                const SizedBox(height: 12),
                _mentorGroup('MAIN', groupB),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(String title, String description, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkCardBg,
        border: Border.all(color: AppTheme.darkBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.tpRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.tpRed.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: AppTheme.tpRed, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description.split('\n').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 14),
        ],
      ),
    );
  }

  Widget _mentorGroup(String label, List mentorList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ...mentorList.map((mentor) => SizedBox(
                    width: 110,
                    child: MentorCard(
                      mentor: mentor,
                      onTap: widget.onMentorTap,
                    ),
                  )),
              // "More" card
              SizedBox(
                width: 110,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.darkCardBg,
                    border: Border.all(color: AppTheme.darkBorder),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
