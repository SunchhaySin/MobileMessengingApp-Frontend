import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
        child: Container(
          // width: double.infinity,
          decoration: BoxDecoration(
            border: BoxBorder.all(color: Colors.white24),
          ),
          child: Column(
            children: [
              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "CURL",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  Icon(Icons.settings, color: Colors.white),
                ],
              ),
      
              // ================= SEARCH =================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Ask AI or Search Messages",
                      hintStyle: TextStyle(fontSize: 14, color: Colors.black),
                      prefixIcon: Icon(Icons.search, size: 22, color: Colors.black),
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
              ),
      
              // ================= HORIZONTAL LIST =================
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [Text("Item 1", style: TextStyle(color: Colors.white)), Text("Item 2", style: TextStyle(color: Colors.white))],
                  ),
                ),
              ),
      
              // ================= MAIN CONTENT =================
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                  ),
                  // child: Padding(
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 4,
                  //     vertical: 5,
                  //   ),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Text("Item 1", style: TextStyle(color: Colors.white)),
                      Text("Item 1", style: TextStyle(color: Colors.white)),
                      Text("Item 1", style: TextStyle(color: Colors.white)),
                      Text("Item 2", style: TextStyle(color: Colors.white)),
                    ],
                    // ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
