import 'dart:convert';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/pages/contacts_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/menu_page.dart';
import 'package:frontend/pages/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/conversation_provider.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/services/socket.dart';
import 'package:frontend/services/token.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'providers/menu_page_provider.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

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
    final conversationProvider = context.read<ConversationProvider>();
    SocketService().connect(AuthService.token!);
    friendProvider.setupFriendListeners();
    conversationProvider.setupMessageListeners();

    Future.microtask(() => fetchAlerts()); // Fetches Alerts when the provider is mounted
    Future.microtask(() => fetchRequests()); // Fetches requests when the provider is mounted
    Future.microtask(() => fetchFriend());
    Future.microtask(() => fetchProfile());
  });
    
    pages = [
      Expanded(child: HomePage()),
      Expanded(child: ContactsPage()),
      Expanded(child: NotificationPage()),
      Expanded(child: MenuPage()),
    ];
  }

    Future<void> fetchAlerts() async {
    final provider = Provider.of<FriendProvider>(context, listen: false);
    if (provider.alertsLoaded) return;

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/alert/fetch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      },
    );
    print(res.body);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)['data'];

      // Call the FriendProvider's setAlerts Method to fetch alerts and update the alerts in provider's state
      provider.setAlerts(data);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Data not found")));
      }
    }
  }

  Future fetchRequests() async {
    try {
      final provider = Provider.of<FriendProvider>(context, listen: false);
      if (provider.requestsLoaded) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/friend/fetch/requests');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
          },
      );
      
      print(res.body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        provider.setRequests(data['sentRequests'], data['receivedRequests']);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Data not found")));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future fetchFriend() async {
    try {
      final provider = Provider.of<FriendProvider>(context, listen: false);
      if (provider.friendLoaded) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/friend/fetch');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        provider.setFriends(data); // Call the FriendProvider's setFriends Method to update the friendList in provider's state

      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Data not found")));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchProfile() async {
    try{
      final provider = Provider.of<MenuPageProvider>(context, listen: false);
      final res = await http.get(
       Uri.parse('${ApiConfig.baseUrl}/profile'),
       headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        }, );

      if(res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        if(data != null){
          provider.setContacts(data['contacts'] as String? ?? "");
          provider.setBio(data['bio'] as String? ?? "");
          provider.setProfilePicture(data['profileUrl'] as String? ?? "");
        }
      }
    } catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<MenuPageProvider>().darkMode;
    return Scaffold(
      body: Container(
        color: isDarkMode? Colors.black : Colors.white,
        child: Column(
          children: [
            pages[currentPageIndex],
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 10, right:10),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.blue.shade300
                ),
                padding: EdgeInsets.symmetric(vertical:5),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.45)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isActive 
            ? Border.all(color: Colors.black.withOpacity(0.25), width: 1.2)
            : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.blue.shade500,
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive 
                ? Colors.deepPurple.shade800 
                : Colors.black,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.deepPurple : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
