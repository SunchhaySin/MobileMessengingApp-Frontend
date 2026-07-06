import 'package:flutter/material.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/utils/profileName.dart';
import 'package:frontend/widgets/alert/alertWidget.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const NotificationPage({super.key, required this.loggedInUser});

  @override
  State<NotificationPage> createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {

    String composeAlertMessage(Map<String, dynamic> alertData) {
    final senderData = alertData['sender'];
    final receiverData = alertData['receiver'];
    final AlertType alertType = AlertType.values.firstWhere(
      (e) => e.value == alertData['type'],
    );

    bool isReceiver = widget.loggedInUser['userID'] == receiverData['id'];
    if (isReceiver) {
      switch (alertType) {
        case AlertType.sendRequest:
          return "${senderData['username']}, sent you a friend request";
        case AlertType.acceptRequest:
          return "${senderData['username']}, accepted your friend request";
        case AlertType.rejectRequest:
          return "${senderData['username']}, rejected your friend request";
      }
    } else {
      return "";
    }
  }

  String getProfileInitials(Map<String, dynamic> alertData) {
    final senderUsername = alertData['sender']['username'];
    return ProfileName.getInitials(senderUsername);
  }
  

  @override 
  Widget build(BuildContext context) {
    final alertsList = context.watch<FriendProvider>().alerts;
    final filteredAlerts = alertsList
    .where((alert) => composeAlertMessage(alert) != "")
    .toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.all(15),
        child: Container(
          width: double.infinity,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Alerts",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Icon(Icons.notifications, color: Colors.white),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: filteredAlerts.isNotEmpty
                    ? ListView.builder(
                        itemCount: filteredAlerts.length,
                        itemBuilder: (context, index) {
                          return 
                          Alertwidget(
                            loggedInUser: widget.loggedInUser,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            marginSize: 3.0,
                            alertMessage: composeAlertMessage(filteredAlerts[index]),
                            profileInitials: getProfileInitials(filteredAlerts[index]),
                            timeStamp: filteredAlerts[index]['createdAt'],
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "You have no Alerts!",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),
            ],),
        ),
        ));
  }
}