import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';

/// The hero voice-input affordance.
///
/// Shows a slow idle pulse when waiting for the user (attention hint), and
/// a louder breath + sound-level response when recording.
class MicButton extends StatelessWidget {
  final bool isRecording;
  final double soundLevel; // 0..10 from the speech engine
  final VoidCallback onTap;
  final double size;
  final bool showIdlePulse;

  const MicButton({
    super.key,
    required this.isRecording,
    required this.soundLevel,
    required this.onTap,
    this.size = 120,
    this.showIdlePulse = true,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = (soundLevel.clamp(0.0, 10.0)) / 10.0;
    final breathScale = isRecording ? 1.0 + normalized * 0.25 : 1.0;
    final fill = isRecording ? AppColors.emergency : AppColors.primary;

    final halo = size * 1.9;

    return Semantics(
      button: true,
      label: isRecording ? 'Stop recording' : 'Start recording',
      child: SizedBox(
        width: halo,
        height: halo,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Idle attention pulse
            if (!isRecording && showIdlePulse)
              Container(
                width: size * 1.7,
                height: size * 1.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill.withOpacity(0.08),
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scaleXY(
                    begin: 0.7,
                    end: 1.05,
                    duration: 1800.ms,
                    curve: Curves.easeOut,
                  )
                  .fadeOut(duration: 1800.ms, curve: Curves.easeOut),

            // Static halo ring (always visible, soft)
            Container(
              width: size * 1.35,
              height: size * 1.35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fill.withOpacity(isRecording ? 0.16 : 0.10),
              ),
            ),

            // Breathing halo — only when recording
            if (isRecording)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: size * (1.35 + normalized * 0.18),
                height: size * (1.35 + normalized * 0.18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: fill.withOpacity(0.22),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(
                    begin: 0.96,
                    end: 1.08,
                    duration: 1300.ms,
                    curve: Curves.easeInOut,
                  ),

            // Core button
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: size * breathScale,
                height: size * breathScale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isRecording
                        ? [AppColors.emergency, AppColors.emergencyDeep]
                        : [AppColors.accent, AppColors.primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: fill.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: AppColors.white,
                  size: size * 0.44,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
