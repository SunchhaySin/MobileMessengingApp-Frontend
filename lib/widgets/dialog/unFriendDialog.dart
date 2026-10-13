import 'package:flutter/material.dart';

class UnFriendDialog {
  final String friendUsername;
  final String friendId;
  final void Function(String) onConfirm;

  const UnFriendDialog({
    required this.friendUsername,
    required this.friendId,
    required this.onConfirm,
  });

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1E1E2E),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Are you sure you want to unfriend, $friendUsername ?", style: TextStyle(color: Colors.white, fontSize: 18),),
                const SizedBox(height: 6),
                Text("This current chat will be moved into archived folder", style: TextStyle(color: Colors.white70, fontSize: 13),),

                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Confirm',
                        icon: Icons.check_circle,
                        color: Colors.green,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onConfirm(friendId);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionButton(
                        label: 'Cancel',
                        icon: Icons.close,
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
    return SizedBox(
      width: double.infinity,
      child: TextButton(
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
      ),
    );
  }
}
