import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/pages/conversation.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/dialog/friendDetail.dart';
import 'package:provider/provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/friend_provider.dart';
import '../../utils/profileName.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../dialog/unFriendDialog.dart';

class Friendwidget extends StatefulWidget {
  final bool isDarkMode;
  final double marginSize;
  final Map<String, dynamic> data;
  final Map<String, dynamic> loggedInUser;

  const Friendwidget({
    super.key,
    required this.isDarkMode,
    required this.data,
    required this.marginSize,
    required this.loggedInUser,
  });

  @override
  State<Friendwidget> createState() => _Friendwidget();
}

class _Friendwidget extends State<Friendwidget> {
  final ValueNotifier<bool> isLoadingOnChat = ValueNotifier(false);

  Future<void> openChat(BuildContext dialogContext, String userId, String profileInitials, String? profileUrl) async {
    isLoadingOnChat.value = true;
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/conversation/open'),
        body: jsonEncode({"friendId": userId}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      final data = jsonDecode(res.body)['data'];

      if(!mounted) return;
      context.read<ConversationProvider>().addConversation(data);

      Navigator.of(dialogContext).pop(); // Closes the dialog

      Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
        conversationData: data,
        loggedInUser: widget.loggedInUser,
        friendName: widget.data['username'],
        isDarkMode: widget.isDarkMode,
        profileInitials: profileInitials,
        profileUrl: profileUrl,
      )));
    } catch (e) {
      print(e);
    } finally {
      isLoadingOnChat.value = false;
    }
  }

  Future<void> unFriend(String userId) async {
    try {
      final friendProvider = context.read<FriendProvider>();
      final conversationProvider = context.read<ConversationProvider>();

      final message = await friendProvider.removeFriend(userId);
      conversationProvider.archiveConversationByUserId(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileName = ProfileName.getInitials(widget.data['username']);
    final profileImage = widget.data['profile']?['profileUrl'];

    return InkWell(
      onTap: () => FriendDetailDialog(
        friendProfile: widget.data,
        onChat: openChat,
        onUnfriend: (friendId) => UnFriendDialog(
          friendId: friendId,
          friendUsername: widget.data['username'],
          onConfirm: unFriend,
        ).openDialog(context),
        isDarkMode: widget.isDarkMode,
        isLoadingOnChat: isLoadingOnChat,
      ).openDialog(context),
      child: Container(
        width: double.infinity,
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: widget.marginSize),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                profileImage != null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(profileImage),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.data['username'],
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.data['email'],
                      style: TextStyle(color: widget.isDarkMode? Colors.white70 : Colors.black87,),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              height: 25,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.lightBlueAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Friend",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  Icon(Icons.people, color: Colors.black, size:16)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
