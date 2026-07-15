import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/apiConfig.dart';
import '../../services/token.dart';

class ProfileHistory extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final bool isDarkMode;
  const ProfileHistory({
    super.key,
    required this.loggedInUser,
    required this.isDarkMode,
  });

  @override
  State<ProfileHistory> createState() => _ProfileHistoryState();
}

class _ProfileHistoryState extends State<ProfileHistory> {
  Future<void> fetchHisotry() async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if(res.statusCode == 200){
        final data = jsonDecode(res.body);
        print(data);
      } 
    } catch (e) {
      print(e);
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: widget.isDarkMode ? Colors.black : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Profile History",
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
