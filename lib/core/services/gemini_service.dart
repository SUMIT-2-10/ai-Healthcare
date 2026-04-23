import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/logger.dart';

enum AppLanguage { hindi, english }

class GeminiService {
  static const String _modelName = 'gemini-1.5-flash';

  late GenerativeModel _model;
  bool _initialized = false;

  void initialize(String apiKey) {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 512,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      ],
    );
    _initialized = true;
    AppLogger.i('GeminiService initialized');
  }

  bool get isInitialized => _initialized;

  // ─── Step 1: Generate follow-up question ───────────────────────────────────

  Future<String> generateFollowUpQuestion({
    required String symptoms,
    required AppLanguage language,
  }) async {
    _assertInitialized();

    final systemInstruction = language == AppLanguage.hindi
        ? '''Tum ek anubhavi gramin swasthya triage assistant ho.
Tumhara kaam hai ek SABSE ZAROORI anusaran prashna poochna.

Niyam:
- Sirf EK prashna poochho
- Simple aur seedhi bhasha mein (Hindi)
- 1-2 vaakyon se zyaada nahi
- Medical jargon mat use karo
- Yadi serious lakshan ho (seene mein dard, saans ki takleef) toh urgency wala prashna poochho'''
        : '''You are an experienced rural health triage assistant.
Your job is to ask ONE most important follow-up question.

Rules:
- Ask only ONE question
- Use simple, clear language (English)
- No more than 1-2 sentences
- No medical jargon
- If serious symptoms (chest pain, breathing difficulty), ask about urgency indicators''';

    final prompt = '''$systemInstruction

Patient said: "$symptoms"

Ask the single most important follow-up question now:''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '';
      AppLogger.i('Follow-up Q generated: $text');
      return text;
    } on GenerativeAIException catch (e) {
      AppLogger.e('Gemini follow-up error', e);
      return language == AppLanguage.hindi
          ? 'यह समस्या कब से है और दर्द कितना तेज है (1 से 10 में)?'
          : 'How long have you had this, and how severe is the pain on a scale of 1-10?';
    }
  }

  // ─── Step 2: Final triage classification ──────────────────────────────────

  Future<Map<String, dynamic>> classifyTriage({
    required String symptoms,
    required String followUpQuestion,
    required String followUpAnswer,
    required AppLanguage language,
  }) async {
    _assertInitialized();

    final isHindi = language == AppLanguage.hindi;

    final systemInstruction = isHindi
        ? '''Tum ek gramin swasthya triage assistant ho.
Neeche diye gaye lakshan aur jawab ke aadhar par triage karo.

SIRF is JSON format mein jawab do (koi aur text nahi, koi markdown nahi):
{
  "category": "EMERGENCY" ya "DOCTOR_VISIT" ya "HOME_CARE",
  "reason": "Hindi mein 1 line karan (simple bhasha)",
  "next_steps": "Hindi mein 1-2 vaakyon mein kya karna chahiye",
  "urgency_score": 0 se 100 ke beech number,
  "home_care_tips": ["tip1", "tip2", "tip3"] (sirf HOME_CARE ke liye)
}

Category guidelines:
- EMERGENCY: Seene mein dard, saans ki takleef, behoshi, tej khoon aana, bachche mein tej bukhar (104°F+)
- DOCTOR_VISIT: Tej bukhar (102°F+), infection ke lakshan, 2 din se zyaada dard, pregnancy issues
- HOME_CARE: Halka bukhar, sardi-khansi, halka dard'''
        : '''You are a rural health triage assistant.
Classify urgency based on the symptoms and answers below.

Respond ONLY in this JSON format (no other text, no markdown):
{
  "category": "EMERGENCY" or "DOCTOR_VISIT" or "HOME_CARE",
  "reason": "1-line reason in simple English",
  "next_steps": "What to do next in 1-2 sentences",
  "urgency_score": number between 0 and 100,
  "home_care_tips": ["tip1", "tip2", "tip3"] (only for HOME_CARE)
}

Category guidelines:
- EMERGENCY: Chest pain, breathing difficulty, unconsciousness, heavy bleeding, high fever in infants (104°F+)
- DOCTOR_VISIT: High fever (102°F+), signs of infection, pain >2 days, pregnancy complications
- HOME_CARE: Mild fever, cold/cough, minor pain''';

    final prompt = '''$systemInstruction

Initial symptoms: $symptoms
Follow-up question asked: $followUpQuestion
Patient's answer: $followUpAnswer

Classify now (JSON only):''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final raw = response.text?.trim() ?? '';
      AppLogger.d('Gemini triage raw: $raw');

      // Clean and parse
      final cleaned = raw
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final parsed = jsonDecode(cleaned) as Map<String, dynamic>;
      AppLogger.i('Triage result: ${parsed['category']} (score: ${parsed['urgency_score']})');
      return parsed;
    } on GenerativeAIException catch (e) {
      AppLogger.e('Gemini triage error', e);
      return _fallbackResult(symptoms, isHindi);
    } on FormatException catch (e) {
      AppLogger.e('JSON parse error', e);
      return _fallbackResult(symptoms, isHindi);
    }
  }

  // ─── Fallback for parsing errors ──────────────────────────────────────────

  Map<String, dynamic> _fallbackResult(String symptoms, bool isHindi) {
    final upper = symptoms.toLowerCase();
    String category = 'HOME_CARE';
    int score = 20;

    if (upper.contains('chest') || upper.contains('seene') ||
        upper.contains('saans') || upper.contains('breath') ||
        upper.contains('unconscious') || upper.contains('behosh')) {
      category = 'EMERGENCY';
      score = 90;
    } else if (upper.contains('fever') || upper.contains('bukhar') ||
        upper.contains('pain') || upper.contains('dard') ||
        upper.contains('infection')) {
      category = 'DOCTOR_VISIT';
      score = 58;
    }

    return {
      'category': category,
      'urgency_score': score,
      'reason': isHindi
          ? 'लक्षणों के आधार पर यह वर्गीकरण किया गया है।'
          : 'Classification based on the reported symptoms.',
      'next_steps': isHindi
          ? (category == 'EMERGENCY'
              ? 'तुरंत 108 पर कॉल करें।'
              : category == 'DOCTOR_VISIT'
                  ? 'आज नज़दीकी PHC जाएं।'
                  : 'आराम करें और पानी पिएं।')
          : (category == 'EMERGENCY'
              ? 'Call 108 immediately.'
              : category == 'DOCTOR_VISIT'
                  ? 'Visit your nearest PHC today.'
                  : 'Rest and stay hydrated.'),
      'home_care_tips': isHindi
          ? ['खूब पानी पिएं', 'आराम करें', 'हल्का खाना खाएं']
          : ['Drink plenty of water', 'Rest well', 'Eat light food'],
    };
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError('GeminiService not initialized. Call initialize() first.');
    }
  }
}
