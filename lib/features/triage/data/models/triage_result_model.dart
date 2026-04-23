import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings.dart';

enum TriageCategory { emergency, doctorVisit, homeCare }

class TriageResultModel {
  final String id;
  final TriageCategory category;
  final String reason;
  final String nextSteps;
  final int urgencyScore;
  final List<String> homeCareTips;
  final DateTime createdAt;

  TriageResultModel({
    String? id,
    required this.category,
    required this.reason,
    required this.nextSteps,
    required this.urgencyScore,
    this.homeCareTips = const [],
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // ─── UI helpers ─────────────────────────────────────────────────────────────

  Color get primaryColor {
    switch (category) {
      case TriageCategory.emergency:
        return AppColors.emergency;
      case TriageCategory.doctorVisit:
        return AppColors.doctorVisit;
      case TriageCategory.homeCare:
        return AppColors.homeCare;
    }
  }

  Color get backgroundColor {
    switch (category) {
      case TriageCategory.emergency:
        return AppColors.emergencyLight;
      case TriageCategory.doctorVisit:
        return AppColors.doctorVisitLight;
      case TriageCategory.homeCare:
        return AppColors.homeCareLight;
    }
  }

  Color get borderColor {
    switch (category) {
      case TriageCategory.emergency:
        return AppColors.emergencyDeep;
      case TriageCategory.doctorVisit:
        return AppColors.doctorVisitDeep;
      case TriageCategory.homeCare:
        return AppColors.homeCareDeep;
    }
  }

  String get emoji {
    switch (category) {
      case TriageCategory.emergency:
        return '🔴';
      case TriageCategory.doctorVisit:
        return '🟡';
      case TriageCategory.homeCare:
        return '🟢';
    }
  }

  String labelFor(bool isHindi) {
    switch (category) {
      case TriageCategory.emergency:
        return isHindi ? AppStrings.emergencyLabelHi : AppStrings.emergencyLabel;
      case TriageCategory.doctorVisit:
        return isHindi ? AppStrings.doctorLabelHi : AppStrings.doctorLabel;
      case TriageCategory.homeCare:
        return isHindi ? AppStrings.homeLabelHi : AppStrings.homeLabel;
    }
  }

  String titleFor(bool isHindi) {
    switch (category) {
      case TriageCategory.emergency:
        return isHindi ? AppStrings.emergencyTitleHi : AppStrings.emergencyTitle;
      case TriageCategory.doctorVisit:
        return isHindi ? AppStrings.doctorTitleHi : AppStrings.doctorTitle;
      case TriageCategory.homeCare:
        return isHindi ? AppStrings.homeTitleHi : AppStrings.homeTitle;
    }
  }

  IconData get actionIcon {
    switch (category) {
      case TriageCategory.emergency:
        return Icons.local_hospital_rounded;
      case TriageCategory.doctorVisit:
        return Icons.medical_services_rounded;
      case TriageCategory.homeCare:
        return Icons.home_rounded;
    }
  }

  // ─── Factory constructors ──────────────────────────────────────────────────

  factory TriageResultModel.fromMap(Map<String, dynamic> map) {
    final categoryStr = map['category'] as String? ?? 'HOME_CARE';
    final category = _parseCategory(categoryStr);
    final rawTips = map['home_care_tips'];
    final tips = rawTips is List
        ? rawTips.map((e) => e.toString()).toList()
        : <String>[];

    return TriageResultModel(
      category: category,
      reason: map['reason'] as String? ?? '',
      nextSteps: map['next_steps'] as String? ?? '',
      urgencyScore: (map['urgency_score'] as num?)?.toInt() ?? 20,
      homeCareTips: tips,
    );
  }

  static TriageCategory _parseCategory(String s) {
    switch (s.toUpperCase()) {
      case 'EMERGENCY':
        return TriageCategory.emergency;
      case 'DOCTOR_VISIT':
        return TriageCategory.doctorVisit;
      default:
        return TriageCategory.homeCare;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category.name,
        'reason': reason,
        'next_steps': nextSteps,
        'urgency_score': urgencyScore,
        'home_care_tips': homeCareTips,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  String toString() =>
      'TriageResultModel(category: $category, score: $urgencyScore)';
}
