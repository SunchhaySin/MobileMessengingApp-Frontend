import 'package:flutter/material.dart';
import 'package:frontend/utils/profileName.dart';

class FriendDetailDialog {
  final Map<String, dynamic> friendProfile;
  final void Function(String) onChat;

  const FriendDetailDialog({required this.friendProfile, required this.onChat});

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
                profileImage != null
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
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Chat',
                        icon: Icons.chat_bubble,
                        color: Colors.green,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onChat(friendProfile['id']);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Close',
                        icon: Icons.cancel_outlined,
                        color: Colors.redAccent,
                        onPressed: () {
                          Navigator.of(context).pop();
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
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
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
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
