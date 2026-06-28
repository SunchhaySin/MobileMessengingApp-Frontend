import 'package:flutter/material.dart';
import 'package:frontend/prompt.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Prompt()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade200, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Text("Hello World"), // Change to App Logo
              ),
            ),

            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Text("AI Messenging App", textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
