import 'package:flutter/material.dart';
// built in ui widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/models/mentor.dart';
// the mentor data type
import 'package:tpmentorship/providers/data_providers.dart';
// live firestore providers
import 'package:tpmentorship/screens/mentor_list_screen.dart';
// the filtered results screen
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/widgets/mentor_card.dart';
// the small mentor card widget

class SearchScreen extends ConsumerStatefulWidget {
// screen for browsing and finding mentors - all data is live from
// firestore and the sections demonstrate the advanced queries:
//   popular search chips -> filter by subject (arrayContains)
//   browse by subject    -> filter by specialization (equality)
//   ratings groups       -> two filters on the same field (range)
//   everything           -> sorted by rating (orderBy)
  final ValueChanged<Mentor>? onMentorTap;
  // run when a mentor is tapped
  final VoidCallback? onBack;
  // run when the back arrow is tapped

  const SearchScreen({
    super.key,
    this.onMentorTap,
    this.onBack,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // grabs whatever the user types into the search box
  String _query = '';
  // the current search text, updates as the user types

  // preset tags shown under "popular searches" - each is a subject code
  // tapping one runs the filter-by-subject firestore query
  static const _popularSearches = [
    ('</>', 'DAVA'),
    ('+/-', 'LOMA'),
    ('C++', 'COMT'),
    ('~~', 'ECOMM'),
    ('', 'GSOST'),
  ];

  // preset areas shown in the "browse by subject" grid
  // tapping one runs the filter-by-specialization firestore query
  static const _specializations = [
    ('Development', 'Explore development\nmentors & sessions', Icons.code),
    ('Data', 'Explore data analytics\nmentors & sessions', Icons.bar_chart),
    ('Cybersecurity', 'Explore cybersecurity\nmentors & sessions', Icons.security),
    ('AI & Machine Learning', 'Explore AI/ML\nmentors & sessions', Icons.psychology),
  ];

  // opens the results screen for one subject code
  void _openSubject(String subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MentorListScreen(title: '$subject Mentors', subject: subject),
      ),
    );
  }

  // opens the results screen for one specialization area
  void _openSpecialization(String specialization) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentorListScreen(
            title: specialization, specialization: specialization),
      ),
    );
  }

  // opens the results screen for a rating range
  void _openRatingRange(String title, double min, double max) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentorListScreen(
            title: title, minRating: min, maxRating: max),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // back arrow, title and subtitle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: widget.onBack,
                    child: Icon(Icons.arrow_back_ios,
                        color: AppTheme.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
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
              Text(
                'Find Mentors, Topics and Availability slots',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // search box - filters the mentor list live as the user types
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value.trim()),
            // rebuild with the new search text on every keystroke
            style: TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search mentors, specialisations or rating....',
              hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 20),
              // an x button to clear the search quickly
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(Icons.close,
                          color: AppTheme.textSecondary, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              fillColor: AppTheme.darkCardBg,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.darkBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.tpRed, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // rest of the page scrolls
        Expanded(
          child: _query.isNotEmpty
              // typing something? show matching mentors instead of browse
              ? _buildSearchResults()
              : _buildBrowseSections(),
        ),
      ],
    );
  }

  // live search results - filters the all-mentors stream by the text
  Widget _buildSearchResults() {
    final mentorsAsync = ref.watch(mentorsProvider);
    return mentorsAsync.when(
      data: (mentors) {
        final lower = _query.toLowerCase();
        // keep mentors whose name, specialization or subject matches
        final results = mentors.where((m) {
          return m.name.toLowerCase().contains(lower) ||
              m.specialization.toLowerCase().contains(lower) ||
              m.subjects.any((s) => s.toLowerCase().contains(lower));
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Text(
              'No mentors match "$_query"',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            return MentorCard(
              mentor: results[index],
              onTap: () => widget.onMentorTap?.call(results[index]),
            );
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: AppTheme.tpRed)),
      error: (e, _) => Center(
        child: Text('Could not load mentors',
            style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }

  // the browse sections shown when the search box is empty
  Widget _buildBrowseSections() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // popular searches section - subject filter queries
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  .map((tag) => GestureDetector(
                        onTap: () => _openSubject(tag.$2),
                        // runs the filter-by-subject query
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.tpRed),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tag.$1.isEmpty ? tag.$2 : '${tag.$1}  ${tag.$2}',
                            // show just the label if theres no symbol
                            style: TextStyle(
                              color: AppTheme.tpRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // browse by subject section - specialization filter queries
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
              // let the outer scroll view handle scrolling
              itemCount: _specializations.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                // two cards per row
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.0,
              ),
              itemBuilder: (context, index) {
                // build one card per specialization
                final s = _specializations[index];
                return _buildSubjectCard(s.$1, s.$2, s.$3);
              },
            ),
          ),
          const SizedBox(height: 24),

          // browse by mentor ratings section - rating range queries
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          _ratingGroup('4.5 STARS & ABOVE', 4.5, 5.01),
          const SizedBox(height: 12),
          _ratingGroup('4.0 TO 4.5 STARS', 4.0, 4.5),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(String title, String description, IconData icon) {
  // builds one card in the browse by subject grid
    return GestureDetector(
      onTap: () => _openSpecialization(title),
      // runs the filter-by-specialization query
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkCardBg,
          border: Border.all(color: AppTheme.darkBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            // subject icon
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
            // title and short desc
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description.split('\n').first,
                    // only show the first line of the desc
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _ratingGroup(String label, double min, double max) {
  // builds a row of mentor cards for one rating range, live from the
  // range query (two filter conditions on the same "rating" field)
    final mentorsAsync =
        ref.watch(mentorsByRatingProvider((min: min, max: max)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // group label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            label,
            style: TextStyle(
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
          child: mentorsAsync.when(
            data: (mentorList) {
              if (mentorList.isEmpty) {
                return Center(
                  child: Text(
                    'No mentors in this range yet',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }
              // first two mentors plus a "..." card that opens the rest
              final preview = mentorList.take(2).toList();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // one card per mentor in this group
                  ...preview.map((mentor) => SizedBox(
                        width: 110,
                        child: MentorCard(
                          mentor: mentor,
                          onTap: () => widget.onMentorTap?.call(mentor),
                        ),
                      )),
                  SizedBox(
                    width: 110,
                    child: GestureDetector(
                      onTap: () => _openRatingRange(label, min, max),
                      // opens the full results for this rating range
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.darkCardBg,
                          border: Border.all(color: AppTheme.darkBorder),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
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
                  ),
                ],
              );
            },
            loading: () => Center(
                child: CircularProgressIndicator(color: AppTheme.tpRed)),
            error: (e, _) => Center(
              child: Text('Could not load mentors',
                  style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
  // runs when the screen is closed for good
    _searchController.dispose();
    // free the controllers memory to avoid leaks
    super.dispose();
  }
}
