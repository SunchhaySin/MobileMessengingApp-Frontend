import 'package:flutter/material.dart';
import '../../utils/profileName.dart';

class ProfileRowWidget extends StatefulWidget {
  final String username;

  const ProfileRowWidget({super.key, required this.username});

  @override
  State<ProfileRowWidget> createState() => _ProfileRowWidget();
}

class _ProfileRowWidget extends State<ProfileRowWidget> {
  @override
  Widget build(BuildContext context) {
    final profileName = ProfileName.getInitials(widget.username);
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.blue, width: 1),
        color: Colors.lightBlue.shade300,
      ),
      margin: EdgeInsets.symmetric(horizontal: 3),
      child: Center(child: Text(profileName, style: TextStyle(fontSize: 18))),
    );
  }
}
