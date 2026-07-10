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
import '../providers/menu_page_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    final currentUser = context.read<MenuPageProvider>().currentUser;
    final isDarkMode = context.read<MenuPageProvider>().darkMode;
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
        loggedInUser: currentUser,
        friendName: userName,
        isDarkMode: isDarkMode,
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

  // Structures the widgetList to display coversation chats (ordered by newest message)
  List<Map<String, dynamic>> buildDisplayList(
    List<dynamic> friendsList,
    List<dynamic> conversationsList,
    String myId,
  ) {
    final List<Map<String, dynamic>> displayList = [];

    for (final friend in friendsList) {
      final conversationIndex = conversationsList.indexWhere(
        (c) =>
            (c['user1Id'] == myId && c['user2Id'] == friend['id']) ||
            (c['user1Id'] == friend['id'] && c['user2Id'] == myId),
      );

      if (conversationIndex != -1) {
        displayList.add({
          "friend": friend,
          "conversation": conversationsList[conversationIndex],
        });
      } else {
        displayList.add({"friend": friend, "conversation": null});
      }
    }

    displayList.sort((a, b) {
      final convoA = a["conversation"];
      final convoB = b["conversation"];

      // Friends with no conversation go to the bottom
      if (convoA == null && convoB == null) return 0;
      if (convoA == null) return 1;
      if (convoB == null) return -1;

      // Get the newest message timestamp
      final messagesA = (convoA["messages"] as List?) ?? [];
      final messagesB = (convoB["messages"] as List?) ?? [];

      if (messagesA.isEmpty && messagesB.isEmpty) return 0;
      if (messagesA.isEmpty) return 1;
      if (messagesB.isEmpty) return -1;

      final dateA = DateTime.parse(messagesA.first["sentAt"]);
      final dateB = DateTime.parse(messagesB.first["sentAt"]);

      return dateB.compareTo(dateA); // Newest first
    });

    return displayList;
  }

  @override
  Widget build(BuildContext context) {
    final friendsList = context.watch<FriendProvider>().friends;
    final conversationsList = context.watch<ConversationProvider>().conversations;
    final currentUser = context.watch<MenuPageProvider>().currentUser;
    final isDarkMode = context.watch<MenuPageProvider>().darkMode;
    final displayList = buildDisplayList(
      friendsList,
      conversationsList,
      currentUser['userID'],
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
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
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Icon(Icons.settings, color: isDarkMode ? Colors.white : Colors.black,),
              ],
            ),

            // ================= SEARCH =================
            Container(
              width: double.infinity,
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 3),
              margin: EdgeInsets.symmetric(vertical: 15),
              child: TextFormField(
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: "Ask AI or Search Messages",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 22,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.black : Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
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
                    color: isDarkMode ?Colors.white70 :Colors.black87,
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

            Divider(color: isDarkMode ? Colors.white30 : Colors.black38, thickness: 1),
            // ================= MAIN CONTENT =================
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "Chats",
                  style: TextStyle(
                    color: isDarkMode ?Colors.white70 :Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            friendsList.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        final friend = item["friend"];
                        final conversation = item["conversation"];
                        final hasConversation = conversation != null;

                        Map<String, dynamic>? lastMessage;
                        if (hasConversation) {
                          final messages = conversation["messages"] as List<dynamic>?;
                          if (messages != null && messages.isNotEmpty) {
                            lastMessage = messages.first;
                          }
                        }

                        return ConversationWidget(
                          loggedInUser: currentUser,
                          username: friend['username'],
                          marginSize: 2.0,
                          hasConversation: hasConversation,
                          previewMessage: lastMessage,
                          isDarkMode: isDarkMode,
                          onTap: () {
                            if (hasConversation) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ConversationPage(
                                    conversationData: conversation,
                                    loggedInUser: currentUser,
                                    friendName: friend['username'],
                                    isDarkMode: isDarkMode,
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
