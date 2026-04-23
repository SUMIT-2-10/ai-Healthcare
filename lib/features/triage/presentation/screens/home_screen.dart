import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/triage_controller.dart';
import '../widgets/mic_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = Get.find<TriageController>();
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text.isNotEmpty
        ? _textController.text
        : _controller.liveTranscript.value;
    _controller.submitSymptoms(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(controller: _controller),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _StepIndicator(currentStep: 1),
                    const SizedBox(height: 20),
                    _SymptomInputCard(
                      controller: _controller,
                      textController: _textController,
                      focusNode: _focusNode,
                      onSend: _handleSend,
                    ),
                    const SizedBox(height: 16),
                    _ExamplesRow(controller: _controller, textController: _textController),
                    const SizedBox(height: 24),
                    _DisclaimerText(controller: _controller),
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

// ─── AppBar ──────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final TriageController controller;
  const _AppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderStrong)),
      ),
      child: Row(
        children: [
          // Brand
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: AppColors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rural Triage Assistant',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Obx(() => Text(
                  controller.isHindi ? AppStrings.appNameHindi : AppStrings.tagline,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                )),
              ],
            ),
          ),
          // Language toggle
          Obx(() => GestureDetector(
            onTap: controller.toggleLanguage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                controller.isHindi ? 'EN' : 'हि',
                style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Step Indicator ──────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(number: 1, isActive: currentStep == 1, isDone: currentStep > 1),
        _StepLine(isDone: currentStep > 1),
        _StepDot(number: 2, isActive: currentStep == 2, isDone: currentStep > 2),
        _StepLine(isDone: currentStep > 2),
        _StepDot(number: 3, isActive: currentStep == 3, isDone: false),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isDone;
  const _StepDot({required this.number, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    final bg = isDone
        ? AppColors.primaryLight
        : isActive
            ? AppColors.primary
            : AppColors.surfaceAlt;
    final textColor = isDone
        ? AppColors.primary
        : isActive
            ? AppColors.white
            : AppColors.textMuted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(
          color: (isActive || isDone) ? AppColors.primary : AppColors.borderStrong,
          width: 1.5,
        ),
      ),
      child: Center(
        child: isDone
            ? Icon(Icons.check_rounded, size: 14, color: AppColors.primary)
            : Text('$number',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: textColor)),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool isDone;
  const _StepLine({required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 1.5,
        color: isDone ? AppColors.primary : AppColors.borderStrong,
      ),
    );
  }
}

// ─── Symptom Input Card ───────────────────────────────────────────────────────

class _SymptomInputCard extends StatelessWidget {
  final TriageController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _SymptomInputCard({
    required this.controller,
    required this.textController,
    required this.focusNode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderStrong),
      ),
      child: Column(
        children: [
          // Card label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Obx(() => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.isHindi
                    ? AppStrings.describeSymptomsHi
                    : AppStrings.describeSymptoms,
                style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  letterSpacing: 0.08, color: AppColors.textMuted,
                ),
              ),
            )),
          ),

          // Mic area
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Obx(() => MicButton(
                  isRecording: controller.isRecording.value,
                  soundLevel: controller.soundLevel.value,
                  onTap: () {
                    if (controller.isRecording.value) {
                      controller.stopRecording();
                    } else {
                      controller.startRecording();
                    }
                  },
                )),
                const SizedBox(height: 14),
                Obx(() => Text(
                  controller.isRecording.value
                      ? (controller.isHindi
                          ? AppStrings.listeningHi
                          : AppStrings.listening)
                      : (controller.isHindi
                          ? AppStrings.tapToSpeakHi
                          : AppStrings.tapToSpeak),
                  style: TextStyle(
                    fontSize: 13,
                    color: controller.isRecording.value
                        ? AppColors.emergency
                        : AppColors.textSecondary,
                  ),
                )),

                // Live transcript preview
                Obx(() {
                  final t = controller.liveTranscript.value;
                  if (t.isEmpty) {
                    return const SizedBox(height: 4);
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(t,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13, color: AppColors.primary, height: 1.5,
                          )),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: Divider(color: AppColors.divider)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('OR', style: TextStyle(
                    fontSize: 11, color: AppColors.textMuted,
                    fontWeight: FontWeight.w600, letterSpacing: 0.08)),
              ),
              Expanded(child: Divider(color: AppColors.divider)),
            ]),
          ),

          // Text input row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => TextField(
                    controller: textController,
                    focusNode: focusNode,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: controller.isHindi
                          ? AppStrings.inputHintHi
                          : AppStrings.inputHint,
                    ),
                    onSubmitted: (_) => onSend(),
                    maxLines: 1,
                  )),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSend,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: Obx(() => Text(
                    controller.isHindi ? AppStrings.sendButtonHi : AppStrings.sendButton,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

// ─── Examples ────────────────────────────────────────────────────────────────

class _ExamplesRow extends StatelessWidget {
  final TriageController controller;
  final TextEditingController textController;

  const _ExamplesRow({required this.controller, required this.textController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final examples = controller.isHindi
          ? AppStrings.examplesHi
          : AppStrings.examplesEn;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: examples.asMap().entries.map((e) {
          return GestureDetector(
            onTap: () => textController.text = e.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Text(
                e.value,
                style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary,
                ),
              ),
            ),
          ).animate(delay: Duration(milliseconds: e.key * 60))
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.1);
        }).toList(),
      );
    });
  }
}

// ─── Disclaimer ──────────────────────────────────────────────────────────────

class _DisclaimerText extends StatelessWidget {
  final TriageController controller;
  const _DisclaimerText({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text(
      controller.isHindi ? AppStrings.disclaimerHi : AppStrings.disclaimer,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 11, color: AppColors.textMuted, height: 1.6,
      ),
    ));
  }
}
