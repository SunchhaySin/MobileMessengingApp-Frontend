import 'package:flutter/material.dart';
import 'package:frontend/pages/add_friend.dart';
import 'package:frontend/pages/friend_requests.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/widgets/friend/friendWidget.dart';
import 'package:provider/provider.dart';
import '../providers/menu_page_provider.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPage();
}

class _ContactsPage extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    final friendsList = context
        .watch<FriendProvider>()
        .friends; // listens for changes in friendlist and updates the UI accordingly
    final currentUser = context.watch<MenuPageProvider>().currentUser;
    final isDarkMode = context.watch<MenuPageProvider>().darkMode;

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Contacts",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    SizedBox(
                      child: Row(
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey.shade300,
                            ),
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FriendRequestPage(
                                        loggedInUser: currentUser,
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(Icons.people, color: isDarkMode ? Colors.black87 : Colors.black54),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.grey.shade300,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddFriendPage(
                                      loggedInUser: currentUser,
                                      isDarkMode: isDarkMode,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.person_add_alt_1, color: isDarkMode ? Colors.black87 : Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Text(
                      "Your Friends",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "(${friendsList.length})",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Expanded(
                child: friendsList.isNotEmpty
                    ? ListView.builder(
                        itemCount: friendsList.length,
                        itemBuilder: (context, index) {
                          return Friendwidget(
                            isDarkMode: isDarkMode,
                            marginSize: 3.0,
                            data: friendsList[index],
                            loggedInUser: currentUser,
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "You have no friends. Reach out by sending friend requests",
                          style: TextStyle(color: Colors.white),
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
