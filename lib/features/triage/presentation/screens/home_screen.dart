import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/triage_controller.dart';
import '../widgets/mic_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = Get.find<TriageController>();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showTypeInput = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.trim().isNotEmpty
        ? _textController.text.trim()
        : _controller.liveTranscript.value.trim();
    _controller.submitSymptoms(text);
  }

  void _toggleTypeInput() {
    setState(() => _showTypeInput = !_showTypeInput);
    if (_showTypeInput) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _TopBar(controller: _controller)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _VaidyaGreeting(controller: _controller)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.08),
                    const SizedBox(height: 24),
                    _HeroHeading(controller: _controller)
                        .animate(delay: 80.ms)
                        .fadeIn(duration: 340.ms)
                        .slideY(begin: 0.06),
                    const SizedBox(height: 24),
                    _MicCard(
                      controller: _controller,
                      onOpenType: () {
                        if (!_showTypeInput) _toggleTypeInput();
                      },
                    )
                        .animate(delay: 160.ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(begin: 0.06),
                    _TranscriptPreview(controller: _controller),
                    _ErrorBanner(controller: _controller),
                    if (_showTypeInput) ...[
                      const SizedBox(height: 16),
                      _TypeInput(
                        controller: _controller,
                        textController: _textController,
                        focusNode: _focusNode,
                        onSend: _handleSend,
                      ),
                    ],
                    const SizedBox(height: 28),
                    _CommonSymptoms(
                      controller: _controller,
                      textController: _textController,
                      onOpenType: () {
                        if (!_showTypeInput) _toggleTypeInput();
                      },
                    ),
                    const SizedBox(height: 24),
                    _TrustStrip(controller: _controller),
                    const SizedBox(height: 20),
                    _EmergencyCta(controller: _controller),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar: brand + language ─────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final TriageController controller;
  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          // Brand mark with gradient
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              final hi = controller.isHindi;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Swasthya AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                  ),
                  Text(
                    hi ? 'स्वास्थ्य सहायक' : 'Your health companion',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }),
          ),
          _LanguagePill(controller: controller),
        ],
      ),
    );
  }
}

class _LanguagePill extends StatelessWidget {
  final TriageController controller;
  const _LanguagePill({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isHi = controller.isHindi;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: controller.toggleLanguage,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.language_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  isHi ? 'हिन्दी' : 'English',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Virtual Vaidya greeting strip ─────────────────────────────────────────

class _VaidyaGreeting extends StatelessWidget {
  final TriageController controller;
  const _VaidyaGreeting({required this.controller});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    return Obx(() {
      final hi = controller.isHindi;
      final greetingEn = hour < 12
          ? 'Good morning'
          : hour < 17
              ? 'Good afternoon'
              : 'Good evening';
      final greetingHi = hour < 12
          ? 'सुप्रभात'
          : hour < 17
              ? 'नमस्ते'
              : 'शुभ संध्या';
      final greeting = hi ? greetingHi : greetingEn;
      final line2 = hi
          ? 'मैं वर्चुअल वैद्य हूँ — यहाँ आपकी मदद के लिए'
          : 'I\'m Virtual Vaidya — here to help you';

      return Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primarySoft, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            const _VaidyaAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    line2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _VaidyaAvatar extends StatelessWidget {
  const _VaidyaAvatar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, AppColors.primaryDark],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.medical_services_rounded,
              color: AppColors.white, size: 22),
        ),
        Positioned(
          right: -1,
          bottom: -1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Hero heading ──────────────────────────────────────────────────────────

class _HeroHeading extends StatelessWidget {
  final TriageController controller;
  const _HeroHeading({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;
      final title = hi
          ? 'आप कैसा\nमहसूस कर रहे हैं?'
          : 'How are you\nfeeling today?';
      final sub = hi
          ? 'अपने लक्षण बताएं — हम सही देखभाल तक पहुँचाएँगे।'
          : 'Tell us your symptoms — we\'ll guide you to the right care.';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 34,
                  height: 1.12,
                  letterSpacing: -0.9,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            sub,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      );
    });
  }
}

// ─── Mic card ──────────────────────────────────────────────────────────────

class _MicCard extends StatelessWidget {
  final TriageController controller;
  final VoidCallback onOpenType;

  const _MicCard({required this.controller, required this.onOpenType});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRec = controller.isRecording.value;
      final hi = controller.isHindi;
      final stateLabel = isRec
          ? (hi ? AppStrings.listeningHi : AppStrings.listening)
          : (hi ? AppStrings.tapToSpeakHi : AppStrings.tapToSpeak);

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.primarySoft],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            MicButton(
              isRecording: isRec,
              soundLevel: controller.soundLevel.value,
              size: 104,
              onTap: () {
                if (isRec) {
                  controller.stopRecording();
                } else {
                  controller.startRecording();
                }
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                stateLabel,
                key: ValueKey(stateLabel),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isRec
                          ? AppColors.emergency
                          : AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hi
                  ? 'अपनी भाषा में बोलें'
                  : 'Speak in your language',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: onOpenType,
              icon: const Icon(Icons.keyboard_alt_outlined, size: 18),
              label: Text(
                hi ? 'टाइप करके लिखें' : 'Or type your symptoms',
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.trust,
                minimumSize: const Size(double.infinity, 44),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Transcript preview ────────────────────────────────────────────────────

class _TranscriptPreview extends StatelessWidget {
  final TriageController controller;
  const _TranscriptPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.liveTranscript.value;
      if (t.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.trustLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.trust.withOpacity(0.18)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.graphic_eq_rounded,
                  size: 20, color: AppColors.trust),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.trustDark,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              _SendArrow(onTap: () => controller.submitSymptoms(t)),
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.08),
      );
    });
  }
}

class _SendArrow extends StatelessWidget {
  final VoidCallback onTap;
  const _SendArrow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(Icons.arrow_forward_rounded,
              color: AppColors.white, size: 20),
        ),
      ),
    );
  }
}

// ─── Error banner ──────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final TriageController controller;
  const _ErrorBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final err = controller.errorMessage.value;
      if (err.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.emergencyLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 18, color: AppColors.emergency),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  err,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.emergencyDeep,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 180.ms),
      );
    });
  }
}

// ─── Type input ─────────────────────────────────────────────────────────────

class _TypeInput extends StatelessWidget {
  final TriageController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _TypeInput({
    required this.controller,
    required this.textController,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: hi ? AppStrings.inputHintHi : AppStrings.inputHint,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: Text(hi ? AppStrings.sendButtonHi : AppStrings.sendButton),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06);
    });
  }
}

// ─── Common symptoms chips ─────────────────────────────────────────────────

class _CommonSymptoms extends StatelessWidget {
  final TriageController controller;
  final TextEditingController textController;
  final VoidCallback onOpenType;

  const _CommonSymptoms({
    required this.controller,
    required this.textController,
    required this.onOpenType,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;
      final chips = hi ? _chipsHi : _chipsEn;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              hi ? 'आम लक्षण' : 'Common symptoms',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips.map((c) {
              return _SymptomChip(
                icon: c.icon,
                label: c.label,
                bg: c.bg,
                fg: c.fg,
                onTap: () {
                  textController.text = c.prefillFor(hi);
                  onOpenType();
                },
              );
            }).toList(),
          ),
        ],
      );
    });
  }
}

class _ChipSpec {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final String prefillEn;
  final String prefillHi;
  const _ChipSpec(
    this.icon,
    this.label,
    this.bg,
    this.fg,
    this.prefillEn,
    this.prefillHi,
  );

  String prefillFor(bool hi) => hi ? prefillHi : prefillEn;
}

const _chipsEn = <_ChipSpec>[
  _ChipSpec(
    Icons.thermostat_rounded,
    'Fever',
    AppColors.chipFeverBg,
    AppColors.chipFeverFg,
    'Fever and headache',
    'बुखार और सिरदर्द',
  ),
  _ChipSpec(
    Icons.favorite_rounded,
    'Chest pain',
    AppColors.chipHeartBg,
    AppColors.chipHeartFg,
    'Chest pain',
    'सीने में दर्द',
  ),
  _ChipSpec(
    Icons.child_care_rounded,
    'Child ill',
    AppColors.chipChildBg,
    AppColors.chipChildFg,
    'Child with diarrhea',
    'बच्चे को दस्त',
  ),
  _ChipSpec(
    Icons.blur_on_rounded,
    'Dizziness',
    AppColors.chipHeadBg,
    AppColors.chipHeadFg,
    'Dizziness',
    'चक्कर आना',
  ),
  _ChipSpec(
    Icons.healing_rounded,
    'Stomach',
    AppColors.chipStomachBg,
    AppColors.chipStomachFg,
    'Stomach pain',
    'पेट में दर्द',
  ),
];

const _chipsHi = <_ChipSpec>[
  _ChipSpec(
    Icons.thermostat_rounded,
    'बुखार',
    AppColors.chipFeverBg,
    AppColors.chipFeverFg,
    'Fever and headache',
    'बुखार और सिरदर्द',
  ),
  _ChipSpec(
    Icons.favorite_rounded,
    'सीने में दर्द',
    AppColors.chipHeartBg,
    AppColors.chipHeartFg,
    'Chest pain',
    'सीने में दर्द',
  ),
  _ChipSpec(
    Icons.child_care_rounded,
    'बच्चा बीमार',
    AppColors.chipChildBg,
    AppColors.chipChildFg,
    'Child with diarrhea',
    'बच्चे को दस्त',
  ),
  _ChipSpec(
    Icons.blur_on_rounded,
    'चक्कर',
    AppColors.chipHeadBg,
    AppColors.chipHeadFg,
    'Dizziness',
    'चक्कर आना',
  ),
  _ChipSpec(
    Icons.healing_rounded,
    'पेट दर्द',
    AppColors.chipStomachBg,
    AppColors.chipStomachFg,
    'Stomach pain',
    'पेट में दर्द',
  ),
];

class _SymptomChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const _SymptomChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: fg, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Trust strip ───────────────────────────────────────────────────────────

class _TrustStrip extends StatelessWidget {
  final TriageController controller;
  const _TrustStrip({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.trustLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.trust,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hi
                        ? 'AI द्वारा मार्गदर्शन'
                        : 'AI-powered guidance',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: AppColors.trustDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hi
                        ? 'डॉक्टर का विकल्प नहीं — केवल सहायता'
                        : 'Not a replacement for a doctor',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Emergency CTA ─────────────────────────────────────────────────────────

class _EmergencyCta extends StatelessWidget {
  final TriageController controller;
  const _EmergencyCta({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.emergency, AppColors.emergencyDeep],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.emergency.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () =>
                LocationService.callNumber(AppStrings.ambulanceNumber),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hi ? 'आपातकाल?' : 'Emergency?',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hi
                              ? 'अभी 108 पर कॉल करें'
                              : 'Call 108 now — free ambulance',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.92),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.22),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
