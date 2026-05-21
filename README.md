# NexaAI 🚀

NexaAI is a production-grade, highly-optimized Flutter training application built with a **Feature-First Clean Architecture**, state-of-the-art visual styling, robust state management, and highly-resilient, crash-safe hardware integrations.

Designed around developer best practices, NexaAI demonstrates how to handle asynchronous API transactions, handle device permissions elegantly, monitor connection reactive state, and present premium dark-themed interfaces.

---

## 🌟 Key Features

1. **Intelligent AI Chatbot (Gemini API / Simulator)**:
   - Full conversational thread history sent dynamically to Google Gemini.
   - Long-press copy to clipboard for code snippets.
   - Micro-animated staggered bouncing typing indicators.
   - **Intelligent Offline Simulation Fallback**: If the API key is not present or if you're offline, the app seamlessly runs a delayed local chatbot simulator with high-quality styled answers rather than throwing exceptions or spinning indefinitely!
2. **Interactive Google Maps & GPS Telemetry**:
   - Live location acquisition using the `Geolocator` library.
   - Clean permission handling, retry displays, and permission lock warnings.
   - **Crash-Safe Telemetry Dashboard Sandbox**: Integrates an interactive mock map overlay that lets you test camera zooms, satellite lockdowns, and coordinate trackers immediately on any emulator/device—even if Google Map API keys are not yet configured!
3. **Reactive Connectivity Monitoring**:
   - Dynamically tracks network status via `connectivity_plus`.
   - Renders animated top warning headers ("No Internet - Simulator active") instantly when connections drop.
4. **Premium Slate Dark Theme**:
   - Modern color palette: Deep Slate Scaffold (`#0F172A`), Slate Cards (`#1E293B`), Indigo gradients (`#4F46E5`), and Sky Blue highlights (`#38BDF8`).
   - Clean typography using standard Poppins and Inter typography sizing.
   - Smooth responsive dimensions rendered via `flutter_screenutil`.

---

## 🏗️ Architectural Blueprint

NexaAI strictly implements a **Feature-First Clean Architecture** coupled with the **MVVM + Repository Pattern** to decouple layout widgets, business logic, data mapping, and networking services.

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart
│   │   └── app_constants.dart
│   ├── theme/
│   │   └── app_theme.dart (Premium slate dark theme mappings)
│   ├── network/
│   │   ├── dio_client.dart (Singleton Dio with logging interceptors)
│   │   ├── api_exception.dart (Dio network failure translator)
│   │   └── connectivity_service.dart (Connectivity status notifier)
│   ├── services/
│   │   └── location_service.dart (Geolocator hardware permissions wrapper)
│   └── widgets/
│       ├── custom_button.dart
│       └── error_view.dart
│
├── features/
│   ├── chatbot/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── chat_message_model.dart (Message serialization + UUID v4)
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository_impl.dart
│   │   │   └── datasources/
│   │   │       └── chat_remote_datasource.dart (Gemini API + local fallback AI)
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── chat_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── chat_provider.dart (Optimistic UI updates StateNotifier)
│   │       ├── screens/
│   │       │   └── chat_screen.dart (Scroll controllers, list builders)
│   │       └── widgets/
│   │           ├── chat_bubble.dart (Custom borders, long press copy)
│   │           └── typing_indicator.dart (Staggered bouncing circles)
│   │
│   └── maps/
│       ├── presentation/
│       │   ├── providers/
│       │   │   └── maps_provider.dart (GPS telemetry coordinates provider)
│       │   └── screens/
│       │       └── maps_screen.dart (Hybrid standard Maps / visual dashboard)
│
├── routes/
│   └── app_router.dart (GoRouter route declarations)
├── app.dart (MaterialApp configuration with ScreenUtil responsive wrapper)
└── main.dart (Binding initializations and Riverpod ProviderScope)
```

---

## 🛠️ Step-by-Step Installation

### 1. Prerequisite Installations
Ensure you have the latest stable [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your operating system.

### 2. Clone and Dependency Fetching
Open your terminal inside the project directory and fetch the required packages:
```bash
flutter pub get
```

### 3. API Key Environment Setup
Create a file named `.env` in the project's root directory (next to `pubspec.yaml`) and paste your API key:
```env
GEMINI_API_KEY=AIzaSy...your_actual_key_here
```
*(If no API key is set, the chatbot will automatically run in simulation mode. No crashes, completely safe!)*

### 4. Running the Application
Connect a mobile device or startup an emulator and execute:
```bash
flutter run
```

---

## 🗺️ Google Maps Keys Setup (For Live maps)

To unlock the live Google Map widget in place of the sandboxed telemetry mock dashboard:

### For Android:
1. Open `android/app/src/main/AndroidManifest.xml`.
2. Inside the `<application>` node, insert your Google Maps credential:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY"
              android:value="YOUR_GOOGLE_MAPS_KEY_HERE"/>
   ```

### For iOS:
1. Open `ios/Runner/AppDelegate.swift`.
2. Import GoogleMaps package and set the key:
   ```swift
   import GoogleMaps
   ...
   GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_KEY_HERE")
   ```
