import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/triage_result_model.dart';
import '../../../../core/constants/app_colors.dart';

/// Full-bleed category hero.
///
/// This is THE result. No sub-cards, no borders, no urgency progress bars.
/// The color of the hero IS the triage verdict.
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
    final bg = _deepColor(result.category);

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: bg),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryBadge(result: result, isHindi: isHindi)
                  .animate()
                  .fadeIn(duration: 240.ms)
                  .slideY(begin: -0.1),
              const SizedBox(height: 24),
              Text(
                result.titleFor(isHindi),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
              )
                  .animate(delay: 80.ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.06),
              const SizedBox(height: 16),
              Text(
                result.reason,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white.withOpacity(0.88),
                  height: 1.55,
                  fontWeight: FontWeight.w400,
                ),
              )
                  .animate(delay: 160.ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.06),
              const SizedBox(height: 20),
              _UrgencyRow(result: result, isHindi: isHindi)
                  .animate(delay: 240.ms)
                  .fadeIn(duration: 260.ms),
            ],
          ),
        ),
      ),
    );
  }

  static Color _deepColor(TriageCategory c) {
    switch (c) {
      case TriageCategory.emergency:
        return AppColors.emergencyDeep;
      case TriageCategory.doctorVisit:
        return AppColors.doctorVisitDeep;
      case TriageCategory.homeCare:
        return AppColors.homeCareDeep;
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final TriageResultModel result;
  final bool isHindi;
  const _CategoryBadge({required this.result, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(result.actionIcon, color: AppColors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            result.labelFor(isHindi).toUpperCase(),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgencyRow extends StatelessWidget {
  final TriageResultModel result;
  final bool isHindi;
  const _UrgencyRow({required this.result, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    final score = result.urgencyScore;
    final level = _urgencyLevel(score, isHindi);
    return Row(
      children: [
        _UrgencyDots(score: score),
        const SizedBox(width: 10),
        Text(
          level,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: AppColors.white.withOpacity(0.95),
          ),
        ),
        const Spacer(),
        Text(
          '$score/100',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.white.withOpacity(0.7),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  String _urgencyLevel(int score, bool hi) {
    if (score >= 80) return hi ? 'बहुत तीव्र' : 'CRITICAL';
    if (score >= 60) return hi ? 'तीव्र' : 'HIGH';
    if (score >= 35) return hi ? 'मध्यम' : 'MODERATE';
    return hi ? 'कम' : 'LOW';
  }
}

class _UrgencyDots extends StatelessWidget {
  final int score;
  const _UrgencyDots({required this.score});

  @override
  Widget build(BuildContext context) {
    final filled = (score / 20).ceil().clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final isOn = i < filled;
        return Container(
          width: 8,
          height: 8,
          margin: EdgeInsets.only(right: i == 4 ? 0 : 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOn
                ? AppColors.white
                : AppColors.white.withOpacity(0.28),
          ),
        );
      }),
    );
  }
}
