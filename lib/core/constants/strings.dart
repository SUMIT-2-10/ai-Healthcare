class AppStrings {
  AppStrings._();

  // ─── App ───────────────────────────────────────
  static const String appName = 'Rural Triage Assistant';
  static const String appNameHindi = 'ग्रामीण स्वास्थ्य सहायक';
  static const String tagline = 'Your health. Your language.';
  static const String taglineHindi = 'आपकी भाषा में स्वास्थ्य सहायता';

  // ─── Languages ────────────────────────────────
  static const String hindi = 'हिंदी';
  static const String english = 'English';

  // ─── Home Screen ──────────────────────────────
  static const String describeSymptoms = 'Describe your problem';
  static const String describeSymptomsHi = 'अपनी समस्या बताएं';
  static const String tapToSpeak = 'Tap to speak';
  static const String tapToSpeakHi = 'बोलने के लिए दबाएं';
  static const String orTypeBelow = 'or type below';
  static const String orTypeBelowHi = 'या नीचे टाइप करें';
  static const String sendButton = 'Send';
  static const String sendButtonHi = 'भेजें';
  static const String listeningHi = 'सुन रहा हूँ...';
  static const String listening = 'Listening...';
  static const String inputHint = 'fever, pain, dizziness...';
  static const String inputHintHi = 'बुखार, दर्द, चक्कर...';

  // ─── Example symptoms ─────────────────────────
  static const List<String> examplesHi = [
    'बुखार और सिरदर्द',
    'सीने में दर्द',
    'बच्चे को दस्त',
    'चक्कर आना',
    'पेट में दर्द',
  ];
  static const List<String> examplesEn = [
    'Fever and headache',
    'Chest pain',
    'Child with diarrhea',
    'Dizziness',
    'Stomach pain',
  ];

  // ─── Question Screen ──────────────────────────
  static const String followUpHi = 'फॉलो-अप प्रश्न';
  static const String followUp = 'Follow-up Question';
  static const String answerHi = 'जवाब दें';
  static const String answer = 'Answer';
  static const String answerHintHi = 'आपका जवाब...';
  static const String answerHint = 'Your answer...';
  static const String analyzingHi = 'जांच हो रही है...';
  static const String analyzing = 'Analyzing...';

  // ─── Result Screen ────────────────────────────
  static const String triageResultHi = 'जांच परिणाम';
  static const String triageResult = 'Triage Result';
  static const String reasonHi = 'कारण';
  static const String reason = 'Reason';
  static const String nextStepsHi = 'अगला कदम';
  static const String nextSteps = 'Next Steps';
  static const String urgencyHi = 'तीव्रता स्तर';
  static const String urgency = 'Urgency Level';
  static const String newAssessmentHi = 'नई जांच';
  static const String newAssessment = 'New Assessment';

  // ─── Categories ──────────────────────────────
  static const String emergency = 'EMERGENCY';
  static const String doctorVisit = 'DOCTOR_VISIT';
  static const String homeCare = 'HOME_CARE';

  static const String emergencyLabelHi = 'आपातकाल';
  static const String emergencyLabel = 'Emergency';
  static const String emergencyTitleHi = 'तुरंत अस्पताल जाएं!';
  static const String emergencyTitle = 'Seek Emergency Care Now!';

  static const String doctorLabelHi = 'डॉक्टर से मिलें';
  static const String doctorLabel = 'Doctor Visit Needed';
  static const String doctorTitleHi = 'आज डॉक्टर को दिखाएं';
  static const String doctorTitle = 'See a Doctor Today';

  static const String homeLabelHi = 'घर पर देखभाल';
  static const String homeLabel = 'Home Care';
  static const String homeTitleHi = 'घर पर ठीक हो सकते हैं';
  static const String homeTitle = 'Manageable at Home';

  // ─── Actions ─────────────────────────────────
  static const String callAmbulance = 'Call Ambulance';
  static const String callAmbulanceHi = 'एम्बुलेंस बुलाएं';
  static const String nearestHospital = 'Nearest Hospital';
  static const String nearestHospitalHi = 'नज़दीकी अस्पताल';
  static const String findNearbyPHC = 'Find Nearby PHC';
  static const String findNearbyPHCHi = 'नज़दीकी PHC देखें';
  static const String healthHelpline = 'Health Helpline';
  static const String healthHelplineHi = 'स्वास्थ्य हेल्पलाइन';
  static const String homeCareGuide = 'Home Care Tips';
  static const String homeCareGuideHi = 'घर पर देखभाल के उपाय';

  // ─── Emergency Numbers ───────────────────────
  static const String ambulanceNumber = '108';
  static const String healthHelplineNumber = '104';

  // ─── Disclaimer ──────────────────────────────
  static const String disclaimerHi =
      'यह केवल मार्गदर्शन के लिए है। चिकित्सीय सलाह के लिए हमेशा डॉक्टर से मिलें।';
  static const String disclaimer =
      'This tool is for guidance only. Always consult a healthcare professional for medical advice.';

  // ─── Errors ──────────────────────────────────
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoInternet = 'No internet connection.';
  static const String errorMicPermission = 'Microphone permission denied.';
  static const String errorEmptyInput = 'Please describe your symptoms first.';
}
