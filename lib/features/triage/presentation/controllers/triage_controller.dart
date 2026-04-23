import 'package:get/get.dart';
import '../../data/models/symptom_model.dart';
import '../../data/models/triage_result_model.dart';
import '../../data/repositories/triage_repository.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/logger.dart';
import '../../../../routes/app_routes.dart';

enum TriageStep { input, followUp, result }
enum LoadingState { idle, loading, error }

class TriageController extends GetxController {
  final TriageRepository _repository;
  final SpeechService _speechService;

  TriageController({
    required TriageRepository repository,
    required SpeechService speechService,
  })  : _repository = repository,
        _speechService = speechService;

  // ─── Observable state ─────────────────────────────────────────────────────

  final Rx<TriageStep> step = TriageStep.input.obs;
  final Rx<LoadingState> loadingState = LoadingState.idle.obs;
  final Rx<AppLanguage> language = AppLanguage.hindi.obs;
  final RxBool isRecording = false.obs;
  final RxDouble soundLevel = 0.0.obs;
  final RxString errorMessage = ''.obs;

  final Rx<SymptomModel?> currentSymptom = Rx(null);
  final RxString followUpQuestion = ''.obs;
  final RxString followUpAnswer = ''.obs;
  final Rx<TriageResultModel?> triageResult = Rx(null);

  // For live speech transcription display
  final RxString liveTranscript = ''.obs;

  // ─── Computed helpers ─────────────────────────────────────────────────────

  bool get isHindi => language.value == AppLanguage.hindi;

  String get stepLabel {
    switch (step.value) {
      case TriageStep.input:
        return isHindi ? 'लक्षण बताएं' : 'Describe Symptoms';
      case TriageStep.followUp:
        return isHindi ? 'अनुवर्ती प्रश्न' : 'Follow-up';
      case TriageStep.result:
        return isHindi ? 'परिणाम' : 'Result';
    }
  }

  // ─── Language toggle ──────────────────────────────────────────────────────

  void toggleLanguage() {
    language.value = isHindi ? AppLanguage.english : AppLanguage.hindi;
    AppLogger.d('Language toggled to: ${language.value}');
  }

  // ─── Voice / STT ──────────────────────────────────────────────────────────

  Future<void> startRecording() async {
    liveTranscript.value = '';
    _speechService.onResult = (text) {
      liveTranscript.value = text;
    };
    _speechService.onStatusChange = (status) {
      if (status == SpeechStatus.listening) {
        isRecording.value = true;
      } else if (status == SpeechStatus.done || status == SpeechStatus.idle) {
        isRecording.value = false;
      } else if (status == SpeechStatus.error) {
        isRecording.value = false;
        _setError(AppStrings.errorMicPermission);
      }
    };
    _speechService.onSoundLevel = (level) => soundLevel.value = level;

    final locale = isHindi ? 'hi_IN' : 'en_IN';
    await _speechService.startListening(locale: locale);
  }

  Future<void> stopRecording() async {
    await _speechService.stopListening();
    isRecording.value = false;
  }

  // ─── Step 1: Submit symptoms ───────────────────────────────────────────────

  Future<void> submitSymptoms(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _setError(AppStrings.errorEmptyInput);
      return;
    }

    _clearError();
    currentSymptom.value = SymptomModel(
      text: trimmed,
      isHindi: isHindi,
    );

    loadingState.value = LoadingState.loading;
    step.value = TriageStep.followUp;
    Get.toNamed(AppRoutes.question);

    try {
      final question = await _repository.getFollowUpQuestion(
        symptom: currentSymptom.value!,
        language: language.value,
      );
      followUpQuestion.value = question;

      // TTS — speak the question
      await _speechService.speak(question,
          language: isHindi ? 'hi-IN' : 'en-IN');

      loadingState.value = LoadingState.idle;
    } catch (e, st) {
      AppLogger.e('submitSymptoms error', e, st);
      loadingState.value = LoadingState.error;
      _setError(AppStrings.errorGeneric);
    }
  }

  // ─── Step 2: Submit follow-up answer ──────────────────────────────────────

  Future<void> submitFollowUpAnswer(String answer) async {
    final trimmed = answer.trim();
    if (trimmed.isEmpty) return;

    followUpAnswer.value = trimmed;
    _clearError();
    loadingState.value = LoadingState.loading;

    try {
      final result = await _repository.classifySymptoms(
        symptom: currentSymptom.value!,
        followUpQuestion: followUpQuestion.value,
        followUpAnswer: trimmed,
        language: language.value,
      );

      triageResult.value = result;
      step.value = TriageStep.result;
      loadingState.value = LoadingState.idle;

      // Speak the result
      await _speechService.speak(
        '${result.titleFor(isHindi)}. ${result.nextSteps}',
        language: isHindi ? 'hi-IN' : 'en-IN',
      );

      Get.toNamed(AppRoutes.result);
    } catch (e, st) {
      AppLogger.e('submitFollowUpAnswer error', e, st);
      loadingState.value = LoadingState.error;
      _setError(AppStrings.errorGeneric);
    }
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> callAmbulance() async {
    await LocationService.callNumber(AppStrings.ambulanceNumber);
  }

  Future<void> callHealthHelpline() async {
    await LocationService.callNumber(AppStrings.healthHelplineNumber);
  }

  Future<void> openNearestHospital() async {
    await LocationService.openNearestHospital();
  }

  Future<void> openNearestPHC() async {
    await LocationService.openNearestPHC();
  }

  List<Map<String, String>> getNearbyFacilities() {
    return LocationService.getNearbyFacilities(
      isEmergency: triageResult.value?.category == TriageCategory.emergency,
    );
  }

  // ─── Reset ────────────────────────────────────────────────────────────────

  void reset() {
    step.value = TriageStep.input;
    loadingState.value = LoadingState.idle;
    currentSymptom.value = null;
    followUpQuestion.value = '';
    followUpAnswer.value = '';
    triageResult.value = null;
    liveTranscript.value = '';
    errorMessage.value = '';
    isRecording.value = false;
    _speechService.stopSpeaking();
    Get.until((route) => Get.currentRoute == AppRoutes.home);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  void _setError(String msg) => errorMessage.value = msg;
  void _clearError() => errorMessage.value = '';

  @override
  void onClose() {
    _speechService.dispose();
    super.onClose();
  }
}
