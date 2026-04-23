import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/triage_controller.dart';
import '../widgets/result_card.dart';
import '../../data/models/triage_result_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/services/location_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TriageController>();

    return Scaffold(
      body: Obx(() {
        final result = controller.triageResult.value;
        if (result == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
          ),
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: ResultCard(
                      result: result,
                      isHindi: controller.isHindi,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _ResultBody(
                      result: result,
                      controller: controller,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: _OverlayTopBar(controller: controller),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─── Overlay top bar (floats over colored header) ──────────────────────────

class _OverlayTopBar extends StatelessWidget {
  final TriageController controller;
  const _OverlayTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Back',
            onTap: controller.reset,
          ),
          const Spacer(),
          _CircleIconButton(
            icon: Icons.volume_up_rounded,
            tooltip: 'Replay',
            onTap: controller.replayResult,
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: AppColors.white.withOpacity(0.22),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Icon(icon, color: AppColors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Result body ────────────────────────────────────────────────────────────

class _ResultBody extends StatelessWidget {
  final TriageResultModel result;
  final TriageController controller;

  const _ResultBody({required this.result, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Next-step label + copy
          Obx(() {
            final hi = controller.isHindi;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hi ? AppStrings.nextStepsHi : AppStrings.nextSteps,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  result.nextSteps,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        height: 1.4,
                      ),
                ),
              ],
            );
          }).animate(delay: 320.ms).fadeIn(duration: 280.ms).slideY(begin: 0.06),
          const SizedBox(height: 24),

          _PrimaryAction(result: result, controller: controller)
              .animate(delay: 400.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.08),

          const SizedBox(height: 12),

          _SecondaryActions(result: result, controller: controller),

          if (result.category == TriageCategory.homeCare &&
              result.homeCareTips.isNotEmpty) ...[
            const SizedBox(height: 28),
            _HomeCareTips(tips: result.homeCareTips, controller: controller)
                .animate(delay: 520.ms)
                .fadeIn(duration: 320.ms),
          ],

          if (result.category != TriageCategory.homeCare) ...[
            const SizedBox(height: 28),
            _NearbyFacilities(
              facilities: controller.getNearbyFacilities(),
              controller: controller,
            ).animate(delay: 520.ms).fadeIn(duration: 320.ms),
          ],

          const SizedBox(height: 32),

          Center(
            child: TextButton.icon(
              onPressed: controller.reset,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Obx(() => Text(
                    controller.isHindi
                        ? AppStrings.newAssessmentHi
                        : AppStrings.newAssessment,
                  )),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),
          Obx(() => Text(
                controller.isHindi
                    ? AppStrings.disclaimerHi
                    : AppStrings.disclaimer,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              )),
        ],
      ),
    );
  }
}

// ─── Primary action (hero CTA) ──────────────────────────────────────────────

class _PrimaryAction extends StatelessWidget {
  final TriageResultModel result;
  final TriageController controller;

  const _PrimaryAction({required this.result, required this.controller});

  @override
  Widget build(BuildContext context) {
    final hi = controller.isHindi;

    late final IconData icon;
    late final String title;
    late final String subtitle;
    late final VoidCallback onTap;
    late final Color color;

    switch (result.category) {
      case TriageCategory.emergency:
        icon = Icons.call_rounded;
        title = hi ? AppStrings.callAmbulanceHi : AppStrings.callAmbulance;
        subtitle = hi ? '108 — निःशुल्क एम्बुलेंस' : '108 — Free ambulance';
        onTap = controller.callAmbulance;
        color = AppColors.emergency;
        break;
      case TriageCategory.doctorVisit:
        icon = Icons.map_rounded;
        title = hi ? AppStrings.findNearbyPHCHi : AppStrings.findNearbyPHC;
        subtitle =
            hi ? 'प्राथमिक स्वास्थ्य केंद्र खोजें' : 'Find a Primary Health Centre';
        onTap = controller.openNearestPHC;
        color = AppColors.doctorVisit;
        break;
      case TriageCategory.homeCare:
        icon = Icons.headset_mic_rounded;
        title = hi ? AppStrings.healthHelplineHi : AppStrings.healthHelpline;
        subtitle = hi ? '104 — टेलीमेडिसिन' : '104 — Telemedicine';
        onTap = controller.callHealthHelpline;
        color = AppColors.homeCare;
        break;
    }

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded,
                  color: AppColors.white.withOpacity(0.9), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Secondary actions ──────────────────────────────────────────────────────

class _SecondaryActions extends StatelessWidget {
  final TriageResultModel result;
  final TriageController controller;

  const _SecondaryActions({required this.result, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;

      final tiles = <Widget>[];

      switch (result.category) {
        case TriageCategory.emergency:
          tiles.add(_SecondaryTile(
            icon: Icons.local_hospital_rounded,
            label: hi ? AppStrings.nearestHospitalHi : AppStrings.nearestHospital,
            subtitle: hi ? 'Google Maps पर खोलें' : 'Open in Google Maps',
            onTap: controller.openNearestHospital,
          ));
          break;
        case TriageCategory.doctorVisit:
          tiles.add(_SecondaryTile(
            icon: Icons.headset_mic_rounded,
            label: hi ? AppStrings.healthHelplineHi : AppStrings.healthHelpline,
            subtitle: hi ? '104 — टेलीमेडिसिन' : '104 — Telemedicine',
            onTap: controller.callHealthHelpline,
          ));
          break;
        case TriageCategory.homeCare:
          // No secondary tile; home-care primary is the helpline already.
          break;
      }

      if (tiles.isEmpty) return const SizedBox.shrink();

      return Column(
        children: tiles
            .map((t) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: t,
                ))
            .toList(),
      ).animate(delay: 480.ms).fadeIn(duration: 280.ms);
    });
  }
}

class _SecondaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SecondaryTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.borderStrong, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home care tips ─────────────────────────────────────────────────────────

class _HomeCareTips extends StatelessWidget {
  final List<String> tips;
  final TriageController controller;

  const _HomeCareTips({required this.tips, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  size: 18, color: AppColors.homeCare),
              const SizedBox(width: 8),
              Text(
                hi ? 'घर पर देखभाल' : 'Home care guide',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 7),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.homeCare,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      );
    });
  }
}

// ─── Nearby facilities ──────────────────────────────────────────────────────

class _NearbyFacilities extends StatelessWidget {
  final List<Map<String, String>> facilities;
  final TriageController controller;

  const _NearbyFacilities({
    required this.facilities,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (facilities.isEmpty) return const SizedBox.shrink();
    return Obx(() {
      final hi = controller.isHindi;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                hi ? 'नज़दीकी स्वास्थ्य केंद्र' : 'Nearby health centres',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...facilities.map((f) => _FacilityRow(facility: f)),
        ],
      );
    });
  }
}

class _FacilityRow extends StatelessWidget {
  final Map<String, String> facility;
  const _FacilityRow({required this.facility});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  facility['name'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  facility['distance'] ?? '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () =>
                  LocationService.callNumber(facility['phone'] ?? ''),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.call_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      facility['phone'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
