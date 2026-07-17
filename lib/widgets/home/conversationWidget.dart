import 'package:flutter/material.dart';
import '../../utils/profileName.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationWidget extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final String username;
  final Map<String,dynamic>? previewMessage; // Last Message or New Chat (if Coversation has no messages)
  final String? timestamp;
  final void Function(String profileInitials)? onTap;
  final bool hasConversation;

  final double? marginSize;
  final bool isDarkMode;
  final String? profileUrl;

  const ConversationWidget({
    super.key,
    required this.loggedInUser,
    required this.username,
    this.previewMessage,
    this.timestamp,
    this.onTap,
    required this.hasConversation,

    this.marginSize,
    required this.isDarkMode,
    this.profileUrl,
  });

  @override
  State<ConversationWidget> createState() => _ConversationWidgetState();
}

class _ConversationWidgetState extends State<ConversationWidget> {
  @override
  Widget build(BuildContext context) {
    final profileName = ProfileName.getInitials(widget.username);
    final lastMessage = widget.previewMessage?['content'];
    final createdAt = widget.previewMessage?['sentAt'];
    final senderId = widget.previewMessage?['senderId'];
    final newChat = lastMessage == null && widget.hasConversation;

    return InkWell(
      onTap: () => widget.onTap?.call(profileName),
      child: Container(
        width: double.infinity,
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: widget.marginSize!),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300 ,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  widget.profileUrl != null
                      ? CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(widget.profileUrl!),
                        )
                      : Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.lightBlue.shade300,
                          ),
                          child: Center(
                            child: Text(
                              profileName,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.username,
                          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                        ),
                        Text(
                          newChat
                            ? "Chat Empty"
                            : widget.hasConversation 
                              ? senderId == widget.loggedInUser['userID'] 
                                ? "You: $lastMessage"
                                : lastMessage
                              : "Tap to start a converstion",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(color: widget.isDarkMode? Colors.white70 : Colors.black87, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            widget.hasConversation
                ? newChat
                  ? SizedBox.shrink()
                  : Text(
                    timeago.format(DateTime.parse(createdAt)),
                    style: TextStyle(color: widget.isDarkMode? Colors.white70 : Colors.black87, fontSize: 11),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, color: widget.isDarkMode?Colors.white : Colors.black, size: 14),
                      Text(
                        "New Friend",
                        style: TextStyle(color: widget.isDarkMode? Colors.white : Colors.black, fontSize: 12),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
