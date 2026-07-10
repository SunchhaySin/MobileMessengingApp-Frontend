import 'package:flutter/material.dart';

class TileTemplate extends StatelessWidget {
  final Widget? trailingWidget;
  final Widget? leadingWidget;

  final Widget title;

  final String? subtitle;
  final Color? subtitleColor;

  final bool isDarkMode;
  final VoidCallback? ontap;

  const TileTemplate({
    super.key,
    this.trailingWidget,
    this.leadingWidget,

    required this.title,
    this.subtitle,
    this.subtitleColor,

    required this.isDarkMode,
    this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 55,
        child: Row(
          children: [
            if (leadingWidget != null) ...[
              leadingWidget!,
              const SizedBox(width: 12),
            ],

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  title,

                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            if (trailingWidget != null) trailingWidget!,
          ],
        ),
      ),
    );
  }
}