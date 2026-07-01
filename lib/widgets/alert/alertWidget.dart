import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../utils/profileName.dart';

class Alertwidget extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final Color backgroundColor;
  final Color textColor;
  final double marginSize;
  final Map<String, dynamic> alertData;

  const Alertwidget({
    super.key,
    required this.loggedInUser,
    required this.backgroundColor,
    required this.textColor,
    required this.alertData,
    required this.marginSize,
  });

  @override
  State<Alertwidget> createState() => _Alertwidget();
}

class _Alertwidget extends State<Alertwidget> {
  String composeAlertMessage(Map<String, dynamic> alertData) {
    final sender = alertData['sender'];
    final receiver = alertData['receiver'];

    // final List<String> alertContent = alertData['message'].split("");

    if (widget.loggedInUser['userID'] == sender['id']) {
      return "You sent a friend request to ${receiver['username']}";
    } else if (widget.loggedInUser['userID'] == receiver['id']) {
      return "${sender['username']} sent you a friend request";
    } else {
      return "Unknown alert";
    }
  }

  String getProfileInitials(Map<String, dynamic> alertData) {
    final sender = alertData['sender'];
    final receiver = alertData['receiver'];

    if (widget.loggedInUser['userID'] == sender['id']) {
      return ProfileName.getInitials(receiver['username']);
    } else if (widget.loggedInUser['userID'] == receiver['id']) {
      return ProfileName.getInitials(sender['username']);
    } else {
      return "??";
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => FriendDetailDialog(friendProfile: widget.alertData).openDialog(context),
      child: Container(
        width: double.infinity,
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: widget.marginSize),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blueGrey,
                  ),
                  child: Center(
                    child: Text(
                      getProfileInitials(widget.alertData),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  composeAlertMessage(widget.alertData),
                  style: TextStyle(color: widget.textColor),
                ),
              ],
            ),
            Text(
              timeago.format(DateTime.parse(widget.alertData['createdAt'])),
              style: TextStyle(color: widget.textColor),
            ),
          ],
        ),
      ),
    );
  }
}
