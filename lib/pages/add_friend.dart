import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/friend/searchResult.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddFriendPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final bool isDarkMode;
  const AddFriendPage({super.key, required this.loggedInUser, required this.isDarkMode});

  @override
  State<AddFriendPage> createState() => _AddFriendPage();
}

class _AddFriendPage extends State<AddFriendPage> {
  final TextEditingController _usernameController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;

  Future searchUsers(query) async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/friend/search?q=$query');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
          },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          searchResults = data;
        });
      } else {
        final response = jsonDecode(res.body)['message'];
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response)));
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        color: widget.isDarkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back, color: widget.isDarkMode ? Colors.white : Colors.black),
                ),
                SizedBox(width: 8),
                Text(
                  "New Friends",
                  style: TextStyle(
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: TextFormField(
                controller: _usernameController,
                maxLines: 1,
                onFieldSubmitted: (_) async {
                  await searchUsers(_usernameController.text);
                },
                decoration: InputDecoration(
                  hintText: "Enter username",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                  prefixIcon: Icon(Icons.search, size: 22, color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _usernameController.text = "";
                      });
                    },
                    child: Icon(Icons.clear),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.black,
                            strokeWidth: 2.0,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Loading...",
                          style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black, fontSize: 12),
                        ),
                      ],
                    )
                  : searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return SearchResultTemplate(
                          marginSize: 3.0,
                          searchResult: searchResults[index],
                          isDarkMode: widget.isDarkMode,
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No Results Found",
                        style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
                      ),
                    ),
            ) 
          ],
        ),
      ),
    );
  }
}
