import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../config/apiConfig.dart';
import '../../providers/menu_page_provider.dart';
import '../../services/token.dart';
import '../../widgets/menu/profile_history_widget.dart';

class ProfileHistory extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final bool isDarkMode;
  const ProfileHistory({
    super.key,
    required this.loggedInUser,
    required this.isDarkMode,
  });

  @override
  State<ProfileHistory> createState() => _ProfileHistoryState();
}

class _ProfileHistoryState extends State<ProfileHistory> {
  bool isLoading = false;

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);
    try {
      final provider = Provider.of<MenuPageProvider>(context, listen: false);
      final res = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/profile/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print(data);
        provider.setProfileHistory(data);
      }
      setState(() => isLoading = false);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    final historyList = context.watch<MenuPageProvider>().profileHistory;
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: widget.isDarkMode ? Colors.black : Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Profile History",
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: !isLoading
                    ? historyList.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 25,
                              ),
                              child: ListView.builder(
                                itemCount: historyList.length,
                                itemBuilder: (context, index) {
                                  final historyRecord = historyList[index];

                                  return ProfileHistoryWidget(
                                    message: historyRecord['message'],
                                    timeStamp: historyRecord['createdAt'],
                                    isDarkMode: widget.isDarkMode,
                                  );
                                },
                              ),
                            )
                          : Center(
                              child: Text(
                                "No Profile History",
                                style: TextStyle(
                                  color: widget.isDarkMode
                                      ? Colors.white
                                      : Colors.white,
                                ),
                              ),
                            )
                    : Column(
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
                            style: TextStyle(
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
