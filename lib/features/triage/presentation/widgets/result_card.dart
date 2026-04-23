import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/triage_result_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings.dart';

class ResultCard extends StatelessWidget {
  final TriageResultModel result;
  final bool isHindi;

  const ResultCard({
    super.key,
    required this.result,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: result.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: result.borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge + Icon
          Row(
            children: [
              _CategoryBadge(result: result, isHindi: isHindi),
              const Spacer(),
              Icon(result.actionIcon, color: result.primaryColor, size: 28),
            ],
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            result.titleFor(isHindi),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: result.primaryColor,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Reason box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: result.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Next steps
          Text(
            isHindi ? AppStrings.nextStepsHi : AppStrings.nextSteps,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.06,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            result.nextSteps,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // Urgency meter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isHindi ? AppStrings.urgencyHi : AppStrings.urgency,
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.textMuted, letterSpacing: 0.06,
                    ),
                  ),
                  Text(
                    '${result.urgencyScore}/100',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: result.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: result.urgencyScore / 100,
                  minHeight: 6,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: AlwaysStoppedAnimation(result.primaryColor),
                ),
              ).animate().custom(
                duration: 1200.ms,
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (result.urgencyScore / 100) * value,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    valueColor: AlwaysStoppedAnimation(result.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 400.ms);
  }
}

class _CategoryBadge extends StatelessWidget {
  final TriageResultModel result;
  final bool isHindi;

  const _CategoryBadge({required this.result, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: result.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(result.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 6),
          Text(
            result.labelFor(isHindi),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
