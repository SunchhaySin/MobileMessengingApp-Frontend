import 'package:flutter/material.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/widgets/dialog/friendRequestDialog.dart';

import '../../utils/profileName.dart';


class FriendrequestTemplate extends StatefulWidget {
  final bool isDarkMode;
  final double marginSize;
  final Map<String, dynamic> fetchResult;
  final String resultType;
  final bool selectMode;
  final String? profileUrl;

  final void Function(String requestId, bool selected) onSelection; // send Request id back to parent

  const FriendrequestTemplate({
    super.key,
    required this.isDarkMode,
    required this.fetchResult,
    required this.marginSize,
    required this.resultType,
    required this.selectMode,
    required this.onSelection,
    this.profileUrl
  });

  @override
  State<FriendrequestTemplate> createState() => _FriendrequestTemplate();
}

class _FriendrequestTemplate extends State<FriendrequestTemplate> {
  late final String requestId;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    requestId = widget.fetchResult['id'];
  }

  void acceptRequest(String requestId) async {
    final message = await context.read<FriendProvider>().acceptRequest(
      requestId,
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void rejectRequest(String requestId) async {
    final message = await context.read<FriendProvider>().rejectRequest(
      requestId,
    );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void removeSignleRequest(String requestIds, String requestType) async {
    final message = await context.read<FriendProvider>().removeRequest([requestIds], requestType);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }


  @override
  Widget build(BuildContext context) {
    final DateTime createdAt = DateTime.parse(widget.fetchResult['createdAt']);
    final String status = widget.fetchResult['status'];

    Color getStatusColor(String status) {
      switch (status) {
        case "Accepted":
          return Colors.green;
        case "Rejected":
          return Colors.red;
        case "Sent":
          return Colors.orange;
        default:
          return Colors.white;
      }
    }
    final profileName = ProfileName.getInitials(
      widget.resultType == "sent" 
        ? widget.fetchResult['requestTo']['username']
        : widget.fetchResult['requestFrom']['username']);

    return InkWell(
      onTap: () {
        widget.selectMode 
          ? setState(() {
              isSelected = !isSelected;
              widget.onSelection(requestId, isSelected);
            })
          : FriendRequestDialog(
              requestId: requestId,
              username: widget.resultType == "received"
                  ? widget.fetchResult['requestFrom']['username']
                  : widget.fetchResult['requestTo']['username'],
              isReceived: widget.resultType == "received",
              onAccept: acceptRequest,
              onReject: rejectRequest,
              onRemove: (id) => removeSignleRequest(id, widget.resultType),
              profileUrl: widget.profileUrl
            ).openDialog(context);
      },
      child: Container(
        width: double.infinity,
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: widget.marginSize),
        decoration: BoxDecoration(
          color: widget.isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300 ,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                widget.resultType == "sent"
                  ? Icon(Icons.call_made, color: Colors.blue)
                  : Icon(Icons.call_received, color: Colors.blue),
                SizedBox(width: 8),
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
                          color: Colors.blueGrey,
                        ),
                        child: Center(
                          child: Text(
                            profileName,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
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
                                  color: widget.isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                        : Text(
                            widget.fetchResult['requestFrom']['username'],
                            style: TextStyle(
                              color: widget.isDarkMode ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    widget.resultType == "sent"
                        ? Text(
                            widget.fetchResult['requestTo']['email'],
                            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black,),
                          )
                        : Text(
                            widget.fetchResult['requestFrom']['email'],
                            style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black,),
                          ),
                  ],
                ),
              ],
            ),
            widget.selectMode
                ? SizedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              status,
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                            ),
                          ],
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelected = !isSelected;
                              widget.onSelection(requestId, isSelected);
                            });
                          },
                          child: Icon(
                            isSelected
                                ? Icons.check_circle_outline_outlined
                                : Icons.circle_outlined,
                            color: isSelected? Colors.green : widget.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            color: getStatusColor(status),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${createdAt.day}/${createdAt.month}/${createdAt.year}",
                          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black,),
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