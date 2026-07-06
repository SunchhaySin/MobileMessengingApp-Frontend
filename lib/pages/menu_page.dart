import 'package:flutter/material.dart';
import 'package:frontend/prompt.dart';
import 'package:frontend/services/socket.dart';
import 'package:frontend/services/token.dart';
import 'package:provider/provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/friend_provider.dart';

class MenuPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const MenuPage({super.key, required this.loggedInUser});

  @override
  State<MenuPage> createState() => _MenuPage();
}

class _MenuPage extends State<MenuPage> {
  void logOut() {
    context.read<FriendProvider>().clear();
    context.read<ConversationProvider>().clear();
    SocketService().disconnect();
    AuthService.token = null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Icon(Icons.menu, color: Colors.white),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    // Log out button
                    GestureDetector(
                      onTap: () {
                        logOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Prompt()),
                        );
                      },
                      child: Container(
                        width: 350,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            "Log out",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
