import 'package:flutter/material.dart';
import 'package:frontend/pages/add_friend.dart';
import 'package:frontend/pages/friend_requests.dart';
// import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/friend/friendWidget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:provider/provider.dart';

class ContactsPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const ContactsPage({super.key, required this.loggedInUser});

  @override
  State<ContactsPage> createState() => _ContactsPage();
}

class _ContactsPage extends State<ContactsPage> {
  List<dynamic> friendsList = [];

  @override
  void initState() {
    super.initState();
    fetchFriend();
    // Future.microtask(() =>fetchFriend());
  }

  Future fetchFriend() async {
    try {
      // final provider = Provider.of<FriendProvider>(context, listen: false);
      // if (provider.loaded) return;

      final url = Uri.parse('http://10.0.2.2:3000/friend/fetch');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      print(res.body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        setState(() {
          friendsList = data;
        });
        // provider.setFriends(data);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Data not found")));
        }
      }
    } catch (e) {
      print(e);
    } finally {
      print(friendsList);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<FriendProvider>(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: Container(
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
                        color: Colors.white,
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
                              color: Colors.white,
                            ),
                            child: Center(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FriendRequestPage(
                                        loggedInUser: widget.loggedInUser,
                                      ),
                                    ),
                                  );
                                },
                                child: Icon(Icons.people),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddFriendPage(
                                      loggedInUser: widget.loggedInUser,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.person_add_alt_1),
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
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "(${friendsList.length})",
                      style: TextStyle(color: Colors.white70),
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
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            marginSize: 3.0,
                            data: friendsList[index],
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
