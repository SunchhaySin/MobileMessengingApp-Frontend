import 'package:flutter/material.dart';
import '../../widgets/menu/ListTile.dart';

class MyProfile extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final bool isDarkMode;
  const MyProfile({super.key, required this.loggedInUser, required this.isDarkMode});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late final TextEditingController usernameController;
  late final TextEditingController contactController = TextEditingController();
  late final TextEditingController bioController = TextEditingController();

  bool isEditUsername = false;
  bool isEditContacts = false;
  bool isEditBio = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(
      text: widget.loggedInUser['username'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
        color: widget.isDarkMode ?Colors.black :Colors.white,
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back, color: widget.isDarkMode ?Colors.white :Colors.black),
                ),
                SizedBox(width: 8),
                Text(
                  "Your Profile",
                  style: TextStyle(
                    color: widget.isDarkMode ?Colors.white :Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20,),
            CircleAvatar(
              radius: 50,
              backgroundColor: widget.isDarkMode ?Colors.white :Colors.black,
              child: Text(
                "profileimg",
                style: TextStyle(color: widget.isDarkMode ?Colors.black :Colors.white),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(3),
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent.shade200),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Text(
                  "Add Profile",
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),
              ),
            ),
            SizedBox(height: 14),
            TileTemplate(
              title: isEditUsername
                  ? TextFormField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    )
                  : Text(
                      widget.loggedInUser['username'],
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
              subtitle: "Display Name",
              subtitleColor: Colors.grey.shade400,
        
              isDarkMode:  widget.isDarkMode,
              trailingWidget: TextButton(
                onPressed: () {
                  setState(() => isEditUsername = !isEditUsername);
                  setState(() => isEditBio = false);
                  setState(() => isEditContacts = false);
                },
                child: Text(
                  isEditUsername ? "Confirm" : "Edit",
                  style: const TextStyle(
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ontap: () => setState(() {
                if (isEditUsername) {}
              }),
            ),
            SizedBox(height: 5),
            TileTemplate(
              title: isEditContacts
                  ? TextFormField(
                      controller: contactController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    )
                  : Text(
                     "none",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
              subtitle: "Contacts",
              subtitleColor: Colors.grey.shade400,
        
              isDarkMode:  widget.isDarkMode,
              trailingWidget: TextButton(
                onPressed: () {
                   setState(() => isEditContacts = !isEditContacts);
                   setState(() => isEditUsername = false);
                   setState(() => isEditBio = false);
                },
                child: Text(
                  "Edit",
                  style: const TextStyle(
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ontap: () => setState(() {
                // dropdownActive = !dropdownActive;
              }),
            ),
            SizedBox(height: 5),
            TileTemplate(
              title: isEditBio
                  ? TextFormField(
                      controller: bioController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                    )
                  : Text(
                     "none",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
              subtitle: "bio",
              subtitleColor: Colors.grey.shade400,
        
              isDarkMode:  widget.isDarkMode,
              trailingWidget: TextButton(
                onPressed: () {
                  setState(() => isEditBio = !isEditBio);
                  setState(() => isEditContacts = false);
                  setState(() => isEditUsername = false);
                },
                child: Text(
                  "Edit",
                  style: const TextStyle(
                    color: Colors.lightGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ontap: () => setState(() {
                // dropdownActive = !dropdownActive;
              }),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

