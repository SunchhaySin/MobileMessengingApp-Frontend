import 'package:flutter/material.dart';
import 'package:frontend/services/socket.dart';
// import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/dialog/friendRequestDialog.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class FriendrequestTemplate extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final double marginSize;
  final Map<String, dynamic> fetchResult;
   final String resultType;

  const FriendrequestTemplate({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.fetchResult,
    required this.marginSize,
    required this.resultType,
  });

  @override
  State<FriendrequestTemplate> createState() => _FriendrequestTemplate();
}

class _FriendrequestTemplate extends State<FriendrequestTemplate> {

    // Future acceptRequest(String requestId) async {
    //   try {
    //     final url = Uri.parse('http://10.0.2.2:3000/friend/accept/$requestId');
    //     final res = await http.post(
    //       url,
    //       headers: {
    //         'Content-Type': 'application/json',
    //         'Authorization': 'Bearer ${AuthService.token}',
    //       },
    //     );

    //     final data = jsonDecode(res.body);

    //     if (res.statusCode == 200) {
    //       if (mounted) {
    //         ScaffoldMessenger.of(
    //           context,
    //         ).showSnackBar(SnackBar(content: Text(data['message'])));
    //       }
    //     } else {
    //       if (mounted) {
    //         ScaffoldMessenger.of(
    //           context,
    //         ).showSnackBar(SnackBar(content: Text(data['message'])));
    //       }
    //     }
    //   } catch (e) {
    //     print(e);
    //   }
    // }

    // Future rejectRequest(String requestId) async {
    //   try {
    //     final url = Uri.parse('http://10.0.2.2:3000/friend/reject/$requestId');
    //     final res = await http.post(
    //       url,
    //       headers: {
    //         'Content-Type': 'application/json',
    //         'Authorization': 'Bearer ${AuthService.token}',
    //       },
    //     );

    //     final data = jsonDecode(res.body);

    //     if (res.statusCode == 200) {
    //       if (mounted) {
    //         ScaffoldMessenger.of(
    //           context,
    //         ).showSnackBar(SnackBar(content: Text(data['message'])));
    //       }
    //     } else {
    //       if (mounted) {
    //         ScaffoldMessenger.of(
    //           context,
    //         ).showSnackBar(SnackBar(content: Text(data['message'])));
    //       }
    //     }
    //   } catch (e) {
    //     print(e);
    //   }
    // }
  void acceptRequest(String requestId) {
    final socket = SocketService().socket;

    socket?.emit('friend:accept', {'requestId': requestId});

    socket?.once('friend:accept:success', (data) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    });

    socket?.once('friend:accept:error', (data) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    });
  }

  void rejectRequest(String requestId) {
    final socket = SocketService().socket;

    socket?.emit('friend:reject', {'requestId': requestId});

    socket?.once('friend:reject:success', (data) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    });

    socket?.once('friend:reject:error', (data) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        FriendRequestDialog(
          requestId: widget.fetchResult['id'],
          username: widget.resultType == "received"
              ? widget.fetchResult['requestFrom']['username']
              : widget.fetchResult['requestTo']['username'],
          isReceived: widget.resultType == "received",
          onAccept: acceptRequest,
          onReject: rejectRequest,  
          // onRemove: removeRequest,   // add if you have this
        ).openDialog(context);
      },
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
                  child: Text("Profile"),
                ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    widget.resultType == "sent"
                        ? Text(
                            widget.fetchResult['requestTo']['username'],
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            widget.fetchResult['requestFrom']['username'],
                            style: TextStyle(
                              color: widget.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    widget.resultType == "sent"
                        ? Text(
                            widget.fetchResult['requestTo']['email'],
                            style: TextStyle(color: widget.textColor),
                          )
                        : Text(
                            widget.fetchResult['requestFrom']['email'],
                            style: TextStyle(color: widget.textColor),
                          ),
                  ],
                ),
              ],
            ),
            SizedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.fetchResult['status'],
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.fetchResult['createdAt'],
                    style: TextStyle(color: widget.textColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}