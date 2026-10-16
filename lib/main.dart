import 'package:flutter/material.dart';
import 'package:frontend/providers/conversation_provider.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/providers/menu_page_provider.dart';
import 'package:frontend/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FriendProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => MenuPageProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    bool isLargeScreen =
        MediaQuery.sizeOf(context).width > 460; 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AI Messenging App",
      builder: (context, child) {

        // Constrain the width and height of the app when opened on bigger screens (web)
        if(isLargeScreen) {
          return MobileFrameWrapper(child: child ?? const SizedBox());
        }
        return child ?? const SizedBox();
      },
      home: Splashscreen(),
    );
  }
}

class MobileFrameWrapper extends StatelessWidget {
  final Widget child;
  const MobileFrameWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), 
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400, 
            maxHeight: 850, 
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade800, width: 4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: child, 
          ),
        ),
      ),
    );
  }
}