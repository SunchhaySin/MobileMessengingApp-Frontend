import 'package:flutter/material.dart';
import 'package:frontend/layout.dart';
import 'package:frontend/services/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterInterface extends StatefulWidget {
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onBackClick;

  const RegisterInterface({super.key, this.backgroundColor, this.textColor, this.onBackClick});

  @override
  State<RegisterInterface> createState() => _RegisterInterface();
}

class _RegisterInterface extends State<RegisterInterface> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureText = true;
  bool isLoading = false;

  Future registerUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url = Uri.parse('http://10.0.2.2:3000/auth/register');
      final body = jsonEncode({
        "email": _emailController.text,
        "username": _usernameController.text,
        "password": _passwordController.text,
        "confirmPassword": _confirmPasswordController.text,
      });

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        AuthService.token = data['token'];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Layout(
              loggedInUser: {
                "username": data['data']['username'],
                "email": data['data']['email'],
                "userID": data['data']['id'],
              },
            ),
          ),
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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  } 

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: widget.backgroundColor ?? Colors.amberAccent,
      ),
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TextFormField(
              controller: _emailController,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, color: Colors.white,),
                labelStyle: TextStyle(color: Colors.white60),
                labelText: "Email",
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
          SizedBox(height:10),
          SizedBox(
            height: 50,
            child: TextFormField(
              controller: _usernameController,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.white,),
                labelStyle: TextStyle(color: Colors.white60),
                labelText: "Username",
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
          SizedBox(height:10),
          SizedBox(
            height: 50,
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outlined, color: Colors.white,),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    color: Colors.white,
                    _obscureText
                    ? Icons.visibility_off
                    : Icons.visibility),
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
          SizedBox(height:10),
          SizedBox(
            height: 50,
            child: TextFormField(
              controller: _confirmPasswordController,
              style: TextStyle(color: widget.textColor),
              obscureText: _obscureText,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_outlined, color: Colors.white,),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    color: Colors.white,
                    _obscureText
                    ? Icons.visibility_off
                    : Icons.visibility),
                ),
                labelStyle: TextStyle(color: Colors.white60),
                labelText: "Confirm Password",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Already Registered?",
                style: TextStyle(color: widget.textColor),
              ),
              SizedBox(width:3),
              TextButton(
                onPressed: widget.onBackClick,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero), 
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                ),
                child: Text(
                  "Login Now",
                  style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              await registerUser();
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
                            SizedBox(
                              height: 28,
                              width: 28,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white, // Color of the underlying track
                                color: Colors .black, // Color of the moving indicator
                                strokeWidth:2.0, // Thickness of the circle lines
                              ),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        "Register Account",
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