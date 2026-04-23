# 🩺 Rural Triage Assistant — ग्रामीण स्वास्थ्य सहायक

A multilingual AI-powered health triage app for rural India.
Supports Hindi & English voice input, flags urgency, and recommends the right level of care.

---

## 🚀 Quick Setup

### 1. Clone & install Flutter dependencies
```bash
flutter pub get
```

### 2. Configure your Gemini API key

Open `lib/routes/app_routes.dart` and replace:
```dart
defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
```
with your actual key from [Google AI Studio](https://aistudio.google.com/app/apikey).

**For production**, use `--dart-define`:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

### 3. Firebase setup (optional but recommended for production)
```bash
firebase login
firebase init
# Select: Functions, Firestore
firebase deploy --only functions
```

Set your Gemini key as a Firebase config:
```bash
firebase functions:config:set gemini.api_key="YOUR_KEY"
```

### 4. Run
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                        # App entry
├── core/
│   ├── constants/
│   │   ├── app_colors.dart          # Color palette
│   │   ├── app_theme.dart           # Material 3 theme
│   │   └── strings.dart             # Bilingual string constants
│   ├── utils/
│   │   ├── logger.dart              # Logging
│   │   └── helpers.dart             # Utility functions
│   └── services/
│       ├── gemini_service.dart      # Gemini AI calls + prompts
│       ├── speech_service.dart      # STT (Hindi/English) + TTS
│       └── location_service.dart    # Maps + phone calls
├── features/triage/
│   ├── data/
│   │   ├── models/
│   │   │   ├── symptom_model.dart
│   │   │   └── triage_result_model.dart
│   │   └── repositories/
│   │       └── triage_repository.dart
│   └── presentation/
│       ├── controllers/
│       │   └── triage_controller.dart  # GetX controller (main brain)
│       ├── screens/
│       │   ├── home_screen.dart        # Symptom input
│       │   ├── question_screen.dart    # AI follow-up Q&A
│       │   └── result_screen.dart      # Triage result + actions
│       └── widgets/
│           ├── mic_button.dart         # Animated mic with pulse ring
│           ├── result_card.dart        # Red/Yellow/Green result card
│           └── loading_widget.dart     # Bouncing dots + full-screen loader
└── routes/
    └── app_routes.dart              # GetX routing + DI bindings

functions/
├── index.js                         # Firebase Cloud Functions (Node.js)
└── package.json
```

---

## 🔄 App Flow

```
Voice Input (Hindi/English)
    ↓
SpeechService (STT)
    ↓
TriageController.submitSymptoms()
    ↓
TriageRepository → GeminiService
    ↓
Follow-up Question (AI) → TTS speaks it
    ↓
User Answers (Voice/Text)
    ↓
TriageController.submitFollowUpAnswer()
    ↓
GeminiService.classifyTriage() → JSON
    ↓
TriageResultModel parsed
    ↓
ResultScreen: 🔴/🟡/🟢 Card + Action Buttons
    ↓
TTS speaks the result
```

---

## 📱 Android Permissions (android/app/src/main/AndroidManifest.xml)

Add these inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

## 🍎 iOS Permissions (ios/Runner/Info.plist)

Add:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Microphone needed for voice symptom input</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Speech recognition to convert symptoms to text</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location to find nearby health centres</string>
```

---

## 🎯 Triage Categories

| Category | Color | Trigger Conditions |
|---|---|---|
| 🔴 EMERGENCY | Red | Chest pain, breathing difficulty, unconsciousness, heavy bleeding |
| 🟡 DOCTOR_VISIT | Yellow | High fever (102°F+), infection signs, pain >2 days, pregnancy issues |
| 🟢 HOME_CARE | Green | Mild fever, cold/cough, minor aches |

---

## 🌐 Languages

- **Hindi (हिंदी)** — Full STT + TTS + UI
- **English** — Full STT + TTS + UI
- Toggle via language button in the header

---

## 📞 Emergency Numbers (India)

- **108** — National Ambulance Service (free)
- **104** — Health Helpline / Telemedicine

---

## 🔐 Security Notes

- Never hardcode API keys in source code
- Use `--dart-define` for local dev
- Use Firebase Remote Config or Cloud Functions for production
- Triage sessions are saved anonymously (no PII)

---

## 🧪 Hackathon Mode

For quick demo without Firebase, the `GeminiService` calls Gemini directly from the app.
This is fine for a hackathon — move to Cloud Functions before production.
