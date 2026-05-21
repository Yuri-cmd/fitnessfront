import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fit_tracker_app/core/theme/app_colors.dart';

class StreakBottomActions extends StatelessWidget {
  final GlobalKey shareKey;
  final VoidCallback onShare;
  final String userName;

  const StreakBottomActions({
    super.key,
    required this.shareKey,
    required this.onShare,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Row(
        children: [
          GestureDetector(
            onTap: onShare,
            child: Container(
              key: shareKey,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: onSurface.withValues(alpha: 0.1)),
              ),
              child: Icon(Icons.ios_share,
                  color: onSurface.withValues(alpha: 0.6), size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: Get.back,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  '¡VAMOS, ${userName.split(' ').first.toUpperCase()}!',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
