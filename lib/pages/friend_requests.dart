import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/friend/friendRequest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

class FriendRequestPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const FriendRequestPage({super.key, required this.loggedInUser});

  @override
  State<FriendRequestPage> createState() => _FriendRequestPage();
}

class _FriendRequestPage extends State<FriendRequestPage> {
  bool isSentRequest = false;
  bool isReceivedRequest = true;
  bool isSelectMode = false;
  final List<String> selectedSentRequests = [];
  final List<String> selectedReceivedRequests = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => fetchRequests());
  }

  Future fetchRequests() async {
    try {
      final provider = Provider.of<FriendProvider>(context, listen: false);
      if (provider.requestsLoaded) return;

      final url = Uri.parse('${ApiConfig.baseUrl}/friend/fetch/requests');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
          },
      );
      
      print(res.body);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        provider.setRequests(data['sentRequests'], data['receivedRequests']);
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

  Future<void> removeMultipleRequests(List<String> requestIds, String requestType) async {
    final message = await context.read<FriendProvider>().removeRequest(requestIds, requestType);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendProvider>();
    final sentRequests = provider.sentRequests;
    final receivedRequests = provider.receivedRequests;
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        color: Colors.black87,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                GestureDetector(
                  onTap: () async {
                    if (isSelectMode) {
                      // currently in select mode -> this tap means "confirm delete"
                      final ids = isReceivedRequest
                          ? selectedReceivedRequests
                          : selectedSentRequests;
                      final type = isReceivedRequest ? "received" : "sent";

                      if (ids.isNotEmpty) {
                        await removeMultipleRequests(List.from(ids), type);
                        setState(() {
                          ids.clear();
                          isSelectMode = false;
                        });
                      } else {
                        setState(() {
                          isSelectMode = false;
                        });
                      }
                    } else {
                      // not in select mode -> this tap just enters select mode
                      setState(() {
                        isSelectMode = true;
                      });
                    }
                  },
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      color: Colors.white70,
                      isSelectMode
                        ? Icons.delete 
                        : Icons.check_circle_outline_outlined ),
                    SizedBox(width: 2,),
                    Text(isSelectMode? "Delete" : "Select", style: TextStyle(fontSize: 15, color: Colors.white),),
                    if (isSelectMode) ...[
                        SizedBox(width: 6),
                        Builder(
                          builder: (context) {
                            final count = isReceivedRequest
                                ? selectedReceivedRequests.length
                                : selectedSentRequests.length;

                            if (count == 0) return const SizedBox.shrink();

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$count",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                  ],
                ),
                )
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
                        isSelectMode = false;
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
                        isSelectMode = false;
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
                                selectMode: isSelectMode? true : false,
                                onSelection: (requestId, selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedReceivedRequests.add(requestId);
                                      print("received, $selectedReceivedRequests");
                                    } else {
                                      selectedReceivedRequests.remove(requestId);
                                      print("received, $selectedReceivedRequests");
                                    }
                                  });
                                },
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
                                selectMode: isSelectMode? true : false,
                                onSelection: (requestId, selected) {
                                  setState(() {
                                    if (selected) {
                                      selectedSentRequests.add(requestId);
                                      print("sent : $selectedSentRequests");
                                    } else {
                                      selectedSentRequests.remove(requestId);
                                      print("sent : $selectedSentRequests");
                                    }
                                  });
                                },
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
