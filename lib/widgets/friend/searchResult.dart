import 'package:flutter/material.dart';
import 'package:frontend/services/socket.dart';
// import 'package:frontend/services/token.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class SearchResultTemplate extends StatefulWidget {
  final Color backgroundColor;
  final Color textColor;
  final double marginSize;
  final Map<String, dynamic> searchResult;

  const SearchResultTemplate({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    required this.searchResult,
    required this.marginSize,

  });

  @override
  State<SearchResultTemplate> createState() => _SearchResultTemplateState();
}

class _SearchResultTemplateState extends State<SearchResultTemplate> {
  
  // Future addFriend(String targetUserId) async {
  //   try {
  //     final url = Uri.parse('http://10.0.2.2:3000/friend/add');
  //     final res = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer ${AuthService.token}',
  //       },
  //       body: jsonEncode({'recipientID': targetUserId}),
  //     );

  //     final data = jsonDecode(res.body);

  //     if (res.statusCode == 201) {
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
  //     // print(targetUserId);
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  void addFriend(String recipientId) {
    final socket = SocketService().socket;

    socket?.emit('friend:add', {'recipientId': recipientId});

    socket?.once('friend:add:success', (data) {
      _showSnackbar(data['message']);
    });

    socket?.once('friend:add:error', (data) {
      _showSnackbar(data['message']);
    });
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  Text(
                    widget.searchResult['username'],
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.searchResult['email'],
                    style: TextStyle(color: widget.textColor),
                  ),
                ],
              ),
            ],
          ),
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.lightGreen,
            ),
            child: InkWell(
              onTap: () async {
                addFriend(widget.searchResult['id']);
              },
              child: Icon(Icons.person_add_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
