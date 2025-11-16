import 'package:flutter/material.dart';
import 'package:voice_transscript/models/language_model.dart';

class LanguageButton extends StatelessWidget {
  final LanguageModel language;
  final VoidCallback? onTap;
  final bool isAutoDetected;

  const LanguageButton({
    required this.language,
    this.onTap,
    this.isAutoDetected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isAutoDetected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: isAutoDetected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isAutoDetected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAutoDetected)
              const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
            if (isAutoDetected) const SizedBox(width: 4),
            Text(language.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                language.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isAutoDetected ? FontWeight.w600 : FontWeight.normal,
                  color: isAutoDetected ? Colors.blue.shade700 : Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isAutoDetected) const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
