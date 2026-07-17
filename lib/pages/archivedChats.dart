import 'package:flutter/material.dart';
import 'package:frontend/pages/conversation.dart';
import 'package:frontend/providers/conversation_provider.dart';
import 'package:provider/provider.dart';

import '../widgets/home/conversationWidget.dart';

class ArchivedchatsPage extends StatefulWidget {
  final bool isDarkMode;
  final Map<String, dynamic> loggedInUser;
  const ArchivedchatsPage({
    super.key,
    required this.isDarkMode,
    required this.loggedInUser,
  });

  @override
  State<ArchivedchatsPage> createState() => _ArchivedchatsPage();
}

class _ArchivedchatsPage extends State<ArchivedchatsPage> {
  @override
  Widget build(BuildContext context) {
    final archivedCoversationList = context.watch<ConversationProvider>().archivedConversations;

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: widget.isDarkMode ? Colors.black : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Archived Chats",
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: archivedCoversationList.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 25,
                        ),
                        child: ListView.builder(
                          itemCount: archivedCoversationList.length,
                          itemBuilder: (context, index) {
                            final archivedChat = archivedCoversationList[index];
                            final otherUser =
                                archivedChat['user1']['id'] ==
                                    widget.loggedInUser['userID']
                                ? archivedChat['user2']
                                : archivedChat['user1'];

                            final lastMessage =
                                archivedChat['messages']?.isNotEmpty == true
                                ? archivedChat['messages'][0]
                                : null;

                            return ConversationWidget(
                              loggedInUser: widget.loggedInUser, // note: this widget isn't passed into ArchivedchatsPage currently
                              username: otherUser['username'],
                              hasConversation: true, // All archives chats has a conversation, different of emtpy chats
                              isDarkMode: widget.isDarkMode,
                              marginSize: 2.0,
                              previewMessage: lastMessage,
                              onTap: (profileInitials) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ConversationPage(
                                      conversationData: archivedChat,
                                      loggedInUser: widget.loggedInUser,
                                      friendName: otherUser['username'],
                                      isDarkMode: widget.isDarkMode,
                                      profileInitials: profileInitials,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          "No Archived Coversation",
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
