# TechCare Personal Finance Tracker

A production-ready Flutter application for managing personal finances with real-time data synchronization, advanced analytics, and smooth animations. Built with Clean Architecture and BLoC pattern.

<div align="center">
  
  [![Flutter Version](https://img.shields.io/badge/Flutter-3.24+-blue.svg)](https://flutter.dev/)
  [![Dart Version](https://img.shields.io/badge/Dart-3.9+-blue.svg)](https://dart.dev/)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Architecture](#-architecture)
- [Setup Instructions](#-setup-instructions)
- [Project Structure](#-project-structure)
- [Key Technical Decisions](#-key-technical-decisions)
- [Trade-offs & Compromises](#-trade-offs--compromises)
- [Known Limitations](#-known-limitations)
- [Environment Configuration](#-environment-configuration)
- [Dependencies](#-dependencies)

---

## ✨ Features

### Core Features
- **Dashboard Overview**
  - Real-time balance summary (income, expenses, savings)
  - Quick statistics with animated counters
  - Recent transactions list with pull-to-refresh
  - Category-wise spending breakdown
  - Shimmer loading effects

- **Transaction Management**
  - Add, edit, and delete transactions
  - Filter by category, type, and date range
  - Search transactions
  - Pagination with infinite scroll
  - Optimistic updates for instant feedback
  - Offline support with automatic sync

- **Analytics & Insights**
  - Interactive spending trend charts (fl_chart)
  - Category breakdown visualization
  - Budget progress tracking
  - Monthly/Weekly/Yearly views
  - Export-ready data summaries

### Technical Features
- **State Management**: BLoC pattern with event transformation
- **Offline-First**: Local caching with Hive + automatic sync
- **Connectivity Handling**: Real-time network status monitoring
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Multi-language Support**: English and Bengali (i18n/l10n)
- **Theme Support**: Light/Dark mode with smooth transitions
- **Responsive Design**: Adaptive layouts for phones and tablets
- **Animations**: 60 FPS hero animations, page transitions, and micro-interactions

---

## 📱 Screenshots

> **Note**: Add screenshots to `assets/images/screenshots/` directory:
> - `dashboard_light.png` - Dashboard in light mode
> - `dashboard_dark.png` - Dashboard in dark mode
> - `transactions_list.png` - Transaction list with filters
> - `add_transaction.png` - Add/Edit transaction screen
> - `analytics.png` - Analytics charts
> - `offline_mode.png` - Offline indicator

<!-- Uncomment when screenshots are added
<p align="center">
  <img src="assets/images/screenshots/dashboard_light.png" width="250" alt="Dashboard Light"/>
  <img src="assets/images/screenshots/transactions_list.png" width="250" alt="Transactions"/>
  <img src="assets/images/screenshots/analytics.png" width="250" alt="Analytics"/>
</p>
-->

---

## 🏗 Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────┐
│              Presentation Layer                  │
│  (UI, BLoCs, Screens, Widgets)                  │
│  • State management with BLoC                   │
│  • UI components and animations                 │
│  • Navigation with GoRouter                     │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│               Domain Layer                       │
│  (Entities, Use Cases, Repository Interfaces)   │
│  • Business logic                               │
│  • Platform-independent                         │
│  • No external dependencies                     │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│                Data Layer                        │
│  (Repository Impl, Data Sources, Models)        │
│  • Remote data source (API)                     │
│  • Local data source (Hive)                     │
│  • Data transformation                          │
└─────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### Presentation Layer
- **BLoCs**: Handle state management and business events
- **Screens**: Compose UI from widgets
- **Widgets**: Reusable UI components
- **Navigation**: Route management with GoRouter

#### Domain Layer
- **Entities**: Core business models (Transaction, Category, BalanceSummary)
- **Use Cases**: Single-responsibility business operations
- **Repository Interfaces**: Abstract data access contracts

#### Data Layer
- **Models**: Serializable data structures with Freezed
- **Data Sources**: Remote (Dio) and Local (Hive)
- **Repositories**: Implement domain interfaces, handle caching strategy

### State Management Pattern

**BLoC (Business Logic Component)**:
```dart
Event → BLoC → State
  ↓       ↓       ↓
UI    Business  UI Update
Input  Logic
```

**Key Features**:
- Event transformation (debounce, throttle, restartable)
- Optimistic updates for better UX
- Comprehensive error handling
- Offline-first with mutation queue

---

## 🚀 Setup Instructions

### Prerequisites

- **Flutter SDK**: 3.24 or higher ([Install Guide](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: 3.9 or higher (included with Flutter)
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Git**: For version control

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Haraprosad/techcare-flutter-assessment-haraprosad.git
   cd techcare_assessment_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (models, dependency injection)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure environment files**
   
   Create environment configuration files in the root directory:

   **`.env.development`**:
   ```env
   APP_NAME=TechCare Dev
   BASE_URL=http://localhost:3000
   IMAGE_BASE_URL=http://localhost:3000/images
   ENVIRONMENT=DEVELOPMENT
   ```

   **`.env.staging`**:
   ```env
   APP_NAME=TechCare Staging
   BASE_URL=https://staging-api.example.com
   IMAGE_BASE_URL=https://staging-api.example.com/images
   ENVIRONMENT=STAGING
   ```

   **`.env.production`**:
   ```env
   APP_NAME=TechCare
   BASE_URL=https://api.example.com
   IMAGE_BASE_URL=https://api.example.com/images
   ENVIRONMENT=PRODUCTION
   ```

5. **Set up JSON Server (for local development)**
   
   Install JSON Server globally:
   ```bash
   npm install -g json-server
   ```

   Start the mock API server:
   ```bash
   json-server --watch db.json --port 3000
   ```

   The API will be available at `http://localhost:3000`

### Running the App

#### Development Mode
```bash
flutter run --flavor development --target lib/flavors/main_development.dart
```

#### Staging Mode
```bash
flutter run --flavor staging --target lib/flavors/main_staging.dart
```

#### Production Mode
```bash
flutter run --flavor production --target lib/flavors/main_production.dart
```

#### Quick Run (default development)
```bash
flutter run
```

### Building for Release

#### Android APK
```bash
flutter build apk --flavor production --target lib/flavors/main_production.dart
```

#### Android App Bundle
```bash
flutter build appbundle --flavor production --target lib/flavors/main_production.dart
```

#### iOS
```bash
flutter build ios --flavor production --target lib/flavors/main_production.dart
```

---

## 📂 Project Structure

```
lib/
├── core/                           # Core functionality shared across features
│   ├── constants/                  # App-wide constants
│   │   ├── asset_constants.dart
│   │   ├── env_constants.dart
│   │   └── string_constants.dart
│   ├── di/                        # Dependency Injection
│   │   ├── injection.dart         # GetIt setup
│   │   ├── injection.config.dart  # Generated
│   │   └── register_module.dart   # External dependencies
│   ├── localization/              # i18n support
│   │   ├── bloc/                  # Locale state management
│   │   └── l10n/                  # Generated localizations
│   ├── logger/                    # Logging utility
│   ├── navigation/                # Navigation utilities
│   ├── network/                   # Networking layer
│   │   ├── config/                # Dio setup & interceptors
│   │   ├── cubit/                 # Connectivity monitoring
│   │   ├── error_handling/        # Error handler
│   │   ├── queue/                 # Mutation queue for offline
│   │   └── services/              # Auto-sync, connection manager
│   ├── router/                    # GoRouter configuration
│   ├── storage/                   # Local storage (Hive, SharedPreferences, Secure)
│   ├── theme/                     # Theme system
│   │   ├── bloc/                  # Theme state management
│   │   ├── colors/                # Color schemes
│   │   ├── styles/                # Text styles, decorations
│   │   └── typography/            # Font definitions
│   ├── utils/                     # Helper utilities
│   └── widgets/                   # Shared widgets
│
├── features/                      # Feature modules (Clean Architecture)
│   ├── analytics/
│   │   ├── data/
│   │   │   ├── datasources/       # Local & Remote data sources
│   │   │   ├── models/            # Freezed data models
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/          # Business use cases
│   │   └── presentation/
│   │       ├── bloc/              # BLoC state management
│   │       ├── pages/             # Screen widgets
│   │       └── widgets/           # Feature-specific widgets
│   │
│   ├── dashboard/                 # Same structure as analytics
│   ├── transactions/              # Same structure as analytics
│   ├── categories/                # Same structure as analytics
│   └── splash/                    # Splash screen
│
├── flavors/                       # Environment configuration
│   ├── app_initializer.dart       # App initialization logic
│   ├── env_config.dart            # Environment config manager
│   ├── environment.dart           # Environment enum
│   ├── main_development.dart      # Dev entry point
│   ├── main_staging.dart          # Staging entry point
│   └── main_production.dart       # Production entry point
│
└── main.dart                      # App widget and setup

test/
├── core/                          # Core tests
├── features/                      # Feature tests
└── widget_test.dart               # Sample widget test
```

---

## 🎯 Key Technical Decisions

### 1. **Clean Architecture**
**Why?** Ensures separation of concerns, testability, and maintainability. Business logic is independent of UI and data sources.

**Implementation**:
- Domain layer contains only business logic (no Flutter/Dart dependencies)
- Data layer handles API and local storage
- Presentation layer manages UI and state

### 2. **BLoC Pattern**
**Why?** Predictable state management, testable business logic, and clear separation of UI and logic.

**Features Used**:
- `debounce`: Search input to reduce API calls
- `throttle`: Button taps to prevent double submission
- `restartable`: Cancel ongoing operations when new ones start
- `sequential`: Ensure operations execute in order

### 3. **Dependency Injection with GetIt + Injectable**
**Why?** Automatic dependency registration, easy testing with mocks, and loose coupling.

**Benefits**:
- Code generation reduces boilerplate
- Singleton, LazySingleton, Factory scopes
- Easy to swap implementations for testing

### 4. **Offline-First Architecture**
**Why?** Better UX, works without internet, instant feedback.

**Strategy**:
- Local cache as source of truth (Hive)
- Optimistic updates for mutations
- Background sync when online
- Mutation queue for failed requests

### 5. **Freezed for Data Models**
**Why?** Immutability, code generation, pattern matching, and type safety.

**Features**:
- Immutable models
- copyWith methods
- Equality comparison
- JSON serialization

### 6. **GoRouter for Navigation**
**Why?** Declarative routing, deep linking support, type-safe navigation.

**Features**:
- Named routes
- Path parameters
- Query parameters
- Redirect guards
- Nested navigation

### 7. **Multi-Environment Setup**
**Why?** Separate configurations for dev/staging/production.

**Implementation**:
- Different API endpoints per environment
- Environment-specific settings
- Flavor-based builds

### 8. **Comprehensive Error Handling**
**Why?** Better user experience with actionable error messages.

**Layers**:
- Network layer: HTTP error codes
- Repository layer: Domain-specific errors
- BLoC layer: State-based error handling
- UI layer: User-friendly messages with retry actions

---

## ⚖️ Trade-offs & Compromises

### 1. **Mock API vs Real Backend**
**Trade-off**: Using JSON Server instead of real backend  
**Reasoning**: Focuses assessment on Flutter skills, faster development, no backend dependency  
**Impact**: Some features like authentication are simplified

### 2. **Local Storage Complexity**
**Trade-off**: Using Hive for complex caching instead of simple key-value storage  
**Reasoning**: Better performance for large datasets, type-safe queries  
**Impact**: More setup required, larger app size

### 3. **Code Generation**
**Trade-off**: Heavy reliance on code generation (Freezed, Injectable, JSON Serializable)  
**Reasoning**: Reduces boilerplate, enforces patterns, prevents errors  
**Impact**: Longer initial build times, requires build_runner knowledge

### 4. **Over-Engineering for Assessment**
**Trade-off**: Production-grade architecture for assessment project  
**Reasoning**: Demonstrates expertise, shows best practices, scalable foundation  
**Impact**: More code than minimal implementation would require

### 5. **Animation Performance**
**Trade-off**: Smooth animations vs battery consumption  
**Reasoning**: Better UX, demonstrates animation skills  
**Impact**: Slightly higher battery usage, more GPU utilization

### 6. **Testing Coverage**
**Trade-off**: Focused on BLoC/use case tests over integration tests  
**Reasoning**: Time constraints, core logic coverage  
**Impact**: UI tests may be limited

---

## 🚧 Known Limitations

### Current Limitations

1. **Authentication System**
   - No real user authentication implemented
   - Mock login/logout functionality
   - No JWT token management
   - **Reason**: Focus on core finance features, backend not provided

2. **Image Upload**
   - Receipt/attachment upload not implemented
   - No image compression
   - **Reason**: Would require storage backend setup

3. **Push Notifications**
   - No budget alerts or reminders
   - No transaction notifications
   - **Reason**: Requires backend notification service

4. **Data Export**
   - CSV/PDF export not implemented
   - No email sharing
   - **Reason**: Time constraints, would need additional libraries

5. **Advanced Analytics**
   - No predictive analytics
   - No spending forecasts
   - Limited comparison features
   - **Reason**: Would require ML models

6. **Biometric Authentication**
   - No fingerprint/face unlock
   - **Reason**: Additional platform-specific setup required

7. **Multi-Currency Support**
   - Single currency (BDT) only
   - No exchange rate handling
   - **Reason**: Would require external API integration

8. **Social Features**
   - No shared budgets
   - No expense splitting
   - **Reason**: Out of scope for personal finance tracker

### Future Enhancements

- [ ] Add biometric authentication
- [ ] Implement receipt scanning with OCR
- [ ] Add budget alerts and notifications
- [ ] Export data to CSV/PDF
- [ ] Multi-currency support
- [ ] Recurring transactions
- [ ] Expense splitting
- [ ] Bank account integration
- [ ] AI-powered insights
- [ ] Widget for home screen

---

## 🌍 Environment Configuration

The app supports three environments with different configurations:

| Environment | API Endpoint | Use Case |
|-------------|-------------|----------|
| **Development** | `http://localhost:3000` | Local development with JSON Server |
| **Staging** | `https://staging-api.example.com` | QA testing before production |
| **Production** | `https://api.example.com` | Live app with real backend |

### Environment Variables

Create `.env.{environment}` files with:

```env
APP_NAME=Your App Name
BASE_URL=https://your-api-endpoint.com
IMAGE_BASE_URL=https://your-cdn.com/images
ENVIRONMENT=DEVELOPMENT|STAGING|PRODUCTION
```

### Accessing Environment Config

```dart
import 'package:techcare_assessment_app/flavors/env_config.dart';

// Get current environment
final env = EnvConfig.instance.env;

// Get base URL
final apiUrl = EnvConfig.instance.baseUrl;

// Check environment
if (EnvConfig.instance.env.isDevelopment) {
  // Development-specific code
}
```

---

## 📦 Dependencies

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | State management |
| `get_it` | ^8.2.0 | Dependency injection |
| `injectable` | ^2.5.2 | DI code generation |
| `freezed` | ^2.5.7 | Immutable models |
| `dio` | ^5.9.0 | HTTP client |
| `go_router` | ^16.2.4 | Navigation |
| `hive` | ^2.2.3 | Local database |
| `fl_chart` | ^1.1.1 | Data visualization |
| `shimmer` | ^3.0.0 | Loading effects |
| `intl` | ^0.20.2 | Internationalization |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing framework |
| `bloc_test` | ^10.0.0 | BLoC testing |
| `mocktail` | ^1.0.4 | Mocking |
| `build_runner` | ^2.4.13 | Code generation |
| `flutter_lints` | ^5.0.0 | Lint rules |

### Full Dependency List

See [pubspec.yaml](pubspec.yaml) for complete dependency list with versions.

---

## 🤝 Contributing

This is an assessment project and not open for contributions. However, feel free to:
- Report bugs by creating issues
- Suggest improvements
- Fork for learning purposes

---

## 📄 License

This project is created for assessment purposes. All rights reserved.

---

## 👨‍💻 Developer

**Haraprosad**  
Senior Flutter Developer

---

## 📞 Support

For questions or issues:
- Create an issue in the repository
- Contact: [Your Email]

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **BLoC Library** for predictable state management
- **GetIt & Injectable** for clean dependency injection
- **Freezed** for reducing boilerplate
- **FL Chart** for beautiful charts

---

<div align="center">
  
  **Built with ❤️ using Flutter**
  
  [⬆ Back to Top](#techcare-personal-finance-tracker)

</div>