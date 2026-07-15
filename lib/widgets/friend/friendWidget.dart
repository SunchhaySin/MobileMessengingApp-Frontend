import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/pages/conversation.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/dialog/friendDetail.dart';
import '../../utils/profileName.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  Future<void> openChat(String userId) async {
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
      print(data);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
        conversationData: data,
        loggedInUser: widget.loggedInUser,
        friendName: widget.data['username'],
        isDarkMode: widget.isDarkMode,
      )));
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
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 25,
                width: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.lightBlueAccent,
                ),
                child: Center(
                  child: Text(
                    "View",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
