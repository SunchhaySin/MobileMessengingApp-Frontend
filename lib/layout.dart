import 'package:frontend/pages/contacts_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/menu_page.dart';
import 'package:frontend/pages/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/services/socket.dart';
import 'package:frontend/services/token.dart';
import 'package:provider/provider.dart';

class Layout extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const Layout({super.key, required this.loggedInUser});

  @override
  State<Layout> createState() => _Layout();
}

class _Layout extends State<Layout> {
  int currentPageIndex = 0;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    final friendProvider = context.read<FriendProvider>();
    SocketService().connect(AuthService.token!, friendProvider);
  });
    
    pages = [
      Expanded(child: HomePage(loggedInUser: widget.loggedInUser)),
      Expanded(child: ContactsPage(loggedInUser: widget.loggedInUser)),
      Expanded(child: NotificationPage()),
      Expanded(child: MenuPage()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // width: double.infinity,
        // height: double.infinity,
        color: Colors.black87,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     colors: [Colors.lightBlue.shade200, Colors.lightBlueAccent],
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //   ),
        // ),
        child: Column(
          children: [
            pages[currentPageIndex],
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 10, right:10),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.chat_bubble,
                      label: "Chats",
                      isActive: currentPageIndex == 0,
                      onTap: () {
                        setState(() {
                          currentPageIndex = 0;
                        });
                      },
                    ),
                    _NavItem(
                      icon: Icons.account_circle,
                      label: "Contacts",
                      isActive: currentPageIndex == 1,
                      onTap: () {
                        setState(() {
                          currentPageIndex = 1;
                        });
                      },
                    ),
                    _NavItem(
                      icon: Icons.notifications,
                      label: "Alerts",
                      isActive: currentPageIndex == 2,
                      onTap: () {
                        setState(() {
                          currentPageIndex = 2;
                        });
                      },
                    ),
                    _NavItem(
                      icon: Icons.menu,
                      label: "Menu",
                      isActive: currentPageIndex == 3,
                      onTap: () {
                        setState(() {
                          currentPageIndex = 3;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: isActive ? Colors.blue : Colors.white),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
