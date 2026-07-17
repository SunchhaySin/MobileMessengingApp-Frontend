import 'package:flutter/material.dart';
import 'package:frontend/pages/profile/profile.dart';
import 'package:frontend/prompt.dart';
import 'package:frontend/services/socket.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/utils/profileName.dart';
import 'package:provider/provider.dart';
import '../providers/conversation_provider.dart';
import '../providers/friend_provider.dart';
import '../providers/menu_page_provider.dart';
import '../widgets/dialog/logOutDialog.dart';
import '../widgets/menu/ListTile.dart';
import 'profile/dark_mode.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPage();
}

class _MenuPage extends State<MenuPage> { 
  Future<void> logOut() async {
    context.read<FriendProvider>().clear();
    context.read<ConversationProvider>().clear();
    context.read<MenuPageProvider>().clear();
    SocketService().disconnect();
    AuthService.token = null;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<MenuPageProvider>().currentUser;
    final isDarkMode = context.watch<MenuPageProvider>().darkMode;
    final profileName = ProfileName.getInitials(currentUser['username']);
    final profileUrl = context.watch<MenuPageProvider>().profileUrl;

    // Guard: currentUser can become null/empty mid-logout while this
    // page is still animating off screen — bail out safely.
    if (currentUser['username'] == null) {
      return const SizedBox.shrink();
    }
    
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 5),
        child: SizedBox(
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
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  // Icon(Icons.menu, color: isDarkMode ? Colors.white : Colors.black,),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    TileTemplate(
                      title: Text(
                        currentUser['username'],
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: currentUser['email'],
                      subtitleColor: Colors.grey.shade400,
                      trailingWidget: Icon(
                        Icons.arrow_forward_ios,
                        color: isDarkMode ?Colors.white : Colors.black,
                        size: 14,
                      ),
                      leadingWidget: profileUrl != ""
                          ? CircleAvatar(
                              radius: 20,
                              backgroundImage: NetworkImage(profileUrl),
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
                      isDarkMode: isDarkMode,
                      ontap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyProfile(loggedInUser: currentUser, isDarkMode: isDarkMode,),
                        ),
                      )
                    ),
                    SizedBox(height: 10),
                    
                    Divider(color: isDarkMode ? Colors.white30 : Colors.black38),

                    SizedBox(height: 10),
                    TileTemplate(
                      title: Text(
                        "Dark Mode",
                        style: TextStyle(
                          color: isDarkMode ?Colors.white : Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      leadingWidget: Icon(Icons.mode_night_sharp, color: isDarkMode ?Colors.white : Colors.black),
                      trailingWidget: Icon(
                        Icons.arrow_forward_ios,
                        color: isDarkMode ?Colors.white : Colors.black,
                        size: 14,
                      ),
                      isDarkMode: isDarkMode,
                      ontap:() =>  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DarkModePage()),
                      ),
                    ),


                    SizedBox(height:50),

                    // Log out button
                    GestureDetector(
                      onTap: () => LogoutDialog(
                        onConfirm: () async {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Prompt()),
                          );
                          await logOut();
                        },
                      ).openDialog(context),
                      child: Container(
                        width: 350,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
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
                    SizedBox(height: 8),
                    Divider(color: isDarkMode ? Colors.white30 : Colors.black38),

                    // Delete Account 
                    Text(
                      "Deativate Account",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    GestureDetector(
                      onTap: () {
                        if(mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content:  Text("This feature hasn't been implemented due to security reasons.")));
                        }
                      },
                      child: Container(
                        width: 350,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade800,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            "Delete this Account",
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