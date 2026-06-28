import 'package:flutter/material.dart';
// import 'package:frontend/layout.dart';
import 'package:frontend/widgets/login_Interface.dart';
import 'package:frontend/widgets/register_interface.dart';

class Prompt extends StatefulWidget {
  const Prompt({super.key});

  @override
  State<Prompt> createState() => _Prompt();
}

class _Prompt extends State<Prompt> {
  bool _loginWidget = true;

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black87,
        ),
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,      
          children: [
            Text("CURL Messenging App", style: TextStyle(color: Colors.white, fontSize: 22)),
            SizedBox(height:2),
            SizedBox(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_loginWidget ? Icons.account_circle_outlined : Icons.account_box_sharp, color: Colors.white70,),
                SizedBox(width: 5),
                Text(_loginWidget ? "Login to continue" : "Create New Account", style: TextStyle(color: Colors.white70, fontSize: 15)),
              ],
            )),
            SizedBox(height: 15),
            _loginWidget 
              ? LoginInterface(backgroundColor: Colors.black, textColor:Colors.white, onRegisterClick: () => setState(() => _loginWidget =!_loginWidget,),)
              : RegisterInterface(backgroundColor: Colors.black, textColor:Colors.white, onBackClick: () => setState(() => _loginWidget =!_loginWidget,)),
            // TextButton(
            //   onPressed: () {
            //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Layout(loggedInUser: { 
            //       "username": "AdminBypass",
            //       "email": "admin@gmail.com",
            //       "userID": 1,})));
            //   },
            //   child: Text("Bypass Login - Developer Access ONLY !!"),
            // )
          ],
        ),
      ),
    );
  }
}