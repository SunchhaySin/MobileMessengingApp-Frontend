import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/pages/conversation.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/home/conversationWidget.dart';
import 'package:frontend/widgets/home/profileRow.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/friend_provider.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const HomePage({super.key, required this.loggedInUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final List<dynamic> existingCoversations;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => fetchConvo());
  }

  Future<void> openChat(String userId, String userName) async {
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

      Navigator.push(context, MaterialPageRoute(builder: (context) => ConversationPage(
        conversationData: data,
        loggedInUser: widget.loggedInUser,
        friendName: userName,
      )));
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchConvo() async{
    try{
      final provider = Provider.of<ConversationProvider>(context, listen: false);
      if(provider.conversationsLoaded) return;

      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/conversation/fetch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },);

      if(res.statusCode == 200){
        final data = jsonDecode(res.body)['data'];
        provider.setConversations(data);

      }
    } catch(e){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendsList = context.watch<FriendProvider>().friends;
    final conversationsList = context.watch<ConversationProvider>().conversations;

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child: Column(
          children: [
            // ================= HEADER =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "CURL",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.settings, color: Colors.white),
              ],
            ),

            // ================= SEARCH =================
            Container(
              width: double.infinity,
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 3),
              margin: EdgeInsets.symmetric(vertical: 10),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "Ask AI or Search Messages",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                  prefixIcon: Icon(Icons.search, size: 22, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ================= HORIZONTAL LIST =================
            Padding(
              padding: const EdgeInsets.only(left: 1),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Activity",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            friendsList.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friendsList.length,
                        itemBuilder: (context, index) {
                          final friend = friendsList[index];
                          return ProfileRowWidget(username: friend['username']);
                        },
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      "No friend activities",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

            Divider(color: Colors.white12, thickness: 1),
            // ================= MAIN CONTENT =================
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Chats",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            friendsList.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: friendsList.length,
                      itemBuilder: (context, index) {
                        final friend = friendsList[index];
                        final myId = widget.loggedInUser['userID'];
                        final conversationIndex = conversationsList.indexWhere(
                          (c) =>
                              (c['user1Id'] == myId &&
                                  c['user2Id'] == friend['id']) ||
                              (c['user1Id'] == friend['id'] &&
                                  c['user2Id'] == myId),
                        );
                        final hasConversation = conversationIndex != -1;

                        Map<String,dynamic>? lastMessage;
                        if (conversationIndex != -1) {
                          final conversation = conversationsList[conversationIndex];

                          if (conversation['messages'].isNotEmpty) {
                            lastMessage = conversation['messages'][0];
                            print(lastMessage);
                          } else {
                            lastMessage = null;
                          }
                        }

                        return ConversationWidget(
                          loggedInUser: widget.loggedInUser,
                          username: friend['username'],
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          marginSize: 2.0,
                          hasConversation: hasConversation,
                          previewMessage: lastMessage,
                          onTap: () {
                            if (hasConversation) {
                              final conversation =
                                  conversationsList[conversationIndex];

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConversationPage(
                                    conversationData: conversation,
                                    loggedInUser: widget.loggedInUser,
                                    friendName: friend['username'],
                                  ),
                                ),
                              );
                            } else {
                              openChat(friend['id'], friend['username']);
                            }
                          },
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      "You have no conversations",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
