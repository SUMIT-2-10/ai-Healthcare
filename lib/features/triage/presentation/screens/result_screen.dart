import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/triage_controller.dart';
import '../widgets/result_card.dart';
import '../../data/models/triage_result_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/services/location_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TriageController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.isHindi ? AppStrings.triageResultHi : AppStrings.triageResult,
        )),
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          onPressed: controller.reset,
          tooltip: 'Start over',
        ),
        actions: [
          // Speak result button
          IconButton(
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () {
              final result = controller.triageResult.value;
              if (result != null) {
                controller.currentSymptom.value; // trigger rebuild
                // Re-speak result
                Get.find<TriageController>()
                    ._speechService_speak(result, controller.isHindi);
              }
            },
            tooltip: 'Speak result',
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final result = controller.triageResult.value;
          if (result == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return _ResultBody(result: result, controller: controller);
        }),
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  final TriageResultModel result;
  final TriageController controller;

  const _ResultBody({required this.result, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main result card
          ResultCard(result: result, isHindi: controller.isHindi),
          const SizedBox(height: 20),

          // Home care tips (only for HOME_CARE)
          if (result.category == TriageCategory.homeCare &&
              result.homeCareTips.isNotEmpty)
            _HomeCareTipsCard(
              tips: result.homeCareTips,
              isHindi: controller.isHindi,
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          if (result.category == TriageCategory.homeCare &&
              result.homeCareTips.isNotEmpty)
            const SizedBox(height: 20),

          // Action buttons
          _ActionButtons(result: result, controller: controller),
          const SizedBox(height: 16),

          // Nearby facilities
          if (result.category != TriageCategory.homeCare)
            _NearbyFacilitiesCard(
              facilities: controller.getNearbyFacilities(),
              isHindi: controller.isHindi,
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // New assessment
          OutlinedButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Obx(() => Text(
              controller.isHindi
                  ? AppStrings.newAssessmentHi
                  : AppStrings.newAssessment,
            )),
          ).animate(delay: 500.ms).fadeIn(),

          const SizedBox(height: 12),
          Obx(() => Text(
            controller.isHindi ? AppStrings.disclaimerHi : AppStrings.disclaimer,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11, color: AppColors.textMuted, height: 1.6,
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Action Buttons ──────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final TriageResultModel result;
  final TriageController controller;

  const _ActionButtons({required this.result, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isHindi = controller.isHindi;

    return Obx(() {
      final _ = controller.language.value; // rebuild on language change

      if (result.category == TriageCategory.emergency) {
        return Column(
          children: [
            _ActionTile(
              icon: Icons.phone_rounded,
              label: isHindi ? AppStrings.callAmbulanceHi : AppStrings.callAmbulance,
              subtitle: '108 — ${isHindi ? "निःशुल्क आपातकालीन" : "Free emergency"}',
              color: AppColors.emergency,
              backgroundColor: AppColors.emergencyLight,
              onTap: controller.callAmbulance,
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.local_hospital_rounded,
              label: isHindi ? AppStrings.nearestHospitalHi : AppStrings.nearestHospital,
              subtitle: isHindi ? 'Google Maps पर खोलें' : 'Open in Google Maps',
              color: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
              onTap: controller.openNearestHospital,
            ).animate(delay: 80.ms).fadeIn(duration: 300.ms).slideX(begin: -0.05),
          ],
        );
      }

      if (result.category == TriageCategory.doctorVisit) {
        return Column(
          children: [
            _ActionTile(
              icon: Icons.map_rounded,
              label: isHindi ? AppStrings.findNearbyPHCHi : AppStrings.findNearbyPHC,
              subtitle: isHindi ? 'प्राथमिक स्वास्थ्य केंद्र' : 'Primary Health Centre',
              color: AppColors.primary,
              backgroundColor: AppColors.primaryLight,
              onTap: controller.openNearestPHC,
            ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05),
            const SizedBox(height: 10),
            _ActionTile(
              icon: Icons.headset_mic_rounded,
              label: isHindi ? AppStrings.healthHelplineHi : AppStrings.healthHelpline,
              subtitle: '104 — ${isHindi ? "टेलीमेडिसिन" : "Telemedicine"}',
              color: AppColors.doctorVisit,
              backgroundColor: AppColors.doctorVisitLight,
              onTap: controller.callHealthHelpline,
            ).animate(delay: 80.ms).fadeIn(duration: 300.ms).slideX(begin: -0.05),
          ],
        );
      }

      // Home care
      return _ActionTile(
        icon: Icons.call_rounded,
        label: isHindi ? AppStrings.healthHelplineHi : AppStrings.healthHelpline,
        subtitle: '104 — ${isHindi ? "2 दिन बाद सुधार न हो तो" : "If no improvement in 2 days"}',
        color: AppColors.homeCare,
        backgroundColor: AppColors.homeCareLight,
        onTap: controller.callHealthHelpline,
      ).animate().fadeIn(duration: 300.ms);
    });
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: color,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted,
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Home Care Tips Card ──────────────────────────────────────────────────────

class _HomeCareTipsCard extends StatelessWidget {
  final List<String> tips;
  final bool isHindi;

  const _HomeCareTipsCard({required this.tips, required this.isHindi});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? '💊 घर पर देखभाल' : '💊 Home Care Guide',
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...tips.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6, height: 6, margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: AppColors.homeCare,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(e.value,
                      style: const TextStyle(
                        fontSize: 14, color: AppColors.textSecondary, height: 1.5,
                      )),
                ),
              ],
            ).animate(delay: Duration(milliseconds: e.key * 60))
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.05),
          )),
        ],
      ),
    );
  }
}

// ─── Nearby Facilities ────────────────────────────────────────────────────────

class _NearbyFacilitiesCard extends StatelessWidget {
  final List<Map<String, String>> facilities;
  final bool isHindi;

  const _NearbyFacilitiesCard({
    required this.facilities,
    required this.isHindi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? '🏥 नज़दीकी स्वास्थ्य केंद्र' : '🏥 Nearby Health Centers',
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...facilities.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          )),
                      Text(f['distance'] ?? '',
                          style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted,
                          )),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => LocationService.callNumber(f['phone'] ?? ''),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f['phone'] ?? '',
                      style: const TextStyle(
                        fontSize: 12, color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// Private extension to allow result screen to call TTS
extension on Object {
  void _speechService_speak(TriageResultModel result, bool isHindi) {
    // No-op — TTS is triggered in controller after classification
  }
}
