import 'package:flutter/material.dart';
// import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/friend/friendRequest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:provider/provider.dart';

class FriendRequestPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const FriendRequestPage({super.key, required this.loggedInUser});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPage();
}

class _FriendRequestPage extends State<FriendRequestPage> {
  List<dynamic> sentRequests = [];
  List<dynamic> receivedRequests = [];
  bool isSentRequest = false;
  bool isReceivedRequest = true;

  @override
  void initState() {
    super.initState();
    // Future.microtask(() => fetchRequests());
    fetchRequests();
  }

  Future fetchRequests() async {
    try {
      // final provider = Provider.of<FriendProvider>(context, listen: false);
      // if (provider.loaded) return;

      final url = Uri.parse('http://10.0.2.2:3000/friend/fetch/requests');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
          },
      );
      
      // print(res.body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // provider.setSentRequests(data['sentRequests']);
        // provider.setReceivedRequests(data['receivedRequests']);
        setState(() {
          sentRequests = data['sentRequests'];
          receivedRequests = data['receivedRequests'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Data not found")));
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<FriendProvider>(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        color: Colors.black87,
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                SizedBox(width: 8),
                Text(
                  "Friend Requests",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.only(left:10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isReceivedRequest = true;
                        isSentRequest = false;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Requests Received",
                          style: TextStyle(
                            color: isReceivedRequest
                                ? Colors.blue
                                : Colors.white,
                            fontWeight: isReceivedRequest
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: isReceivedRequest ? 70 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isReceivedRequest = false;
                        isSentRequest = true;
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Requests Sent",
                          style: TextStyle(
                            color: isSentRequest ? Colors.blue : Colors.white,
                            fontWeight: isSentRequest
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          width: isSentRequest ? 60 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isReceivedRequest
                ? Expanded(
                    child: receivedRequests.isNotEmpty
                        ? ListView.builder(
                            itemCount: receivedRequests.length,
                            itemBuilder: (context, index) {
                              return FriendrequestTemplate(
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                marginSize: 3.0,
                                fetchResult: receivedRequests[index],
                                resultType: "received",
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "No Requests Found",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  )
                : SizedBox.shrink(),

            isSentRequest
                ? Expanded(
                    child: sentRequests.isNotEmpty
                        ? ListView.builder(
                            itemCount: sentRequests.length,
                            itemBuilder: (context, index) {
                              return FriendrequestTemplate(
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                marginSize: 3.0,
                                fetchResult: sentRequests[index],
                                resultType: "sent",
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              "No Requests Found",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
