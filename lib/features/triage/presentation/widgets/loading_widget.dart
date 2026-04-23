import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';

/// Inline loader — three quietly-pulsing dots, no bordered box.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? accent;

  const LoadingWidget({super.key, this.message, this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDots(color: color),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _PulsingDots extends StatelessWidget {
  final Color color;
  const _PulsingDots({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: i == 1 ? 5 : 0)
              .add(const EdgeInsets.symmetric(horizontal: 3)),
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(
              delay: Duration(milliseconds: i * 140),
              duration: 500.ms,
              begin: 0.25,
            )
            .scaleXY(
              begin: 0.7,
              end: 1.0,
              duration: 500.ms,
              curve: Curves.easeOut,
            );
      }),
    );
  }
}

/// Full-screen overlay — used during classification where the user must wait.
///
/// Dignified: solid paper-colored wash with a single centered group.
class FullScreenLoader extends StatelessWidget {
  final String message;

  const FullScreenLoader({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: ColoredBox(
          color: AppColors.background.withOpacity(0.92),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulsingDots(color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ).animate().fadeIn(duration: 260.ms),
            ),
          ),
        ),
      ),
    );
  }
}
