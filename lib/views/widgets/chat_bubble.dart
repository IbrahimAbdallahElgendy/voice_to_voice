import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isLive,
  });

  final String text;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Check if text contains Arabic characters
    final bool isArabic = text.contains(RegExp(r'[\u0600-\u06FF]'));
    
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isLive
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          isLive ? '$text …' : text,
          style: theme.textTheme.bodyLarge,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
      ),
    );
  }
}

