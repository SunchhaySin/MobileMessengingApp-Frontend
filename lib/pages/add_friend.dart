import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/widgets/friend/searchResult.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddFriendPage extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  const AddFriendPage({super.key, required this.loggedInUser});

  @override
  State<AddFriendPage> createState() => _AddFriendPage();
}

class _AddFriendPage extends State<AddFriendPage> {
  final TextEditingController _usernameController = TextEditingController();
  List<dynamic> searchResults = [];

  Future searchUsers(query) async {
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
                  "New Friends",
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: searchResults.isNotEmpty
                  ? ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        return SearchResultTemplate(
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          marginSize: 3.0,
                          searchResult: searchResults[index],
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No Results Found",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
