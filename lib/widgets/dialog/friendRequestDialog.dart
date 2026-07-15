import 'package:flutter/material.dart';

class FriendRequestDialog {
  final String requestId;
  final String username;
  final bool isReceived;
  final String? profileUrl;
  final void Function(String) onAccept;
  final void Function(String) onReject;
  final void Function(String) onRemove;

  const FriendRequestDialog({
    required this.requestId,
    required this.username,
    required this.isReceived,
    required this.onAccept,
    required this.onReject,
    required this.onRemove,
    this.profileUrl
  });

  void openDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
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
                // Header
                Row(
                  children: [
                    profileUrl != null
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(profileUrl!),
                          )
                        : CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.blueGrey,
                            child: Text(
                              username.isNotEmpty
                                  ? username[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          isReceived ? 'Sent you a friend request' : 'Friend request sent',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: Colors.white12),
                const SizedBox(height: 16),

                // Action buttons
                if (isReceived) ...[
                  _ActionButton(
                    label: 'Accept',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onAccept(requestId);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Reject',
                    icon: Icons.cancel_outlined,
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onReject(requestId);
                    },
                  ),
                  const SizedBox(height: 10),
                  _ActionButton(
                    label: 'Remove',
                    icon: Icons.delete_outline,
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRemove(requestId);
                    },
                  ),
                ] else ...[
                  _ActionButton(
                    label: 'Remove',
                    icon: Icons.delete_outline,
                    color: Colors.redAccent,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onRemove(requestId);
                    },
                  ),
                ],

                const SizedBox(height: 10),
                _ActionButton(
                  label: 'Cancel',
                  icon: Icons.close,
                  color: Colors.white38,
                  onPressed: () => Navigator.of(context).pop(),
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
            Text(
              label,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}