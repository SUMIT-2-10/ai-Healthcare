import '../../../triage/data/models/symptom_model.dart';
import '../../../triage/data/models/triage_result_model.dart';
import '../../../../core/services/gemini_service.dart';
import '../../../../core/utils/logger.dart';

class TriageRepository {
  final GeminiService _geminiService;

  TriageRepository({required GeminiService geminiService})
      : _geminiService = geminiService;

  /// Step 1 — Get follow-up question from AI
  Future<String> getFollowUpQuestion({
    required SymptomModel symptom,
    required AppLanguage language,
  }) async {
    AppLogger.i('Getting follow-up Q for: ${symptom.text}');
    try {
      return await _geminiService.generateFollowUpQuestion(
        symptoms: symptom.text,
        language: language,
      );
    } catch (e, st) {
      AppLogger.e('Repository: follow-up error', e, st);
      rethrow;
    }
  }

  /// Step 2 — Get final triage classification
  Future<TriageResultModel> classifySymptoms({
    required SymptomModel symptom,
    required String followUpQuestion,
    required String followUpAnswer,
    required AppLanguage language,
  }) async {
    AppLogger.i('Classifying: ${symptom.text} | answer: $followUpAnswer');
    try {
      final raw = await _geminiService.classifyTriage(
        symptoms: symptom.text,
        followUpQuestion: followUpQuestion,
        followUpAnswer: followUpAnswer,
        language: language,
      );
      return TriageResultModel.fromMap(raw);
    } catch (e, st) {
      AppLogger.e('Repository: classify error', e, st);
      rethrow;
    }
  }
}
