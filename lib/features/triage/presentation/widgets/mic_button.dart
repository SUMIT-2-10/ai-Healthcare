import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';

class MicButton extends StatelessWidget {
  final bool isRecording;
  final double soundLevel;
  final VoidCallback onTap;
  final double size;

  const MicButton({
    super.key,
    required this.isRecording,
    required this.soundLevel,
    required this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final ringScale = isRecording ? 1.0 + (soundLevel.clamp(0.0, 10.0) / 40.0) : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulse ring (only when recording)
          if (isRecording)
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: size * ringScale + 28,
              height: size * ringScale + 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergency.withOpacity(0.12),
              ),
            ).animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05),
                    duration: 900.ms, curve: Curves.easeInOut)
                .then()
                .scale(begin: const Offset(1.05, 1.05), end: const Offset(0.95, 0.95),
                    duration: 900.ms, curve: Curves.easeInOut),

          // Middle ring (only when recording)
          if (isRecording)
            Container(
              width: size + 16,
              height: size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.emergency.withOpacity(0.18),
              ),
            ),

          // Main button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRecording ? AppColors.emergency : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: (isRecording ? AppColors.emergency : AppColors.primary)
                      .withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: AppColors.white,
              size: size * 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
