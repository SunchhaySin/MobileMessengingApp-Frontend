import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_page_provider.dart';
import '../../widgets/menu/ListTile.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPage();
}

class _ResetPasswordPage extends State<ResetPasswordPage> {
  late final TextEditingController oldPasswordController =
      TextEditingController();
  late final TextEditingController newPasswordController =
      TextEditingController();

  bool isMatchedPassword = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<MenuPageProvider>().darkMode;
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        color: isDarkMode ? Colors.black : Colors.white,
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
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Password Reset",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              "Enter your Old Password",
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 8),
            TileTemplate(
              title: TextFormField(
                controller: oldPasswordController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Old Password",
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              isDarkMode: isDarkMode,
              trailingWidget: Icon(Icons.lock, color: Colors.blue),
            ),
            SizedBox(height: 25),
            isMatchedPassword
                ? Column(
                    children: [
                      Text(
                        "Enter new Password",
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 8),
                      TileTemplate(
                        title: TextFormField(
                          controller: newPasswordController,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "New Password",
                            hintStyle: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black87,
                              fontSize: 14,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        isDarkMode: isDarkMode,
                        trailingWidget: Icon(Icons.lock, color: Colors.blue),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
