import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/triage_controller.dart';
import '../widgets/mic_button.dart';
import '../widgets/loading_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/strings.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _controller = Get.find<TriageController>();
  final _textController = TextEditingController();

  void _handleAnswer() {
    final text = _textController.text.isNotEmpty
        ? _textController.text
        : _controller.liveTranscript.value;
    _controller.submitFollowUpAnswer(text);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          _controller.isHindi
              ? AppStrings.followUpHi
              : AppStrings.followUp,
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: _controller.reset,
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final isLoading = _controller.loadingState.value == LoadingState.loading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Symptom echo
                    _SymptomEcho(controller: _controller),
                    const SizedBox(height: 16),

                    // AI question bubble
                    if (_controller.followUpQuestion.value.isNotEmpty)
                      _AIQuestionBubble(
                        question: _controller.followUpQuestion.value,
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                    if (isLoading && _controller.followUpQuestion.value.isEmpty)
                      LoadingWidget(
                        message: _controller.isHindi
                            ? AppStrings.analyzingHi
                            : AppStrings.analyzing,
                      ),

                    const SizedBox(height: 20),

                    // Answer area
                    if (_controller.followUpQuestion.value.isNotEmpty) ...[
                      _AnswerInputCard(
                        controller: _controller,
                        textController: _textController,
                        onAnswer: _handleAnswer,
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                    ],

                    // Live transcript
                    Obx(() {
                      final t = _controller.liveTranscript.value;
                      if (t.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(t,
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.primary)),
                        ),
                      );
                    }),

                    // Error
                    Obx(() {
                      final err = _controller.errorMessage.value;
                      if (err.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.emergencyBorder),
                          ),
                          child: Text(err,
                              style: const TextStyle(
                                  color: AppColors.emergency, fontSize: 13)),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    // Reset option
                    TextButton.icon(
                      onPressed: _controller.reset,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Obx(() => Text(
                        _controller.isHindi
                            ? 'फिर से शुरू करें'
                            : 'Start over',
                      )),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Full-screen overlay when classifying
              if (isLoading && _controller.followUpQuestion.value.isNotEmpty)
                FullScreenLoader(
                  message: _controller.isHindi
                      ? AppStrings.analyzingHi
                      : AppStrings.analyzing,
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Symptom Echo ─────────────────────────────────────────────────────────────

class _SymptomEcho extends StatelessWidget {
  final TriageController controller;
  const _SymptomEcho({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_outline_rounded,
              size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.isHindi ? 'आपने बताया:' : 'You described:',
                  style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted,
                    fontWeight: FontWeight.w600, letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.currentSymptom.value?.text ?? '',
                  style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary, height: 1.5,
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AI Question Bubble ───────────────────────────────────────────────────────

class _AIQuestionBubble extends StatelessWidget {
  final String question;
  const _AIQuestionBubble({required this.question});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text('🩺', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 15, color: AppColors.textPrimary, height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Answer Input Card ───────────────────────────────────────────────────────

class _AnswerInputCard extends StatelessWidget {
  final TriageController controller;
  final TextEditingController textController;
  final VoidCallback onAnswer;

  const _AnswerInputCard({
    required this.controller,
    required this.textController,
    required this.onAnswer,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Obx(() => Align(
              alignment: Alignment.centerLeft,
              child: Text(
                controller.isHindi
                    ? 'माइक से या टाइप करके जवाब दें'
                    : 'Answer by voice or typing',
                style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted,
                  fontWeight: FontWeight.w600, letterSpacing: 0.06,
                ),
              ),
            )),
          ),

          // Mini mic
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Obx(() => MicButton(
              isRecording: controller.isRecording.value,
              soundLevel: controller.soundLevel.value,
              size: 60,
              onTap: () {
                if (controller.isRecording.value) {
                  controller.stopRecording();
                } else {
                  controller.startRecording();
                }
              },
            )),
          ),

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

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: controller.isHindi
                          ? AppStrings.answerHintHi
                          : AppStrings.answerHint,
                    ),
                    onSubmitted: (_) => onAnswer(),
                    style: const TextStyle(fontSize: 14),
                  )),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAnswer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: Obx(() => Text(
                    controller.isHindi ? AppStrings.answerHi : AppStrings.answer,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
