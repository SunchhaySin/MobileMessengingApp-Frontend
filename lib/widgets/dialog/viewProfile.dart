import 'package:flutter/material.dart';

class Viewprofile {
  final String profileUrl;
  final bool isDarkMode;
  const Viewprofile({required this.profileUrl, required this.isDarkMode});

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircleAvatar(
            radius: 150,
            backgroundColor: isDarkMode ? Colors.white : Colors.black,
            backgroundImage: profileUrl.isNotEmpty
                ? NetworkImage(profileUrl)
                : null,
            child: profileUrl.isEmpty
                ? Text(
                    "profileimg",
                    style: TextStyle(
                      color: isDarkMode ? Colors.black : Colors.white,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
