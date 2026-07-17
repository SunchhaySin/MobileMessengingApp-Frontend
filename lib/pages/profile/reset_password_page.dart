import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/apiConfig.dart';
import '../../providers/menu_page_provider.dart';
import '../../services/token.dart';
import '../../widgets/menu/ListTile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool isLoading = false;
  bool isObsure = true;

  Future<void> confirmOldPassword() async {
    if (oldPasswordController.text.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/account/password/reset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({"oldPassword": oldPasswordController.text}),
      );

      if (res.statusCode == 200) {
        setState(() => isMatchedPassword = true);
      } else  {
        final body = jsonDecode(res.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? "Something went wrong")),
          );
        }
      } 
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error Occured")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> submitNewPassword() async {
    if (newPasswordController.text.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/account/password/reset'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({
          "oldPassword": oldPasswordController.text,
          "newPassword": newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password updated successfully")),
          );
        }
      } else {
        final body = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? "Something went wrong")),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error Occurred")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

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
                onFieldSubmitted: (_) async {
                  await confirmOldPassword();
                },
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
              trailingWidget: ValueListenableBuilder<TextEditingValue>(
                valueListenable: oldPasswordController,
                builder: (context, value, child) {
                  if (isMatchedPassword) {
                    return const Icon(Icons.check_circle, color: Colors.green);
                  }
                  if (value.text.isEmpty) {
                    return const Icon(Icons.lock, color: Colors.blue);
                  }
                  if (isLoading) {
                    return const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return GestureDetector(
                    onTap: confirmOldPassword,
                    child: const Icon(Icons.check, color: Colors.blue),
                  );
                },
              )
              
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
                          obscureText: isObsure,
                          onFieldSubmitted: (_) async {
                            await submitNewPassword();
                          },
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
                        trailingWidget:
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: newPasswordController,
                              builder: (context, value, _) {
                                return value.text.isEmpty
                                    ? const Icon(
                                        Icons.lock,
                                        color: Colors.lightGreen,
                                      )
                                    : Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(
                                                () => isObsure = !isObsure,
                                              );
                                            },
                                            child: Icon(
                                              isObsure
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.lightGreen.shade600,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.lock_open,
                                            color: Colors.lightGreen,
                                          ),
                                        ],
                                      );
                              },
                            ),
                        //  Icon(Icons.lock, color: Colors.lightGreen),
                      ),
                      SizedBox(height: 14,),
                      GestureDetector(
                      onTap: () async {
                        await submitNewPassword();
                      },
                      child: Container(
                        width: 350,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.lightGreen.shade600,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Reset Password",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8,),
                            isLoading
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      backgroundColor:
                                          Colors.lightGreenAccent,
                                      color: Colors.black,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : SizedBox.shrink()
                        ],
                                                  ),
                      ),
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
