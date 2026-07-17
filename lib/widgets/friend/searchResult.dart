import 'package:flutter/material.dart';
import 'package:frontend/providers/friend_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/profileName.dart';

class SearchResultTemplate extends StatefulWidget {
  final double marginSize;
  final Map<String, dynamic> searchResult;
  final bool isDarkMode;

  const SearchResultTemplate({
    super.key,
    required this.searchResult,
    required this.marginSize,
    required this.isDarkMode,
  });

  @override
  State<SearchResultTemplate> createState() => _SearchResultTemplateState();
}

class _SearchResultTemplateState extends State<SearchResultTemplate> {
  bool isLoading = false;

  // Sending Friend request to other users
  void addFriend(String recipientId) async {
    setState(() => isLoading = true);
    try {
      final message = await context.read<FriendProvider>().addFriendRequest(
        recipientId,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileName = ProfileName.getInitials(
      widget.searchResult['username'],
    );
    final profileImage = widget.searchResult['profile']?['profileUrl'];

    return Container(
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
              profileImage != null
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(profileImage),
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
                  Text(
                    widget.searchResult['username'],
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.searchResult['email'],
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
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
              child: isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightGreenAccent,
                        color: Colors.black,
                        strokeWidth: 2.0,
                      ),
                    )
                  : Icon(Icons.person_add_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
