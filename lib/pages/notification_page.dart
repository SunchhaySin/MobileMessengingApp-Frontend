import 'package:flutter/material.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/alert/alertWidget.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const NotificationPage({super.key, required this.loggedInUser});

  @override
  State<NotificationPage> createState() => _NotificationPage();
}

class _NotificationPage extends State<NotificationPage> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => fetchAlerts()); 
  }

  Future<void> fetchAlerts() async {
    final provider = Provider.of<FriendProvider>(context, listen: false);
      if (provider.alertsLoaded) return;

      final res = await http.get(
        Uri.parse('http://10.0.2.2:3000/alert/fetch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );
      print(res.body);
            if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];

        // Call the FriendProvider's setAlerts Method to fetch alerts and update the alerts in provider's state
        provider.setAlerts(data);  
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Data not found")));
        }
      }
  
  }

  @override 
  Widget build(BuildContext context) {
    final alertsList = context.watch<FriendProvider>().alerts;
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
                child: alertsList.isNotEmpty
                    ? ListView.builder(
                        itemCount: alertsList.length,
                        itemBuilder: (context, index) {
                          return Alertwidget(
                            loggedInUser: widget.loggedInUser,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            marginSize: 3.0,
                            alertData: alertsList[index],
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