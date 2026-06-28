import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  final Map<String, dynamic>? loggedInUser;
  const MenuPage({super.key, this.loggedInUser});

  @override
  State<MenuPage> createState() => _MenuPage();
}

class _MenuPage extends State<MenuPage> {
  @override 
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Center(child: Text("Menu Page", style: TextStyle(color: Colors.white)))
            ],),
        ),
        ));
  }
}