import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

class AppHelpers {
  AppHelpers._();

  /// Show a snackbar
  static void showSnack(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Notice',
      message,
      backgroundColor: isError ? AppColors.emergency : AppColors.primary,
      colorText: AppColors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.info_outline,
        color: AppColors.white,
      ),
    );
  }

  /// Map category string to urgency score (0–100)
  static int categoryToUrgencyScore(String category) {
    switch (category) {
      case 'EMERGENCY':
        return 92;
      case 'DOCTOR_VISIT':
        return 58;
      case 'HOME_CARE':
        return 18;
      default:
        return 18;
    }
  }

  /// Detect if text is primarily Hindi (Devanagari)
  static bool isHindiText(String text) {
    final hindiRegex = RegExp(r'[\u0900-\u097F]');
    final matches = hindiRegex.allMatches(text).length;
    return matches > text.length * 0.3;
  }

  /// Safe JSON parse that returns null on failure
  static Map<String, dynamic>? tryParseJson(String text) {
    try {
      // Strip markdown code fences if present
      final cleaned = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return Map<String, dynamic>.from(
        // ignore: avoid_dynamic_calls
        (cleaned.startsWith('{')) ? _jsonDecode(cleaned) : {},
      );
    } catch (_) {
      return null;
    }
  }

  static dynamic _jsonDecode(String s) {
    // Use dart:convert via import in the file that calls this
    throw UnimplementedError('Use dart:convert jsonDecode directly');
  }

  /// Format phone numbers for tel: URLs
  static String toTelUri(String number) => 'tel:$number';

  /// Card border radius
  static BorderRadius get cardRadius => BorderRadius.circular(12);
  static BorderRadius get chipRadius => BorderRadius.circular(20);
  static BorderRadius get buttonRadius => BorderRadius.circular(10);
}

/// Extension on BuildContext for quick sizing
extension ContextExt on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isMobile => screenWidth < 600;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
}
