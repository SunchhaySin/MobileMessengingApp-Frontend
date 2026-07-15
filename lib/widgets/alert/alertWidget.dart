import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

enum AlertType {
  sendRequest("Send_Request"),
  acceptRequest("Accept_Request"),
  rejectRequest("Reject_Request");

  const AlertType(this.value);

  final String value;
}

class Alertwidget extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final bool isDarkMode;
  final double marginSize;
  final String alertMessage;
  final String profileInitials;
  final String timeStamp;
  final String? profileUrl;

  const Alertwidget({
    super.key,
    required this.loggedInUser,
    required this.isDarkMode,
    required this.alertMessage,
    required this.profileInitials,
    required this.marginSize,
    required this.timeStamp,
    this.profileUrl
  });

  @override
  State<Alertwidget> createState() => _Alertwidget();
}

class _Alertwidget extends State<Alertwidget> {

  
  @override
  Widget build(BuildContext context) {
    final usernamePart = widget.alertMessage.split(",")[0];
    final messagePart = widget.alertMessage.split(",")[1];
    return InkWell(
      // onTap: () => FriendDetailDialog(friendProfile: widget.alertData).openDialog(context),
      child: Container(
        width: double.infinity,
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: widget.marginSize),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                widget.profileUrl != null
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget.profileUrl!),
                      )
                    : Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.lightBlue.shade300,
                        ),
                        child: Center(
                          child: Text(
                            widget.profileInitials,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:2),
                      child: Text(
                        usernamePart,
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      messagePart,
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.white70
                            : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              timeago.format(DateTime.parse(widget.timeStamp)),
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
