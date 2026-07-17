import 'package:flutter/material.dart';

class ProfileHistoryWidget extends StatelessWidget {
  final String message;
  final String timeStamp;
  final bool isDarkMode;
  const ProfileHistoryWidget({
    super.key,
    required this.message,
    required this.timeStamp,
    required this.isDarkMode,
  });

  IconData getIcon(String message) {
    return switch (message) {
      String msg when msg.contains('contacts') => Icons.phone,
      String msg when msg.contains('username') => Icons.person,
      String msg when msg.contains('Bio') => Icons.south_america_sharp,
      _ => Icons.circle_notifications,
    };
  }

  String formatTimestamp(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw; // fallback if parsing fails

    final local = date.toLocal();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final month = months[local.month - 1];
    final day = local.day;
    final year = local.year;

    final hour24 = local.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';

    return '$month $day, $year · $hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white24,
        width: 2,
          )
        )
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              getIcon(message),
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatTimestamp(timeStamp),
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}