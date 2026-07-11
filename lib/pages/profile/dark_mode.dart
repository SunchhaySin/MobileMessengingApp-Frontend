import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_page_provider.dart';
import '../../widgets/menu/ListTile.dart';

class DarkModePage extends StatefulWidget {
  const DarkModePage({super.key});

  @override
  State<DarkModePage> createState() => _DarkModePageState();
}

class _DarkModePageState extends State<DarkModePage> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<MenuPageProvider>().darkMode;
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        color: isDarkMode ?Colors.black :Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back, color: isDarkMode ?Colors.white :Colors.black),
                ),
                SizedBox(width: 8),
                Text(
                  "Dark Mode & Preference",
                  style: TextStyle(
                    color: isDarkMode ?Colors.white :Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 45),
            TileTemplate(
              title: Text(
                "On",
                style: TextStyle(
                  color: isDarkMode ?Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              isDarkMode:  isDarkMode,
              trailingWidget: isDarkMode? Icon(Icons.check, color: Colors.blue) : SizedBox.shrink(),
              ontap: () => context.read<MenuPageProvider>().turnOn(),
            ),
            SizedBox(height: 5),
            TileTemplate(
              title: Text(
                "Off",
                style: TextStyle(
                  color: isDarkMode ?Colors.white70 : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              isDarkMode: isDarkMode,
              trailingWidget: isDarkMode? SizedBox.shrink() : Icon(Icons.check, color: Colors.blue),
              ontap: () => context.read<MenuPageProvider>().turnOff(),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
