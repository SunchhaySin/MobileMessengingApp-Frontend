import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/layout.dart';
import 'package:frontend/services/token.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../providers/menu_page_provider.dart';

class LoginInterface extends StatefulWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onRegisterClick;

  const LoginInterface({
    super.key,
    this.backgroundColor,
    this.textColor,
    this.onRegisterClick,
  });

  @override
  State<LoginInterface> createState() => _LoginInterface();
}

class _LoginInterface extends State<LoginInterface> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool isLoading = false;
  bool rememberMe = false;

  Future loginUser() async {
    final provider = Provider.of<MenuPageProvider>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

      final body = jsonEncode({
        "identifier": _identifierController.text,
        "password": _passwordController.text,
      });

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        AuthService.token = data['token'];

        final loggedInUser = {
          "username": data['data']['username'],
          "email": data['data']['email'],
          "userID": data['data']['id'],
        };
        provider.setCurrentUser(loggedInUser);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data["message"])));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Layout()),
        );
      } else {
        final error = jsonDecode(res.body)['message'];
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      print(e);
    } finally  {
      if(mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TextFormField(
              controller: _identifierController,
              style: TextStyle(color: widget.textColor),
              onFieldSubmitted: (_) async {
                await loginUser();
              } ,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white),
                labelStyle: TextStyle(color: Colors.white60),
                labelText: "Email or Username",
                floatingLabelStyle: TextStyle(color: Colors.blue, fontSize: 18),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white24),
                ),
                fillColor: Colors.grey[800],
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: TextStyle(color: widget.textColor),
              onFieldSubmitted: (_) async {
                await loginUser();
              } ,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outlined, color: Colors.white),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    color: Colors.white,
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
                labelStyle: TextStyle(color: Colors.white60),
                labelText: "Password",
                floatingLabelStyle: TextStyle(color: Colors.blue, fontSize: 18),
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue, width: 1),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white24),
                ),

                fillColor: Colors.grey[800],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top:10, right: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        rememberMe = !rememberMe;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        rememberMe ? Icons.check_box_outlined : Icons.check_box_outline_blank_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              
                Text("Remember Me", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right:4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "New to our app?",
                  style: TextStyle(color: widget.textColor),
                ),
                SizedBox(width: 3),
                GestureDetector(
                  onTap: widget.onRegisterClick,
                  child: Text(
                    "Register Now",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              await loginUser();
            },
            child: Container(
              width: 350,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Loading",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 12,),
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white54, // Color of the underlying track
                                color: Colors.black, // Color of the moving indicator
                                strokeWidth: 2.0, // Thickness of the circle lines
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],  
      ),
    );
  }
}
