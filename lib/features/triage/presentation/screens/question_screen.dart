import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/triage_controller.dart';
import '../widgets/mic_button.dart';
import '../widgets/loading_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/constants/strings.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
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

  void _handleAnswer() {
    final text = _textController.text.trim().isNotEmpty
        ? _textController.text.trim()
        : _controller.liveTranscript.value.trim();
    if (text.isEmpty) return;
    _controller.submitFollowUpAnswer(text);
  }

  void _toggleTypeInput() {
    setState(() => _showTypeInput = !_showTypeInput);
    if (_showTypeInput) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _focusNode.requestFocus(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final isLoading =
              _controller.loadingState.value == LoadingState.loading;
          final hasQuestion = _controller.followUpQuestion.value.isNotEmpty;

          return Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _QuestionTopBar(controller: _controller)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SymptomRecap(controller: _controller),
                          const SizedBox(height: 32),
                          if (!hasQuestion && isLoading)
                            LoadingWidget(
                              message: _controller.isHindi
                                  ? AppStrings.analyzingHi
                                  : AppStrings.analyzing,
                            )
                          else if (hasQuestion)
                            _HeroQuestion(
                              question: _controller.followUpQuestion.value,
                              controller: _controller,
                            ),
                          if (hasQuestion) ...[
                            const SizedBox(height: 40),
                            _AnswerMicStage(controller: _controller),
                            const SizedBox(height: 12),
                            _TranscriptPreview(controller: _controller),
                            _ErrorBanner(controller: _controller),
                            const SizedBox(height: 28),
                            _TypeToggle(
                              isOpen: _showTypeInput,
                              controller: _controller,
                              onToggle: _toggleTypeInput,
                            ),
                            if (_showTypeInput) ...[
                              const SizedBox(height: 12),
                              _AnswerTypeInput(
                                controller: _controller,
                                textController: _textController,
                                focusNode: _focusNode,
                                onSend: _handleAnswer,
                              ),
                            ],
                            const SizedBox(height: 36),
                            _StartOverButton(controller: _controller),
                            const SizedBox(height: 24),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (isLoading && hasQuestion)
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

// ─── Top bar ────────────────────────────────────────────────────────────────

class _QuestionTopBar extends StatelessWidget {
  final TriageController controller;
  const _QuestionTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.reset,
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Obx(() => Text(
                  controller.isHindi ? 'दूसरा सवाल' : 'One more question',
                  style: Theme.of(context).textTheme.labelMedium,
                )),
          ),
          IconButton(
            onPressed: () {
              if (controller.followUpQuestion.value.isNotEmpty) {
                controller.replayQuestion();
              }
            },
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Replay',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Symptom recap ──────────────────────────────────────────────────────────

class _SymptomRecap extends StatelessWidget {
  final TriageController controller;
  const _SymptomRecap({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sym = controller.currentSymptom.value?.text ?? '';
      if (sym.isEmpty) return const SizedBox.shrink();
      final hi = controller.isHindi;
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.record_voice_over_rounded,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  hi ? 'आपने बताया' : 'You described',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              sym,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Hero question ──────────────────────────────────────────────────────────

class _HeroQuestion extends StatelessWidget {
  final String question;
  final TriageController controller;
  const _HeroQuestion({required this.question, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hi = controller.isHindi;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hi ? 'हम पूछते हैं' : 'We need to know',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 26,
                  height: 1.3,
                  letterSpacing: -0.3,
                ),
          ),
        ],
      ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.08);
    });
  }
}

// ─── Answer mic stage ───────────────────────────────────────────────────────

class _AnswerMicStage extends StatelessWidget {
  final TriageController controller;
  const _AnswerMicStage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRec = controller.isRecording.value;
      final hi = controller.isHindi;
      final stateText = isRec
          ? (hi ? AppStrings.listeningHi : AppStrings.listening)
          : (hi ? 'बोलकर जवाब दें' : 'Answer by speaking');
      return Column(
        children: [
          MicButton(
            isRecording: isRec,
            soundLevel: controller.soundLevel.value,
            size: 96,
            onTap: () {
              if (isRec) {
                controller.stopRecording();
              } else {
                controller.startRecording();
              }
            },
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              stateText,
              key: ValueKey(stateText),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isRec
                        ? AppColors.emergency
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      );
    });
  }
}

// ─── Transcript preview ─────────────────────────────────────────────────────

class _TranscriptPreview extends StatelessWidget {
  final TriageController controller;
  const _TranscriptPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = controller.liveTranscript.value;
      if (t.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.graphic_eq_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              _SendArrow(onTap: () => controller.submitFollowUpAnswer(t)),
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

// ─── Error banner ───────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final TriageController controller;
  const _ErrorBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final err = controller.errorMessage.value;
      if (err.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.emergencyLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
        ),
      );
    });
  }
}

// ─── "Or type" toggle ───────────────────────────────────────────────────────

class _TypeToggle extends StatelessWidget {
  final bool isOpen;
  final TriageController controller;
  final VoidCallback onToggle;

  const _TypeToggle({
    required this.isOpen,
    required this.controller,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() {
        final hi = controller.isHindi;
        final label = hi
            ? (isOpen ? 'छिपाएँ' : 'टाइप करके जवाब दें')
            : (isOpen ? 'Hide' : 'Or type your answer');
        return TextButton.icon(
          onPressed: onToggle,
          icon: Icon(
            isOpen ? Icons.keyboard_hide_rounded : Icons.keyboard_alt_outlined,
            size: 18,
          ),
          label: Text(label),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(0, 44),
          ),
        );
      }),
    );
  }
}

class _AnswerTypeInput extends StatelessWidget {
  final TriageController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onSend;

  const _AnswerTypeInput({
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
                hintText: hi
                    ? AppStrings.answerHintHi
                    : AppStrings.answerHint,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: onSend,
              child: Text(hi ? AppStrings.answerHi : AppStrings.answer),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06);
    });
  }
}

// ─── Start over ─────────────────────────────────────────────────────────────

class _StartOverButton extends StatelessWidget {
  final TriageController controller;
  const _StartOverButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Obx(() => TextButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              controller.isHindi ? 'फिर से शुरू करें' : 'Start over',
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
            ),
          )),
    );
  }
}
