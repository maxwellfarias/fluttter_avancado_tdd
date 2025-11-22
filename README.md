# Flutter Advanced - TDD & Clean Architecture

![Flutter Version](https://img.shields.io/badge/Flutter-3.27.0-02569B?logo=flutter)
![Dart Version](https://img.shields.io/badge/Dart-3.5.4+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Tests](https://img.shields.io/badge/Tests-14%20files-success)

Reference Flutter project demonstrating practical application of **Test-Driven Development (TDD)** with **Clean Architecture**, following SOLID principles and software engineering best practices.

## 📋 About the Project

This project implements an application for viewing sports events (football/soccer), displaying information about player confirmations, positions, and participation status. The main focus is on **architecture**, **testability**, and **code quality**.

### Key Features

- ✅ **100% tested** with TDD (14 test files)
- 🏗️ **Clean Architecture** with clear layer separation
- 🎯 **MVP Pattern** in the presentation layer
- 🔄 **Reactive Programming** with RxDart
- 💾 **Local cache** with automatic fallback
- 🌐 **REST API integration**
- 🧩 **Dependency Injection** with Factory Pattern
- 📱 **Multi-platform support** (iOS, Android, Web, Desktop)

## 🏛️ Architecture

The project follows Clean Architecture principles divided into 4 layers:

```
┌─────────────────────────────────────────┐
│          UI Layer (Flutter)             │
│   - Pages (StatefulWidget)              │
│   - Components (StatelessWidget)        │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Presentation Layer (MVP)           │
│   - Presenters (Business Logic)         │
│   - ViewModels (UI State)               │
│   - RxDart Streams                      │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│     Infrastructure Layer (Data)         │
│   - API Repositories                    │
│   - Cache Repositories                  │
│   - Adapters (HTTP, Cache)              │
│   - Mappers (JSON ↔ Entity)             │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│       Domain Layer (Core)               │
│   - Entities (Business Models)          │
│   - Errors (Domain Exceptions)          │
│   - Interfaces (Contracts)              │
└─────────────────────────────────────────┘
```

### Design Patterns Implemented

| Pattern | Application |
|---------|-------------|
| **MVP** | Separation between presentation logic and UI |
| **Repository** | Data source abstraction |
| **Factory** | Dependency injection in composition root |
| **Adapter** | Wrapper for external libraries (HTTP, Cache) |
| **Strategy** | Multiple implementations (API vs Cache) |
| **Observer** | RxDart Subjects for state management |
| **Sealed Class** | Type-safe error handling |

## 📁 Folder Structure

```
lib/
├── domain/              # Domain layer (business rules)
│   └── entities/        # Pure entities
│
├── infra/               # Infrastructure layer (data)
│   ├── api/            # HTTP communication
│   ├── cache/          # Local cache
│   ├── mappers/        # Data transformation
│   └── repositories/   # Repository implementations
│
├── presentation/        # Presentation layer (MVP)
│   ├── presenters/     # Presenter interfaces
│   └── rx/             # RxDart implementation
│
├── ui/                  # Interface layer
│   ├── pages/          # App screens
│   └── components/     # Reusable components
│
├── main/                # Composition root
│   ├── main.dart       # Entry point
│   └── factories/      # Factories for DI
│
└── test/                # Tests (mirrors lib/ structure)
    ├── domain/
    ├── infra/
    ├── presentation/
    ├── ui/
    ├── e2e/            # End-to-end tests
    └── mocks/          # Test doubles (spies, fakes)
```

## 🚀 Getting Started

### Prerequisites

- Flutter 3.27.0 or higher
- Dart 3.5.4 or higher
- FVM (recommended for version management)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/flutter_avancado_tdd.git
cd flutter_avancado_tdd
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the mock backend (optional, for testing with API):
```bash
cd backend
npm install
npm start
```

4. Run the application:
```bash
flutter run
```

## 🧪 Testing

The project has **complete test coverage** following TDD methodology.

### Run all tests:
```bash
flutter test
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Test Structure

| Type | Quantity | Description |
|------|----------|-------------|
| **Unit Tests** | 8 | Tests for mappers, repositories, adapters |
| **Widget Tests** | 5 | Tests for components and pages |
| **E2E Tests** | 1 | Complete integration test |

**Testing Strategies:**
- ✅ Spy Pattern for call verification
- ✅ Fake Data for entity testing
- ✅ Stream testing with `expectLater`
- ✅ Widget testing with `tester.pumpWidget`
- ✅ No mock frameworks (Mockito) - custom spies

## 📦 Main Dependencies

### Production
- `http: ^1.2.2` - HTTP client
- `rxdart: ^0.28.0` - Reactive programming
- `flutter_cache_manager: ^3.4.1` - Cache management
- `dartx: ^1.2.0` - Useful Dart extensions
- `awesome_flutter_extensions: ^1.3.0` - UI helpers

### Development
- `flutter_test` - Testing framework
- `flutter_lints: ^4.0.0` - Lint rules

## 🔄 Data Flow

```
User Interaction
      ↓
   UI Page (StreamBuilder)
      ↓
   Presenter (RxDart)
      ↓
   Repository (API + Cache Fallback)
      ├→ HTTP Adapter → REST API
      └→ Cache Adapter → Local Storage
```

### Cache Strategy

1. **Try fetching from API** first
2. If successful: **save to cache**
3. If fails: **fetch from cache** (fallback)
4. Display data or error to user

## 🎨 Implemented Features

### Next Event Screen
- ✅ Event loading by group
- ✅ Player display by category:
  - Confirmed goalkeepers
  - Confirmed field players
  - Players who declined
  - Players with no response
- ✅ Avatar with photo or automatic initials
- ✅ Position translation to PT-BR
- ✅ Confirmation status indicator
- ✅ Pull-to-refresh
- ✅ Error handling with retry
- ✅ Loading states

## 🔧 Configuration

### FVM (Flutter Version Management)

The project uses FVM to ensure Flutter version consistency:

```json
{
  "flutter": "3.27.0"
}
```

### Editor Config

The `.editorconfig` file ensures consistent formatting across editors.

## 📚 Advanced Concepts Demonstrated

### 1. Clean Architecture
- Clear separation of concerns
- Dependencies pointing inward (domain)
- Independent and testable layers

### 2. Test-Driven Development (TDD)
- Red → Green → Refactor
- Tests written before implementation
- High test coverage

### 3. SOLID Principles
- **S**ingle Responsibility: Classes with single responsibility
- **O**pen/Closed: Extensible via interfaces
- **L**iskov Substitution: Well-defined contracts
- **I**nterface Segregation: Specific interfaces
- **D**ependency Inversion: Dependency on abstractions

### 4. Reactive Programming
- Streams as single source of truth
- BehaviorSubject for reactive state
- Declarative programming with StreamBuilder

### 5. Error Handling
- Sealed classes for type-safe errors
- Specific handling by error type (401, unexpected)
- Resilient UI with fallbacks

## 🤝 Contributing

Contributions are welcome! This is an educational project, so feel free to:

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is under the MIT license. See the `LICENSE` file for more details.

## 👨‍💻 Author

**Maxwell Farias**

## 🙏 Acknowledgments

This project was developed as study material to demonstrate best practices in advanced Flutter development, including:
- Clean Architecture
- Test-Driven Development
- Reactive Programming
- Dependency Injection
- Design Patterns

---

**⭐ If this project was helpful to you, consider giving it a star!**