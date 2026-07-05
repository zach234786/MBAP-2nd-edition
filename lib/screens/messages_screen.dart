import 'package:flutter/material.dart';
// built in ui widgets
import 'package:tpmentorship/data/sample_data.dart';
// fake sample data used to fill the screen
import 'package:tpmentorship/theme/app_theme.dart';
// app colours and styling
import 'package:tpmentorship/utils/snackbar_helper.dart';
// helper to show popup messages
import 'package:tpmentorship/widgets/message_tile.dart';
// the message row widget

class MessagesScreen extends StatefulWidget {
// screen showing the list of chats
  final VoidCallback? onBack;
  // run when the back arrow is tapped

  const MessagesScreen({super.key, this.onBack});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  // grabs whatever the user types into the search box
  final messages = SampleData.getMessages();
  // the list of chats to show
  final mentors = SampleData.getMentors();
  // the mentors shown in the row of circles at the top

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
                    child: const Icon(Icons.arrow_back_ios,
                        color: AppTheme.textPrimary, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Messages',
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
                'Chat with your mentors, students and ask questions!',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // search box 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search for Mentors/students to connect with....',
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

        // row of mentor circles at the top 
        SizedBox(
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: mentors.map((mentor) {
              // build one avatar per mentor
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // profile picture 
                  Stack(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.tpRed, width: 2),
                          color: AppTheme.darkBg,
                        ),
                        child: const Icon(Icons.person,
                            color: AppTheme.textSecondary, size: 28),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mentor.isOnline ? Colors.green : Colors.grey,
                            // green if online, grey if offline
                            border: Border.all(color: AppTheme.darkBg, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // first name under the avatar
                  SizedBox(
                    width: 58,
                    child: Text(
                      mentor.name.split(' ').first,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),

        // msgs section label
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Messages',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        // the scrollable list of chats
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            padding: const EdgeInsets.only(bottom: 16),
            itemBuilder: (context, index) {
              // build one message row per chat
              return MessageTile(
                message: messages[index],
                onTap: () => showAppSnackBar(
                    context, 'Opening chat with ${messages[index].senderName}'),
                    // just shows a popup since chat screens arent built yet
              );
            },
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
