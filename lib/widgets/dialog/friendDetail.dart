import 'package:flutter/material.dart';
import 'package:frontend/utils/profileName.dart';
import 'package:frontend/widgets/dialog/viewProfile.dart';

class FriendDetailDialog {
  final Map<String, dynamic> friendProfile;
  final Future<void> Function(
    BuildContext dialogContext,
    String,
    String,
    String?,
  )
  onChat;
  final void Function(String) onUnfriend;
  final bool isDarkMode;
  final ValueNotifier<bool> isLoadingOnChat;

  const FriendDetailDialog({
    required this.friendProfile,
    required this.onChat,
    required this.isDarkMode,
    required this.onUnfriend,
    required this.isLoadingOnChat,
  });

  String get profileName => ProfileName.getInitials(friendProfile['username']);
  DateTime get createdAt => DateTime.parse(friendProfile['createdAt']);

  String getTimeSuffix(String isoTime) {
    final dateTime = DateTime.parse(isoTime).toLocal();
    final hour = dateTime.hour;
    return hour >= 12 ? "PM" : "AM";
  }

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final profileImage = friendProfile['profile']?['profileUrl'];
        final friendBio = friendProfile['profile']?['bio'];
        final friendContacts = friendProfile['profile']?['contacts'];

        final hasBio = friendBio != null && friendBio != "";
        final hasContact = friendContacts != null && friendContacts != "";

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1E1E2E),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Viewprofile(
                    profileUrl: profileImage ?? "",
                    isDarkMode: isDarkMode,
                  ).openDialog(context),
                  child: profileImage != null
                      ? CircleAvatar(
                          radius: 22,
                          backgroundImage: NetworkImage(profileImage),
                        )
                      : CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            profileName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 6),
                Text(
                  friendProfile['username'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const Divider(color: Colors.white12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      "Friend Since: ",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "${createdAt.day}/${createdAt.month}/${createdAt.year} - ${createdAt.hour}:${createdAt.minute} ${getTimeSuffix(friendProfile['createdAt'])}",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.contact_phone, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text("Contacts: ", style: TextStyle(color: Colors.white)),
                    Text(
                      friendContacts ?? "No Contacts Yet",
                      style: TextStyle(
                        color: hasContact ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text("Bio: ", style: TextStyle(color: Colors.white)),
                    Text(
                      friendBio ?? "No Bio Yet",
                      style: TextStyle(
                        color: hasBio ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLoadingOnChat,
                        builder: (_, loading, __) {
                          return _ActionButton(
                            label: loading ? 'Opening' : 'Chat',
                            iconWidget: loading
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.lightGreenAccent,
                                      color: Colors.black,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : Icon(
                                    Icons.chat_bubble,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                            color: Colors.green,
                            onPressed: () async {
                              await onChat(
                                context,
                                friendProfile['id'],
                                profileName,
                                profileImage,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Unfriend',
                        iconWidget: Icon(
                          Icons.person_off_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        // icon: Icons.person_off_rounded,
                        color: Colors.redAccent,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onUnfriend(friendProfile['id']);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.iconWidget,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
