# PCLL Flutter Project File Map

**Generated**: December 18, 2025  
**Total Files**: 75+ files (excluding build artifacts)

---

## 📁 Project Root

```
pcll_flutter/
├── .env                          # Environment variables (gitignored)
├── .env.example                  # Environment variables template
├── .gitignore                    # Git ignore rules
├── .metadata                     # Flutter metadata
├── analysis_options.yaml         # Dart analysis configuration
├── pubspec.yaml                  # Dependencies & project config
├── pubspec.lock                  # Locked dependency versions
├── README.md                     # Main project documentation
├── PROJECT_STRUCTURE.md          # Quick navigation guide
├── PROJECT_FILE_MAP.md          # This file - complete file listing
├── CONSOLIDATION_GUIDE.md       # File organization recommendations
├── ENV_SETUP.md                 # Environment variables setup guide
├── QUICKSTART_ENV.md            # Quick start for .env configuration
└── pcll_app.iml                 # IntelliJ project file
```

---

## 📚 Documentation (`docs/`)

```
docs/
├── PCLL_v0.1_Specification.md          # Complete app specification
├── azure_openai_integration.md         # Azure integration guide
├── AZURE_INTEGRATION_SUMMARY.md        # Azure setup summary
├── azure_implementation_checklist.md   # Implementation checklist
└── azure_output_examples.md            # Sample Azure responses
```

**Purpose**: Technical documentation, specifications, and integration guides.

---

## 🎯 Main Application (`lib/`)

### Entry Point

```
lib/
└── main.dart                     # App entry point, initialization
```

### Core - Configuration (`lib/core/config/`)

```
lib/core/config/
└── env_config.dart              # Environment variables service
```

**Purpose**: Centralized configuration management using .env files.

### Core - Constants (`lib/core/constants/`)

```
lib/core/constants/
└── vocabulary.dart              # Text constants, terminology
```

**Purpose**: Shared constants and application vocabulary.

### Core - Models (`lib/core/models/`)

```
lib/core/models/
├── models.dart                  # Main models barrel file (LedgerEntry, etc.)
├── user_profile.dart            # User profile model
├── entry_preset.dart            # Quick-log preset model
└── azure_models.dart            # Azure OpenAI models
```

**Purpose**: Data models representing app entities.

**Key Models**:

- `LedgerEntry` - Daily cognitive load entry
- `UserProfile` - User account data
- `EntryPreset` - Pre-configured entry templates
- `AzureInsightResponse` - AI-generated insights

### Core - Providers (`lib/core/providers/`)

```
lib/core/providers/
├── providers.dart               # Barrel file exporting all providers
├── auth_provider.dart           # Authentication state
├── ledger_provider.dart         # Ledger entries & calculations
├── profile_provider.dart        # User profile management
├── settings_provider.dart       # App settings & preferences
└── tutorial_provider.dart       # Tutorial/onboarding state
```

**Purpose**: State management using Provider pattern.

**Responsibilities**:

- `AuthProvider` - Login, logout, account creation
- `LedgerProvider` - Entry CRUD, balance calculations
- `ProfileProvider` - Profile data management
- `SettingsProvider` - Theme, accessibility, Azure config
- `TutorialProvider` - First-time user guidance

### Core - Services (`lib/core/services/`)

```
lib/core/services/
├── services.dart                      # Barrel file exporting all services
├── database_service.dart              # SQLite persistence
├── azure_insights_service.dart        # Azure OpenAI integration (optional)
├── calibration_service.dart           # Load value calculations
├── insight_service.dart               # Rule-based pattern detection
├── pattern_observation_service.dart   # Behavioral pattern analysis
└── preset_service.dart                # Quick-log preset management
```

**Purpose**: Business logic and external integrations.

**Key Services**:

- `DatabaseService` - Local SQLite database
- `AzureInsightsService` - AI insights (optional)
- `InsightService` - Pattern detection algorithms
- `CalibrationService` - Cognitive load calculations

### Core - Theme (`lib/core/theme/`)

```
lib/core/theme/
└── app_theme.dart               # Colors, typography, spacing constants
```

**Purpose**: Design system and theming.

**Contains**:

- `PCLLColors` - Color palette (light/dark)
- `PCLLTypography` - Text styles
- `PCLLSpacing` - Spacing constants (xs, sm, md, lg, xl, xxl)
- `PCLLTheme` - ThemeData configurations

---

## 🎨 Features (`lib/features/`)

### Authentication (`lib/features/auth/`)

```
lib/features/auth/
├── login_screen.dart            # Login screen
└── create_account_screen.dart   # Account creation screen
```

**Purpose**: User authentication (offline email/password).

### Entry Management (`lib/features/entry/`)

```
lib/features/entry/
├── daily_entry_screen.dart      # 6-question daily entry flow
└── edit_entry_screen.dart       # Edit past entries
```

**Purpose**: Daily cognitive load entry and editing.

**Features**:

- 6-question assessment flow
- Radial sliders for smooth input
- Real-time balance preview
- Edit with cascade recalculation

### Home & Dashboard (`lib/features/home/`)

```
lib/features/home/
└── home_screen.dart             # Main dashboard
```

**Purpose**: Balance display, today's summary, quick navigation.

**Shows**:

- Current balance (large, prominent)
- 7-day trend chart
- Today's ledger breakdown
- Quick action buttons

### History & Ledger (`lib/features/history/`)

```
lib/features/history/
└── history_screen.dart          # Historical entries view
```

**Purpose**: Browse, search, and manage past entries.

### Trends & Analysis (`lib/features/trends/`)

```
lib/features/trends/
└── trends_screen.dart           # Weekly trends & insights
```

**Purpose**: Trend visualization and rule-based insights.

### Patterns (`lib/features/patterns/`)

```
lib/features/patterns/
└── pattern_report_screen.dart   # Pattern detection report
```

**Purpose**: Behavioral pattern analysis and observations.

### User Profile (`lib/features/profile/`)

```
lib/features/profile/
└── profile_edit_screen.dart     # Edit user profile
```

**Purpose**: Update profile information and preferences.

### Settings (`lib/features/settings/`)

```
lib/features/settings/
└── settings_screen.dart         # App settings & configuration
```

**Purpose**: Theme, accessibility, Azure setup, data management.

**Sections**:

- Appearance (dark mode, text scaling)
- Accessibility (high contrast, reduce motion)
- Azure OpenAI (optional configuration)
- Data management (export, backup)

### Info & Help (`lib/features/info/`)

```
lib/features/info/
└── how_this_works_screen.dart   # Transparency screen
```

**Purpose**: Explain app methodology and calculations.

### Splash (`lib/features/splash/`)

```
lib/features/splash/
└── splash_screen.dart           # App startup screen
```

**Purpose**: Loading screen during initialization.

### Disclaimer (`lib/features/disclaimer/`)

```
lib/features/disclaimer/
└── disclaimer_screen.dart       # Medical disclaimer
```

**Purpose**: Not a diagnostic tool disclaimer.

### Feature Barrel (`lib/features/`)

```
lib/features/
└── features.dart                # Barrel file exporting all features
```

---

## 🧩 Shared Components (`lib/shared/widgets/`)

```
lib/shared/widgets/
├── widgets.dart                 # Barrel file exporting all widgets
├── balance_display.dart         # Large balance number display
├── ledger_card.dart            # Daily ledger summary card
├── calm_balance_chart.dart     # 7-day trend chart
├── radial_slider.dart          # Circular slider widget
├── tutorial_overlay.dart       # Onboarding tooltips
└── background_patterns.dart    # Decorative background elements
```

**Purpose**: Reusable UI components used across features.

**Key Widgets**:

- `BalanceDisplay` - 72px balance with state indicator
- `LedgerCard` - Withdrawals/deposits summary
- `CalmBalanceChart` - 7-day line chart
- `RadialSlider` - Touch-friendly circular input
- `TutorialOverlay` - Context-sensitive help

---

## 💡 Examples (`lib/examples/`)

```
lib/examples/
└── azure_integration_example.dart    # Sample Azure integration code
```

**Purpose**: Reference implementation for Azure insights in trends screen.

---

## 🧪 Tests (`test/`)

```
test/
└── widget_test.dart             # Basic widget tests
```

**Purpose**: Unit and widget tests (currently minimal).

---

## 🪟 Windows Platform (`windows/`)

```
windows/
├── CMakeLists.txt               # CMake build configuration
├── .gitignore                   # Windows-specific ignores
└── runner/                      # Windows runner application
    ├── CMakeLists.txt
    ├── main.cpp                 # Windows entry point
    ├── flutter_window.cpp/h     # Flutter window wrapper
    ├── win32_window.cpp/h       # Win32 window implementation
    ├── utils.cpp/h              # Helper utilities
    ├── resource.h               # Resource definitions
    ├── Runner.rc                # Resource script
    ├── runner.exe.manifest      # Application manifest
    └── resources/
        └── app_icon.ico         # Application icon
```

**Purpose**: Windows desktop platform implementation.

---

## 📊 Project Statistics

### File Counts by Category

| Category          | Count | Purpose                  |
| ----------------- | ----- | ------------------------ |
| **Screens**       | 13    | UI screens/features      |
| **Providers**     | 5     | State management         |
| **Services**      | 6     | Business logic           |
| **Models**        | 4     | Data structures          |
| **Widgets**       | 6     | Reusable components      |
| **Core**          | 3     | Config, constants, theme |
| **Documentation** | 9     | Guides and specs         |
| **Platform**      | 13    | Windows implementation   |
| **Config**        | 6     | Project configuration    |

**Total Dart Files**: ~50 files  
**Total Documentation**: ~9 files  
**Total Project Files**: ~75 files

---

## 🗂️ File Organization Pattern

### Barrel Files (Index Exports)

For easier imports, several directories use barrel files:

- `lib/core/providers/providers.dart` → All providers
- `lib/core/services/services.dart` → All services
- `lib/features/features.dart` → All feature screens
- `lib/shared/widgets/widgets.dart` → All shared widgets

**Usage**:

```dart
// Instead of:
import 'package:pcll_app/core/providers/auth_provider.dart';
import 'package:pcll_app/core/providers/ledger_provider.dart';

// Use:
import 'package:pcll_app/core/providers/providers.dart';
```

### Feature-Based Organization

Each feature is self-contained with its screen(s):

```
lib/features/<feature_name>/
└── <feature>_screen.dart
```

### Core Layer Separation

```
lib/core/
├── config/      # Configuration & environment
├── constants/   # Shared constants
├── models/      # Data structures
├── providers/   # State management
├── services/    # Business logic
└── theme/       # Design system
```

---

## 🔍 Quick Navigation

### Need to...

**Add a new screen?**
→ `lib/features/<category>/<name>_screen.dart`

**Modify theme/colors?**
→ `lib/core/theme/app_theme.dart`

**Change business logic?**
→ `lib/core/services/<service_name>.dart`

**Update data models?**
→ `lib/core/models/models.dart`

**Adjust state management?**
→ `lib/core/providers/<provider_name>.dart`

**Add reusable widget?**
→ `lib/shared/widgets/<widget_name>.dart`

**Configure environment?**
→ `.env` and `lib/core/config/env_config.dart`

**Update documentation?**
→ `docs/` or root-level `.md` files

---

## 🎯 Key Entry Points

### For Users

1. **App Start** → `lib/main.dart`
2. **First Screen** → `lib/features/splash/splash_screen.dart`
3. **Login** → `lib/features/auth/login_screen.dart`
4. **Main Screen** → `lib/features/home/home_screen.dart`

### For Developers

1. **Configuration** → `.env` and `pubspec.yaml`
2. **State Management** → `lib/core/providers/`
3. **Database** → `lib/core/services/database_service.dart`
4. **Design System** → `lib/core/theme/app_theme.dart`
5. **Documentation** → `docs/PCLL_v0.1_Specification.md`

---

## 📝 Notes

### Gitignored Files

- `.env` - Contains sensitive API keys
- `build/` - Build artifacts
- `.dart_tool/` - Dart tooling cache
- `.idea/` - IDE configuration
- Backup folders - Version snapshots

### Environment Files

- `.env` - Your actual configuration (gitignored)
- `.env.example` - Template for team members
- Uses `flutter_dotenv` package for loading

### Offline-First Architecture

- SQLite database (`database_service.dart`)
- No internet required for core features
- Azure insights are optional enhancements

---

**Last Updated**: December 18, 2025  
**Project Version**: 1.0.0+1  
**Flutter SDK**: >=3.0.0 <4.0.0
