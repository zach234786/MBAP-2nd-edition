import 'package:flutter/material.dart';
// built in ui widgets
import 'package:flutter_riverpod/flutter_riverpod.dart';
// riverpod state management
import 'package:tpmentorship/providers/data_providers.dart';
// the app's firestore providers
import 'package:tpmentorship/screens/book_session_screen.dart';
// the booking form
import 'package:tpmentorship/screens/session_detail_screen.dart';
// the single session view
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/widgets/session_card.dart';
// the session card widget

class MySessionsScreen extends ConsumerStatefulWidget {
// the READ (select all) part of CRUD - lists every session the logged in
// student has booked, live from Firestore
// also demonstrates the advanced query "multiple filters on different
// fields" through the status filter chips at the top

  const MySessionsScreen({super.key});

  @override
  ConsumerState<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends ConsumerState<MySessionsScreen> {
  String _statusFilter = 'All';
  // which filter chip is selected

  // the choices shown as filter chips
  static const _statuses = ['All', 'Pending', 'Confirmed', 'Completed'];

  @override
  Widget build(BuildContext context) {
    // 'All' uses the plain select-all query,
    // anything else uses the two-field filter query (studentId + status)
    final sessionsAsync = _statusFilter == 'All'
        ? ref.watch(mySessionsProvider)
        : ref.watch(mySessionsByStatusProvider(_statusFilter));

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: const Text('My Sessions')),
      // button to book a brand new session
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.tpRed,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BookSessionScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ----- status filter chips -----
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _statuses.map((status) {
                  final selected = _statusFilter == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: selected,
                      onSelected: (_) =>
                          setState(() => _statusFilter = status),
                      // red when picked, dark otherwise
                      selectedColor: AppTheme.tpRed,
                      backgroundColor: AppTheme.darkCardBg,
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                          color: selected
                              ? AppTheme.tpRed
                              : AppTheme.darkBorder),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ----- the sessions list -----
            Expanded(
              child: sessionsAsync.when(
                // the stream gives us loading / error / data states
                data: (sessions) {
                  if (sessions.isEmpty) {
                    // friendly empty state instead of a blank screen
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              color: AppTheme.textSecondary, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            _statusFilter == 'All'
                                ? 'No sessions booked yet'
                                : 'No $_statusFilter sessions',
                            style: TextStyle(
                                color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap + to book your first session',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SessionCard(
                          session: session,
                          onTap: () {
                            // open the single session view (select one)
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SessionDetailScreen(
                                    sessionId: session.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.tpRed)),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Could not load sessions.\n$e',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
