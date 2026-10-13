import 'package:flutter/material.dart';

class Viewprofile {
  final String profileUrl;
  final bool isDarkMode;

  const Viewprofile({
    required this.profileUrl,
    required this.isDarkMode,
  });

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: profileUrl != ""
              ? CircleAvatar(
                  radius: 150,
                  backgroundImage: NetworkImage(profileUrl),
                )
              : CircleAvatar(
                  radius: 150,
                  child: Center(child: Text("No profile picture")),
                ),
        );
      },
    );
  }
}
