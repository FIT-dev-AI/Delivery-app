import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    primaryOrange.withValues(alpha: 0.2),
                    secondaryOrange.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: 64,
                color: primaryOrange,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: textLight,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button (nếu có)
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
