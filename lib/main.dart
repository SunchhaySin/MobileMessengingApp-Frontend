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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "AI Messenging App",
      home: Splashscreen(),
    );
  }
}