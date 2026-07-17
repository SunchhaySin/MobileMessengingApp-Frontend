import 'package:flutter/material.dart';
import 'package:frontend/config/apiConfig.dart';
import 'package:frontend/pages/profile/profile_history.dart';
import 'package:frontend/pages/profile/reset_password_page.dart';
import 'package:frontend/services/token.dart';
import 'package:frontend/utils/profileName.dart';
import 'package:frontend/widgets/dialog/viewProfile.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_page_provider.dart';
import '../../widgets/menu/ListTile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

class MyProfile extends StatefulWidget {
  final Map<String, dynamic> loggedInUser;
  final bool isDarkMode;
  const MyProfile({
    super.key,
    required this.loggedInUser,
    required this.isDarkMode,
  });

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late final TextEditingController usernameController = TextEditingController();
  late final TextEditingController bioController = TextEditingController();
  late final TextEditingController contactController = TextEditingController();

  bool isEditUsername = false;
  bool isEditContacts = false;
  bool isEditBio = false;

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.loggedInUser['username'];
  }

  Future<void> updateUsername() async {
    try {
      final provider = Provider.of<MenuPageProvider>(context, listen: false);
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/profile/name'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({"newUsername": usernameController.text}),
      );

      final data = jsonDecode(res.body);
      usernameController.text = data['newUsername'];
      provider.updateUsername(data['newUsername']);
      if(data['history'] != null){
        provider.updateHistoryList(data['history']);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveContacts() async {
    try {
      final provider = Provider.of<MenuPageProvider>(context, listen: false);

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/profile/contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({"contacts": contactController.text}),
      );
      final data = jsonDecode(res.body);
      contactController.text = data['contact'];
      provider.updateContact(data['contact'] as String? ?? "");
      if(data['history'] != null){
        provider.updateHistoryList(data['history']);
      }
    } catch (e) {
      print(e);
    }
  }

    Future<void> saveBio() async {
    try {
      final provider = Provider.of<MenuPageProvider>(context, listen: false);

      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/profile/bio'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode({"newBio": bioController.text}),
      );
      final data = jsonDecode(res.body);
      bioController.text = data['bio'];
      provider.updateBio(data['bio'] as String? ?? "");
      if(data['history'] != null){
        provider.updateHistoryList(data['history']);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> uploadImage(File image) async {
    try {
      final provider = Provider.of<MenuPageProvider>(context, listen: false);
      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiConfig.baseUrl}/profile/upload/image"),
      );

      request.headers["Authorization"] = "Bearer ${AuthService.token}";
      
      final mimeType = lookupMimeType(image.path) ?? "image/jpeg";

      request.files.add(
        await http.MultipartFile.fromPath(
          "image",        // Must match upload.single("image")
          image.path,
          contentType: MediaType.parse(mimeType)
        ),
      );

      final response = await request.send();
      final body = await response.stream.bytesToString();

      final data = jsonDecode(body);
      provider.updateProfilePicture(data["profileUrl"]);
      // print("request Body : $body");
    } catch (e) {
      print(e);
    }
  }

  Future<File> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = "${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 512,   // plenty for an avatar, even on retina displays
      minHeight: 512,
      format: CompressFormat.jpeg,
    );

    return File(result!.path);
  }
  
  final ImagePicker _picker = ImagePicker();
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    final compressedImage = await compressImage(File(image.path));
    uploadImage(compressedImage);
  }

  @override
  Widget build(BuildContext context) {
    final myDisplayName = context.watch<MenuPageProvider>().currentUser['username'];
    final myContacts = context.watch<MenuPageProvider>().myContacts;
    final myBio = context.watch<MenuPageProvider>().myBio;
    final profileUrl = context.watch<MenuPageProvider>().profileUrl;
    final profileName = ProfileName.getInitials(myDisplayName);

    contactController.text = myContacts;
    bioController.text = myBio;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 10),
          color: widget.isDarkMode ? Colors.black : Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        "Your Profile",
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileHistory(
                              loggedInUser: widget.loggedInUser,
                              isDarkMode: widget.isDarkMode,
                            ),
                          ),
                        ),
                        child: Icon(
                          Icons.history,
                          color: widget.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      Text(
                        "History",
                        style: TextStyle(
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => Viewprofile(profileUrl: profileUrl, isDarkMode: widget.isDarkMode).openDialog(context),
                child: profileUrl != ""
                    ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(profileUrl),
                      )
                    : Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.lightBlue.shade300,
                        ),
                        child: Center(
                          child: Text(
                            profileName,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
              ),
              GestureDetector(
                onTap: pickImage,
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
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    "Username",
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white70 : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              TileTemplate(
                title: isEditUsername
                    ? Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: TextFormField(
                          controller: usernameController,
                          style: TextStyle(color: widget.isDarkMode ?Colors.white :Colors.black),
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
                        ),
                      )
                    : Text(
                        myDisplayName,
                        style: TextStyle(color: Colors.blue, fontSize: 15),
                      ),
                subtitle: "Display Name",
                subtitleColor: Colors.grey.shade400,
                isDarkMode: widget.isDarkMode,
                trailingWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          if (isEditUsername) {
                            updateUsername();
                            setState(() => isEditUsername = false);
                          } else {
                            setState(() => isEditUsername = true);
                            setState(() => isEditBio = false);
                            setState(() => isEditContacts = false);
                          }
                        },
                        child: Text(
                          isEditUsername ? "Confirm" : "Edit",
                          style: const TextStyle(
                            color: Colors.lightGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    isEditUsername
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: InkWell(
                              onTap: () => setState(() => isEditUsername = false),
                              child: Text(
                                "Cancel",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    "Contacts",
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? Colors.white70
                          : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              TileTemplate(
                    title: isEditContacts
                        ? TextFormField(
                            controller: contactController,
                            style: TextStyle(color: widget.isDarkMode ?Colors.white :Colors.black),
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
                            myContacts == ""
                                ? "Not set"
                                : myContacts,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 15,
                            ),
                          ),
                    isDarkMode: widget.isDarkMode,
                    trailingWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () {
                              if (isEditContacts) {
                                saveContacts();
                                setState(() => isEditContacts = false);
                              } else {
                                contactController.text = myContacts;
                                setState(() => isEditContacts = true);
                                setState(() => isEditUsername = false);
                                setState(() => isEditBio = false);
                              }
                            },
                            child: Text(
                              isEditContacts ? "Save" : "Edit",
                              style: const TextStyle(
                                color: Colors.lightGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
        
                        isEditContacts
                            ? Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => isEditContacts = false),
                                  child: Text(
                                    "Cancel",
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "Bio",
                      style: TextStyle(
                        color: widget.isDarkMode ? Colors.white70 : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              TileTemplate(
                title: isEditBio
                    ? TextFormField(
                        controller: bioController,
                        style: TextStyle(color: widget.isDarkMode ?Colors.white :Colors.black),
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
                        myBio == "" ? "Not set" : myBio,
                        style: TextStyle(color: Colors.blue, fontSize: 15),
                      ),
                isDarkMode: widget.isDarkMode,
                trailingWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: InkWell(
                        onTap: () {
                          if (isEditBio) {
                            saveBio();
                            setState(() => isEditBio = false);
                          } else {
                            bioController.text = myBio;
                            setState(() => isEditBio = true);
                            setState(() => isEditContacts = false);
                            setState(() => isEditUsername = false);
                          }
                        },
                        child: Text(
                          isEditBio ? "Save" : "Edit",
                          style: const TextStyle(
                            color: Colors.lightGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
        
                    isEditBio
                        ? Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: InkWell(
                              onTap: () => setState(() => isEditBio = false),
                              child: Text(
                                "Cancel",
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                      
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      "Password Reset",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              TileTemplate(
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Password:",
                      style: TextStyle(
                        color: widget.isDarkMode
                            ? Colors.white70
                            : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 5,),
                    Text(
                      "**********",
                      style: TextStyle(color: Colors.blue, fontSize: 15),
                    ),
                  ],
                ),
                isDarkMode: widget.isDarkMode,
                trailingWidget: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage())),
                    child: Text(
                      "Reset Password",
                      style: const TextStyle(
                        color: Colors.lightGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
