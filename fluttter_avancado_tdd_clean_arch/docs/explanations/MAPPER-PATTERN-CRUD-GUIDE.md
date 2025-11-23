# Mapper Pattern & Complete CRUD Implementation Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Mapper Pattern Deep Dive](#mapper-pattern-deep-dive)
3. [Anti-Corruption Layer Concept](#anti-corruption-layer-concept)
4. [Step-by-Step Mapper Creation](#step-by-step-mapper-creation)
5. [Complete CRUD Example: Team Management](#complete-crud-example-team-management)
6. [SOLID Principles in Mappers](#solid-principles-in-mappers)
7. [Best Practices](#best-practices)

---

## Introduction

This guide provides an in-depth exploration of the **Mapper Pattern** and demonstrates how to implement a complete CRUD (Create, Read, Update, Delete) operation following Clean Architecture principles.

### What You'll Learn

- 🔄 **Mapper Pattern**: How to transform external data (JSON) into internal domain entities
- 🛡️ **Anti-Corruption Layer**: How mappers protect your domain from external changes
- 📋 **Complete CRUD**: Full implementation of Create, Read, Update, and Delete operations
- 🏗️ **Architecture**: How mappers fit into Clean Architecture
- 💡 **SOLID Principles**: How the mapper design follows SOLID principles

### Prerequisites

Before starting, you should understand:
- Basic Dart syntax and object-oriented programming
- JSON format and REST APIs
- The 4-layer Clean Architecture structure (Domain, Infrastructure, Presentation, UI)

---

## Mapper Pattern Deep Dive

### What is the Mapper Pattern?

**Definition**: The Mapper Pattern is a structural design pattern that provides a mechanism to convert data from one form to another while keeping the conversion logic isolated and reusable.

**Real-world analogy**: Think of a **translator** at the United Nations. The translator converts speeches from one language (JSON from API) to another language (Domain entities your app understands), allowing people who speak different languages to communicate effectively.

### Why Do We Need Mappers?

#### Problem Without Mappers

Imagine your repository directly using JSON from the API:

```dart
// ❌ BAD: Repository tightly coupled to API format
class LoadEventRepository {
  Future<Map<String, dynamic>> loadEvent() async {
    final response = await http.get('https://api.com/events');
    final json = jsonDecode(response.body);
    return json;  // Returning raw JSON!
  }
}

// Presenter must know API structure
class EventPresenter {
  Future<void> loadEvent() async {
    final json = await repository.loadEvent();
    final groupName = json['groupName'];  // Presenter knows API field names!
    final date = DateTime.parse(json['date']);  // Parsing logic in presenter!
    final players = (json['players'] as List).map((p) => {
      'name': p['name'],
      'position': p['position']
    }).toList();
  }
}
```

**Problems**:
1. ❌ Presenter knows about API structure (tight coupling)
2. ❌ Parsing logic scattered everywhere
3. ❌ API changes break multiple layers
4. ❌ No type safety
5. ❌ Hard to test (need to mock JSON structure)

#### Solution With Mappers

```dart
// ✅ GOOD: Mapper isolates transformation logic
class NextEventMapper implements Mapper<NextEvent> {
  @override
  NextEvent toDto(Json json) => NextEvent(
    groupName: json['groupName'],
    date: DateTime.parse(json['date']),
    players: playerMapper.toDtoList(json['players']),
  );

  @override
  Json toJson(NextEvent event) => {
    'groupName': event.groupName,
    'date': event.date.toIso8601String(),
    'players': playerMapper.toJsonArr(event.players),
  };
}

// Repository returns domain entity
class LoadEventApiRepository {
  Future<NextEvent> loadEvent() async {
    final json = await httpClient.get(url: url);
    return mapper.toDto(json);  // JSON → Domain entity
  }
}

// Presenter works with domain entities
class EventPresenter {
  Future<void> loadEvent() async {
    final event = await repository.loadEvent();  // NextEvent (type-safe!)
    final groupName = event.groupName;  // IDE autocomplete works!
    final date = event.date;  // DateTime (already parsed!)
    final players = event.players;  // List<NextEventPlayer> (type-safe!)
  }
}
```

**Benefits**:
1. ✅ Presenter doesn't know about API (loose coupling)
2. ✅ Parsing logic centralized in mapper
3. ✅ API changes only affect mapper
4. ✅ Type safety throughout
5. ✅ Easy to test (mock domain entities)

---

## Anti-Corruption Layer Concept

### What is an Anti-Corruption Layer?

**Definition**: An Anti-Corruption Layer (ACL) is a design pattern that prevents external systems from corrupting your domain model. It acts as a protective boundary between your clean domain logic and messy external services.

**Origin**: Introduced by Eric Evans in "Domain-Driven Design" (DDD).

### How Mappers Implement ACL

```
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL WORLD                           │
│  (APIs, Databases, Third-party Services)                    │
│                                                             │
│  • Field names change                                       │
│  • Data formats change                                      │
│  • API versions change                                      │
│  • Different providers, different formats                   │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              │ Raw JSON
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│              ANTI-CORRUPTION LAYER (Mappers)                │
│  ═══════════════════════════════════════════════════        │
│                                                             │
│  ┌────────────────┐    ┌────────────────┐                  │
│  │ NextEventMapper│    │ TeamMapper     │                  │
│  └────────────────┘    └────────────────┘                  │
│                                                             │
│  Responsibilities:                                          │
│  • Convert external JSON → Internal entities                │
│  • Handle API-specific quirks                               │
│  • Provide default values                                   │
│  • Validate data                                            │
│  • Adapt to API changes                                     │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              │ Domain Entities
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                           │
│  (Pure, Stable, Business Logic)                             │
│                                                             │
│  • NextEvent (immutable)                                    │
│  • Team (immutable)                                         │
│  • Business rules                                           │
│  • No knowledge of APIs                                     │
└─────────────────────────────────────────────────────────────┘
```

### Real-World Example: API Changes

#### Scenario: API Changes Field Name

**Old API Response**:
```json
{
  "group_name": "Pelada Chega+",
  "event_date": "2024-01-11T11:10:00.000Z"
}
```

**New API Response** (API team changed naming):
```json
{
  "teamName": "Pelada Chega+",
  "scheduledDate": "2024-01-11T11:10:00.000Z"
}
```

**Without Mapper (Breaks entire app)**:
```dart
// Throughout the app, code breaks:
final groupName = json['group_name'];  // ❌ Now null!
final date = DateTime.parse(json['event_date']);  // ❌ Now throws error!

// Must change code in:
// - Repository
// - Presenter
// - Tests
// - Anywhere JSON is accessed
```

**With Mapper (Only change mapper)**:
```dart
// BEFORE (old API):
@override
NextEvent toDto(Json json) => NextEvent(
  groupName: json['group_name'],  // Old field name
  date: DateTime.parse(json['event_date']),  // Old field name
);

// AFTER (new API) - ONLY CHANGE MAPPER:
@override
NextEvent toDto(Json json) => NextEvent(
  groupName: json['teamName'],  // Updated field name
  date: DateTime.parse(json['scheduledDate']),  // Updated field name
);

// Domain entity unchanged:
final class NextEvent {
  final String groupName;  // Still the same!
  final DateTime date;  // Still the same!
}

// All other code (presenter, UI, tests) works without changes!
```

**Result**: Change isolated to 2 lines in one file (mapper), instead of hundreds of lines across dozens of files.

### Benefits of Anti-Corruption Layer

1. **Domain Protection**: Domain entities never change due to external factors
2. **Flexibility**: Easy to switch between API providers
3. **Testability**: Test domain logic without external dependencies
4. **Maintainability**: Changes isolated to specific mappers
5. **Evolution**: Domain can evolve independently from external systems

---

## Step-by-Step Mapper Creation

This section provides a detailed, beginner-friendly guide to creating mappers.

### Step 1: Understand Your Data

Before creating a mapper, analyze the data flow:

**Example**: Mapping a Player from API

**API JSON (External)**:
```json
{
  "id": "123",
  "full_name": "Cristiano Ronaldo",
  "role": "forward",
  "is_active": true,
  "joined_at": "2024-01-10T10:00:00.000Z",
  "avatar_url": "https://example.com/photo.jpg"
}
```

**Domain Entity (Internal)**:
```dart
final class Player {
  final String id;
  final String name;
  final String initials;  // Computed from name
  final String? position;
  final bool? isActive;
  final DateTime? joinedDate;
  final String? photoUrl;
}
```

**Differences to handle**:
- Field names differ: `full_name` → `name`, `role` → `position`, `avatar_url` → `photoUrl`
- Date parsing: String → DateTime
- Computed field: `initials` (not in JSON, calculated from `name`)
- Optional fields: Some fields may be null

---

### Step 2: Create Type Definitions

**File**: `lib/infra/types/json.dart` (should already exist)

```dart
// Type alias for JSON objects
typedef Json = Map<String, dynamic>;

// Type alias for JSON arrays
typedef JsonArr = List<Json>;
```

**Why?**: Makes code more readable than `Map<String, dynamic>` everywhere.

---

### Step 3: Define Mapper Interfaces

**File**: `lib/infra/mappers/mapper.dart` (should already exist)

This file defines the contracts for mappers:

```dart
// Convert JSON to Domain entity
abstract interface class DtoMapper<Dto> {
  Dto toDto(Json json);
}

// Convert Domain entity to JSON
abstract interface class JsonMapper<Dto> {
  Json toJson(Dto dto);
}

// Bidirectional mapper (both directions)
abstract interface class Mapper<Dto>
    implements DtoMapper<Dto>, JsonMapper<Dto> {}

// Mixin for list conversion (JSON array → List<Entity>)
mixin DtoListMapper<Dto> implements DtoMapper<Dto> {
  List<Dto> toDtoList(dynamic arr) =>
      arr.map<Dto>((item) => toDto(item)).toList();
}

// Mixin for array conversion (List<Entity> → JSON array)
mixin JsonArrMapper<Dto> implements JsonMapper<Dto> {
  JsonArr toJsonArr(List<Dto> list) =>
      list.map((dto) => toJson(dto)).toList();
}

// Base class combining both mixins
abstract base class ListMapper<Dto>
    with DtoListMapper<Dto>, JsonArrMapper<Dto> {}
```

**Key Concepts**:

1. **Interface Segregation**: Small, focused interfaces
   - `DtoMapper`: Only JSON → Entity
   - `JsonMapper`: Only Entity → JSON
   - `Mapper`: Both directions

2. **Mixin Composition**: Reusable list transformation
   - `DtoListMapper`: Adds `toDtoList()` method
   - `JsonArrMapper`: Adds `toJsonArr()` method
   - `ListMapper`: Combines both

3. **Generic Types**: `<Dto>` makes mappers type-safe

---

### Step 4: Create Entity-Specific Mapper

Now create a mapper for your specific entity.

**File**: `lib/infra/mappers/player_mapper.dart` (new file)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';
import 'mapper.dart';

final class PlayerMapper extends ListMapper<Player> {
  // JSON → Player
  @override
  Player toDto(dynamic json) {
    // Safety: Handle potential null values
    return Player(
      id: json['id'] as String,  // Required field
      name: json['full_name'] as String,  // Map: full_name → name
      position: json['role'] as String?,  // Map: role → position (optional)
      isActive: json['is_active'] as bool?,  // Map: is_active → isActive (optional)
      joinedDate: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'])  // Parse date string
          : null,
      photoUrl: json['avatar_url'] as String?,  // Map: avatar_url → photoUrl
    );
  }

  // Player → JSON
  @override
  Json toJson(Player player) {
    return {
      'id': player.id,
      'full_name': player.name,  // Map: name → full_name
      'role': player.position,  // Map: position → role
      'is_active': player.isActive,  // Map: isActive → is_active
      'joined_at': player.joinedDate?.toIso8601String(),  // DateTime → String
      'avatar_url': player.photoUrl,  // Map: photoUrl → avatar_url
    };
  }
}
```

**Important Details**:

1. **Extends `ListMapper<Player>`**: Gets `toDtoList()` and `toJsonArr()` for free
2. **Parameter type is `dynamic`**: `jsonDecode()` returns dynamic
3. **Field mapping**: Handle name differences (`full_name` → `name`)
4. **Type casting**: Use `as String` for required, `as String?` for optional
5. **Date handling**: Use `DateTime.tryParse()` (returns null if invalid)
6. **Null safety**: Use null-aware operators (`?.`, `??`)

---

### Step 5: Handle Nested Objects

If your entity contains other entities (composition), use mapper composition.

**Example**: Team contains Players

**Domain Entities**:
```dart
final class Team {
  final String id;
  final String name;
  final List<Player> members;  // Nested entity
}
```

**TeamMapper** (with dependency injection):
```dart
final class TeamMapper implements Mapper<Team> {
  final ListMapper<Player> playerMapper;  // Injected dependency

  const TeamMapper({required this.playerMapper});

  @override
  Team toDto(Json json) => Team(
    id: json['id'],
    name: json['name'],
    members: playerMapper.toDtoList(json['members']),  // Delegate to PlayerMapper
  );

  @override
  Json toJson(Team team) => {
    'id': team.id,
    'name': team.name,
    'members': playerMapper.toJsonArr(team.members),  // Delegate to PlayerMapper
  };
}
```

**Why inject playerMapper?**
- ✅ Single Responsibility: TeamMapper doesn't know how to map Players
- ✅ Testability: Can inject mock PlayerMapper for testing
- ✅ Reusability: PlayerMapper used elsewhere

---

### Step 6: Create Mapper Factory

**File**: `lib/main/factories/infra/mappers/player_mapper_factory.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/player_mapper.dart';

PlayerMapper makePlayerMapper() {
  return PlayerMapper();
}
```

**For composed mappers**:

**File**: `lib/main/factories/infra/mappers/team_mapper_factory.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/team_mapper.dart';
import 'player_mapper_factory.dart';

TeamMapper makeTeamMapper() {
  return TeamMapper(
    playerMapper: makePlayerMapper(),  // Inject player mapper
  );
}
```

---

### Step 7: Write Mapper Tests

Always test your mappers!

**File**: `test/infra/mappers/player_mapper_test.dart` (new)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/player.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/player_mapper.dart';

void main() {
  late PlayerMapper sut;  // System Under Test

  setUp(() {
    sut = PlayerMapper();
  });

  group('toDto', () {
    test('should convert JSON to Player entity', () {
      // Arrange
      final json = {
        'id': '123',
        'full_name': 'Cristiano Ronaldo',
        'role': 'forward',
        'is_active': true,
        'joined_at': '2024-01-10T10:00:00.000Z',
        'avatar_url': 'https://example.com/photo.jpg',
      };

      // Act
      final player = sut.toDto(json);

      // Assert
      expect(player.id, '123');
      expect(player.name, 'Cristiano Ronaldo');
      expect(player.position, 'forward');
      expect(player.isActive, true);
      expect(player.joinedDate, DateTime.parse('2024-01-10T10:00:00.000Z'));
      expect(player.photoUrl, 'https://example.com/photo.jpg');
    });

    test('should handle null optional fields', () {
      // Arrange
      final json = {
        'id': '123',
        'full_name': 'Lionel Messi',
        'role': null,  // Optional
        'is_active': null,  // Optional
        'joined_at': null,  // Optional
        'avatar_url': null,  // Optional
      };

      // Act
      final player = sut.toDto(json);

      // Assert
      expect(player.id, '123');
      expect(player.name, 'Lionel Messi');
      expect(player.position, null);
      expect(player.isActive, null);
      expect(player.joinedDate, null);
      expect(player.photoUrl, null);
    });

    test('should handle invalid date format', () {
      // Arrange
      final json = {
        'id': '123',
        'full_name': 'Neymar Jr',
        'joined_at': 'invalid-date',  // Invalid format
      };

      // Act
      final player = sut.toDto(json);

      // Assert
      expect(player.joinedDate, null);  // tryParse returns null
    });
  });

  group('toJson', () {
    test('should convert Player entity to JSON', () {
      // Arrange
      final player = Player(
        id: '123',
        name: 'Cristiano Ronaldo',
        initials: 'CR',
        position: 'forward',
        isActive: true,
        joinedDate: DateTime.parse('2024-01-10T10:00:00.000Z'),
        photoUrl: 'https://example.com/photo.jpg',
      );

      // Act
      final json = sut.toJson(player);

      // Assert
      expect(json['id'], '123');
      expect(json['full_name'], 'Cristiano Ronaldo');
      expect(json['role'], 'forward');
      expect(json['is_active'], true);
      expect(json['joined_at'], '2024-01-10T10:00:00.000Z');
      expect(json['avatar_url'], 'https://example.com/photo.jpg');
    });

    test('should handle null optional fields in JSON output', () {
      // Arrange
      final player = Player(
        id: '123',
        name: 'Lionel Messi',
        initials: 'LM',
        position: null,
        isActive: null,
        joinedDate: null,
        photoUrl: null,
      );

      // Act
      final json = sut.toJson(player);

      // Assert
      expect(json['role'], null);
      expect(json['is_active'], null);
      expect(json['joined_at'], null);
      expect(json['avatar_url'], null);
    });
  });

  group('toDtoList', () {
    test('should convert JSON array to List<Player>', () {
      // Arrange
      final jsonArray = [
        {'id': '1', 'full_name': 'Player 1'},
        {'id': '2', 'full_name': 'Player 2'},
        {'id': '3', 'full_name': 'Player 3'},
      ];

      // Act
      final players = sut.toDtoList(jsonArray);

      // Assert
      expect(players.length, 3);
      expect(players[0].name, 'Player 1');
      expect(players[1].name, 'Player 2');
      expect(players[2].name, 'Player 3');
    });
  });

  group('toJsonArr', () {
    test('should convert List<Player> to JSON array', () {
      // Arrange
      final players = [
        Player(id: '1', name: 'Player 1', initials: 'P1'),
        Player(id: '2', name: 'Player 2', initials: 'P2'),
        Player(id: '3', name: 'Player 3', initials: 'P3'),
      ];

      // Act
      final jsonArray = sut.toJsonArr(players);

      // Assert
      expect(jsonArray.length, 3);
      expect(jsonArray[0]['full_name'], 'Player 1');
      expect(jsonArray[1]['full_name'], 'Player 2');
      expect(jsonArray[2]['full_name'], 'Player 3');
    });
  });
}
```

**Test patterns**:
1. **Arrange-Act-Assert (AAA)**: Standard test structure
2. **Edge cases**: Null values, invalid dates
3. **List operations**: Test inherited mixin methods
4. **Descriptive names**: Test names explain what they verify

**Run tests**:
```bash
flutter test test/infra/mappers/player_mapper_test.dart
```

---

## Complete CRUD Example: Team Management

Now let's implement a complete CRUD (Create, Read, Update, Delete) feature for Team management, following the same patterns as the NextEvent example.

### Domain Layer

#### Step 1: Create Team Entity

**File**: `lib/domain/entities/team.dart` (new)

```dart
final class Team {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final List<TeamMember> members;

  const Team({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.members,
  });
}
```

#### Step 2: Create TeamMember Entity

**File**: `lib/domain/entities/team_member.dart` (new)

```dart
final class TeamMember {
  final String id;
  final String name;
  final String initials;
  final String role;  // 'captain', 'member'
  final String? email;
  final String? photoUrl;

  const TeamMember._({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    this.email,
    this.photoUrl,
  });

  factory TeamMember({
    required String id,
    required String name,
    required String role,
    String? email,
    String? photoUrl,
  }) =>
      TeamMember._(
        id: id,
        name: name,
        initials: _getInitials(name),  // Business logic
        role: role,
        email: email,
        photoUrl: photoUrl,
      );

  // Business rule: Generate initials from name
  static String _getInitials(String name) {
    final names = name.toUpperCase().trim().split(' ');
    final firstChar = names.first.split('').firstOrNull ?? '-';
    final lastChar = names.last.split('').elementAtOrNull(
      names.length == 1 ? 1 : 0,
    ) ?? '';
    return '$firstChar$lastChar';
  }
}
```

---

### Infrastructure Layer

#### Step 3: Create Mappers

**File**: `lib/infra/mappers/team_member_mapper.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team_member.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';
import 'mapper.dart';

final class TeamMemberMapper extends ListMapper<TeamMember> {
  @override
  TeamMember toDto(dynamic json) => TeamMember(
        id: json['id'],
        name: json['name'],
        role: json['role'],
        email: json['email'],
        photoUrl: json['photo_url'],
      );

  @override
  Json toJson(TeamMember member) => {
        'id': member.id,
        'name': member.name,
        'role': member.role,
        'email': member.email,
        'photo_url': member.photoUrl,
      };
}
```

**File**: `lib/infra/mappers/team_mapper.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';
import 'mapper.dart';

final class TeamMapper implements Mapper<Team> {
  final ListMapper<TeamMember> memberMapper;

  const TeamMapper({required this.memberMapper});

  @override
  Team toDto(Json json) => Team(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        createdAt: DateTime.parse(json['created_at']),
        members: memberMapper.toDtoList(json['members']),
      );

  @override
  Json toJson(Team team) => {
        'id': team.id,
        'name': team.name,
        'description': team.description,
        'created_at': team.createdAt.toIso8601String(),
        'members': memberMapper.toJsonArr(team.members),
      };
}
```

#### Step 4: Create HTTP Clients (Interfaces)

**File**: `lib/infra/api/clients/http_post_client.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

abstract interface class HttpPostClient {
  Future<dynamic> post({
    required String url,
    required Json body,
    Json? headers,
  });
}
```

**File**: `lib/infra/api/clients/http_put_client.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/types/json.dart';

abstract interface class HttpPutClient {
  Future<dynamic> put({
    required String url,
    required Json body,
    Json? headers,
  });
}
```

**File**: `lib/infra/api/clients/http_delete_client.dart` (new)

```dart
abstract interface class HttpDeleteClient {
  Future<void> delete({
    required String url,
    Json? headers,
  });
}
```

#### Step 5: Extend HTTP Adapter

**File**: `lib/infra/api/adapters/http_adapter.dart` (extend existing)

Add POST, PUT, DELETE methods to existing HttpAdapter:

```dart
final class HttpAdapter implements
    HttpGetClient,
    HttpPostClient,
    HttpPutClient,
    HttpDeleteClient {
  final Client client;

  const HttpAdapter({required this.client});

  // Existing GET method...

  @override
  Future<dynamic> post({
    required String url,
    required Json body,
    Json? headers,
  }) async {
    final response = await client.post(
      Uri.parse(url),
      headers: _buildHeaders(url: url, headers: headers),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> put({
    required String url,
    required Json body,
    Json? headers,
  }) async {
    final response = await client.put(
      Uri.parse(url),
      headers: _buildHeaders(url: url, headers: headers),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  @override
  Future<void> delete({
    required String url,
    Json? headers,
  }) async {
    final response = await client.delete(
      Uri.parse(url),
      headers: _buildHeaders(url: url, headers: headers),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw UnexpectedError();
    }
  }

  // Existing helper methods (_buildHeaders, _handleResponse, etc.)...
}
```

#### Step 6: Create Repositories (CRUD Operations)

**CREATE - File**: `lib/infra/api/repositories/create_team_api_repo.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_post_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';

final class CreateTeamApiRepository {
  final HttpPostClient httpClient;
  final String url;
  final Mapper<Team> mapper;

  const CreateTeamApiRepository({
    required this.httpClient,
    required this.url,
    required this.mapper,
  });

  Future<Team> createTeam({required Team team}) async {
    final json = await httpClient.post(
      url: url,
      body: mapper.toJson(team),
    );
    return mapper.toDto(json);
  }
}
```

**READ - File**: `lib/infra/api/repositories/load_team_api_repo.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';

final class LoadTeamApiRepository {
  final HttpGetClient httpClient;
  final String url;
  final DtoMapper<Team> mapper;

  const LoadTeamApiRepository({
    required this.httpClient,
    required this.url,
    required this.mapper,
  });

  Future<Team> loadTeam({required String teamId}) async {
    final json = await httpClient.get(
      url: url,
      params: {'teamId': teamId},
    );
    return mapper.toDto(json);
  }
}
```

**READ ALL - File**: `lib/infra/api/repositories/load_teams_api_repo.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_get_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';

final class LoadTeamsApiRepository {
  final HttpGetClient httpClient;
  final String url;
  final DtoListMapper<Team> mapper;

  const LoadTeamsApiRepository({
    required this.httpClient,
    required this.url,
    required this.mapper,
  });

  Future<List<Team>> loadTeams() async {
    final jsonArray = await httpClient.get(url: url);
    return mapper.toDtoList(jsonArray);
  }
}
```

**UPDATE - File**: `lib/infra/api/repositories/update_team_api_repo.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_put_client.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/mapper.dart';

final class UpdateTeamApiRepository {
  final HttpPutClient httpClient;
  final String url;
  final Mapper<Team> mapper;

  const UpdateTeamApiRepository({
    required this.httpClient,
    required this.url,
    required this.mapper,
  });

  Future<Team> updateTeam({required Team team}) async {
    final json = await httpClient.put(
      url: url.replaceFirst(':teamId', team.id),
      body: mapper.toJson(team),
    );
    return mapper.toDto(json);
  }
}
```

**DELETE - File**: `lib/infra/api/repositories/delete_team_api_repo.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/clients/http_delete_client.dart';

final class DeleteTeamApiRepository {
  final HttpDeleteClient httpClient;
  final String url;

  const DeleteTeamApiRepository({
    required this.httpClient,
    required this.url,
  });

  Future<void> deleteTeam({required String teamId}) async {
    await httpClient.delete(
      url: url.replaceFirst(':teamId', teamId),
    );
  }
}
```

---

### Presentation Layer

#### Step 7: Create ViewModels

**File**: `lib/presentation/presenters/team_presenter.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team.dart';

// Contracts
abstract interface class TeamPresenter {
  Stream<List<TeamViewModel>> get teamsStream;
  Stream<TeamViewModel> get teamStream;
  Stream<bool> get isBusyStream;

  void dispose();
  Future<void> loadTeams();
  Future<void> loadTeam({required String teamId});
  Future<void> createTeam({required TeamViewModel team});
  Future<void> updateTeam({required TeamViewModel team});
  Future<void> deleteTeam({required String teamId});
}

// ViewModels
final class TeamViewModel {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final int membersCount;
  final List<TeamMemberViewModel> members;

  const TeamViewModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.membersCount,
    required this.members,
  });
}

final class TeamMemberViewModel {
  final String id;
  final String name;
  final String initials;
  final String role;
  final String? email;
  final String? photoUrl;

  const TeamMemberViewModel({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    this.email,
    this.photoUrl,
  });
}
```

#### Step 8: Create RxDart Presenter Implementation

**File**: `lib/presentation/rx/team_rx_presenter.dart` (new)

```dart
import 'package:rxdart/rxdart.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team.dart';
import 'package:fluttter_avancado_tdd_clean_arch/domain/entities/team_member.dart';
import 'package:fluttter_avancado_tdd_clean_arch/presentation/presenters/team_presenter.dart';

final class TeamRxPresenter implements TeamPresenter {
  final Future<List<Team>> Function() teamsLoader;
  final Future<Team> Function({required String teamId}) teamLoader;
  final Future<Team> Function({required Team team}) teamCreator;
  final Future<Team> Function({required Team team}) teamUpdater;
  final Future<void> Function({required String teamId}) teamDeleter;

  final teamsSubject = BehaviorSubject<List<TeamViewModel>>();
  final teamSubject = BehaviorSubject<TeamViewModel>();
  final isBusySubject = BehaviorSubject<bool>();

  TeamRxPresenter({
    required this.teamsLoader,
    required this.teamLoader,
    required this.teamCreator,
    required this.teamUpdater,
    required this.teamDeleter,
  });

  @override
  Stream<List<TeamViewModel>> get teamsStream => teamsSubject.stream;

  @override
  Stream<TeamViewModel> get teamStream => teamSubject.stream;

  @override
  Stream<bool> get isBusyStream => isBusySubject.stream;

  @override
  Future<void> loadTeams() async {
    try {
      isBusySubject.add(true);
      final teams = await teamsLoader();
      teamsSubject.add(teams.map(_mapTeam).toList());
    } catch (error) {
      teamsSubject.addError(error);
    } finally {
      isBusySubject.add(false);
    }
  }

  @override
  Future<void> loadTeam({required String teamId}) async {
    try {
      isBusySubject.add(true);
      final team = await teamLoader(teamId: teamId);
      teamSubject.add(_mapTeam(team));
    } catch (error) {
      teamSubject.addError(error);
    } finally {
      isBusySubject.add(false);
    }
  }

  @override
  Future<void> createTeam({required TeamViewModel teamViewModel}) async {
    try {
      isBusySubject.add(true);
      final team = _viewModelToEntity(teamViewModel);
      final createdTeam = await teamCreator(team: team);
      teamSubject.add(_mapTeam(createdTeam));
    } catch (error) {
      teamSubject.addError(error);
    } finally {
      isBusySubject.add(false);
    }
  }

  @override
  Future<void> updateTeam({required TeamViewModel teamViewModel}) async {
    try {
      isBusySubject.add(true);
      final team = _viewModelToEntity(teamViewModel);
      final updatedTeam = await teamUpdater(team: team);
      teamSubject.add(_mapTeam(updatedTeam));
    } catch (error) {
      teamSubject.addError(error);
    } finally {
      isBusySubject.add(false);
    }
  }

  @override
  Future<void> deleteTeam({required String teamId}) async {
    try {
      isBusySubject.add(true);
      await teamDeleter(teamId: teamId);
      // Reload teams after deletion
      await loadTeams();
    } catch (error) {
      teamsSubject.addError(error);
    } finally {
      isBusySubject.add(false);
    }
  }

  TeamViewModel _mapTeam(Team team) => TeamViewModel(
        id: team.id,
        name: team.name,
        description: team.description,
        createdAt: team.createdAt,
        membersCount: team.members.length,
        members: team.members.map(_mapMember).toList(),
      );

  TeamMemberViewModel _mapMember(TeamMember member) => TeamMemberViewModel(
        id: member.id,
        name: member.name,
        initials: member.initials,
        role: member.role,
        email: member.email,
        photoUrl: member.photoUrl,
      );

  Team _viewModelToEntity(TeamViewModel viewModel) => Team(
        id: viewModel.id,
        name: viewModel.name,
        description: viewModel.description,
        createdAt: viewModel.createdAt,
        members: viewModel.members
            .map((m) => TeamMember(
                  id: m.id,
                  name: m.name,
                  role: m.role,
                  email: m.email,
                  photoUrl: m.photoUrl,
                ))
            .toList(),
      );

  @override
  void dispose() {
    teamsSubject.close();
    teamSubject.close();
    isBusySubject.close();
  }
}
```

---

### Dependency Injection

#### Step 9: Create Factories

**Mapper Factories**:

**File**: `lib/main/factories/infra/mappers/team_member_mapper_factory.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/team_member_mapper.dart';

TeamMemberMapper makeTeamMemberMapper() {
  return TeamMemberMapper();
}
```

**File**: `lib/main/factories/infra/mappers/team_mapper_factory.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/mappers/team_mapper.dart';
import 'team_member_mapper_factory.dart';

TeamMapper makeTeamMapper() {
  return TeamMapper(
    memberMapper: makeTeamMemberMapper(),
  );
}
```

**Repository Factories**:

**File**: `lib/main/factories/infra/api/repositories/team_repositories_factory.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/create_team_api_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/load_team_api_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/load_teams_api_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/update_team_api_repo.dart';
import 'package:fluttter_avancado_tdd_clean_arch/infra/api/repositories/delete_team_api_repo.dart';
import '../../adapters/http_adapter_factory.dart';
import '../../mappers/team_mapper_factory.dart';

CreateTeamApiRepository makeCreateTeamApiRepository() {
  return CreateTeamApiRepository(
    httpClient: makeHttpAdapter(),
    url: 'http://localhost:8080/api/teams',
    mapper: makeTeamMapper(),
  );
}

LoadTeamApiRepository makeLoadTeamApiRepository() {
  return LoadTeamApiRepository(
    httpClient: makeHttpAdapter(),
    url: 'http://localhost:8080/api/teams/:teamId',
    mapper: makeTeamMapper(),
  );
}

LoadTeamsApiRepository makeLoadTeamsApiRepository() {
  return LoadTeamsApiRepository(
    httpClient: makeHttpAdapter(),
    url: 'http://localhost:8080/api/teams',
    mapper: makeTeamMapper(),
  );
}

UpdateTeamApiRepository makeUpdateTeamApiRepository() {
  return UpdateTeamApiRepository(
    httpClient: makeHttpAdapter(),
    url: 'http://localhost:8080/api/teams/:teamId',
    mapper: makeTeamMapper(),
  );
}

DeleteTeamApiRepository makeDeleteTeamApiRepository() {
  return DeleteTeamApiRepository(
    httpClient: makeHttpAdapter(),
    url: 'http://localhost:8080/api/teams/:teamId',
  );
}
```

**Presenter Factory**:

**File**: `lib/main/factories/presentation/rx/team_rx_presenter_factory.dart` (new)

```dart
import 'package:fluttter_avancado_tdd_clean_arch/presentation/rx/team_rx_presenter.dart';
import '../../infra/api/repositories/team_repositories_factory.dart';

TeamRxPresenter makeTeamRxPresenter() {
  return TeamRxPresenter(
    teamsLoader: makeLoadTeamsApiRepository().loadTeams,
    teamLoader: makeLoadTeamApiRepository().loadTeam,
    teamCreator: makeCreateTeamApiRepository().createTeam,
    teamUpdater: makeUpdateTeamApiRepository().updateTeam,
    teamDeleter: makeDeleteTeamApiRepository().deleteTeam,
  );
}
```

---

### Backend API (Mock)

#### Step 10: Create Backend Endpoints

**File**: `backend/teams.js` (new - add to existing backend)

```javascript
const express = require('express');
const router = express.Router();

// In-memory database
let teams = [
  {
    id: '1',
    name: 'Champions League All-Stars',
    description: 'Top players from European leagues',
    created_at: '2024-01-01T00:00:00.000Z',
    members: [
      {
        id: 'm1',
        name: 'Cristiano Ronaldo',
        role: 'captain',
        email: 'cr7@example.com',
        photo_url: 'https://example.com/cr7.jpg',
      },
      {
        id: 'm2',
        name: 'Lionel Messi',
        role: 'member',
        email: 'messi@example.com',
        photo_url: 'https://example.com/messi.jpg',
      },
    ],
  },
];

// CREATE
router.post('/teams', (req, res) => {
  const newTeam = {
    id: String(teams.length + 1),
    ...req.body,
    created_at: new Date().toISOString(),
  };
  teams.push(newTeam);
  res.status(201).json(newTeam);
});

// READ ALL
router.get('/teams', (req, res) => {
  res.json(teams);
});

// READ ONE
router.get('/teams/:teamId', (req, res) => {
  const team = teams.find((t) => t.id === req.params.teamId);
  if (!team) {
    return res.status(404).json({ error: 'Team not found' });
  }
  res.json(team);
});

// UPDATE
router.put('/teams/:teamId', (req, res) => {
  const index = teams.findIndex((t) => t.id === req.params.teamId);
  if (index === -1) {
    return res.status(404).json({ error: 'Team not found' });
  }
  teams[index] = { ...teams[index], ...req.body };
  res.json(teams[index]);
});

// DELETE
router.delete('/teams/:teamId', (req, res) => {
  const index = teams.findIndex((t) => t.id === req.params.teamId);
  if (index === -1) {
    return res.status(404).json({ error: 'Team not found' });
  }
  teams.splice(index, 1);
  res.status(204).send();
});

module.exports = router;
```

**Update** `backend/index.js`:

```javascript
const express = require('express');
const cors = require('cors');
const teamsRouter = require('./teams');

const app = express();
const port = 8080;

app.use(cors());
app.use(express.json());

// Existing routes...
app.use('/api', teamsRouter);  // Add this line

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
```

---

## SOLID Principles in Mappers

### 1. Single Responsibility Principle (SRP)

**Principle**: Each class should have only one reason to change.

**Application in Mappers**:

```dart
// ✅ GOOD: PlayerMapper only maps Players
final class PlayerMapper extends ListMapper<Player> {
  // Responsibility: Convert Player ↔ JSON
  @override
  Player toDto(Json json) => Player(...);

  @override
  Json toJson(Player player) => {...};
}

// ✅ GOOD: TeamMapper only maps Teams (delegates Player mapping)
final class TeamMapper implements Mapper<Team> {
  final ListMapper<Player> playerMapper;  // Delegation!

  @override
  Team toDto(Json json) => Team(
    name: json['name'],
    members: playerMapper.toDtoList(json['members']),  // Delegates
  );
}

// ❌ BAD: TeamMapper knows how to map Players
final class TeamMapper {
  @override
  Team toDto(Json json) => Team(
    name: json['name'],
    members: (json['members'] as List).map((p) => Player(
      name: p['name'],  // Mapping logic duplicated!
      // ... more fields
    )).toList(),
  );
}
```

**Benefit**: Player mapping logic in one place. Changes to Player mapping only affect PlayerMapper.

---

### 2. Open/Closed Principle (OCP)

**Principle**: Open for extension, closed for modification.

**Application in Mappers**:

```dart
// Base interface (closed for modification)
abstract interface class Mapper<Dto> {
  Dto toDto(Json json);
  Json toJson(Dto dto);
}

// Extend by creating new implementations (open for extension)
final class PlayerMapper implements Mapper<Player> { }
final class TeamMapper implements Mapper<Team> { }
final class EventMapper implements Mapper<Event> { }

// Can add new mappers without modifying existing ones
final class GameMapper implements Mapper<Game> { }
```

**Benefit**: Add new entities and mappers without changing existing code.

---

### 3. Liskov Substitution Principle (LSP)

**Principle**: Subtypes must be substitutable for their base types.

**Application in Mappers**:

```dart
// Repository depends on DtoMapper interface
final class LoadTeamRepository {
  final DtoMapper<Team> mapper;  // Interface, not concrete class

  Future<Team> loadTeam() async {
    final json = await httpClient.get(...);
    return mapper.toDto(json);  // Works with any DtoMapper<Team>
  }
}

// Can substitute with any implementation
final repo1 = LoadTeamRepository(mapper: TeamMapper(...));
final repo2 = LoadTeamRepository(mapper: TeamMapperV2(...));
final repo3 = LoadTeamRepository(mapper: MockTeamMapper());  // Test double

// All substitutions work correctly
```

**Benefit**: Easy to swap implementations, especially for testing.

---

### 4. Interface Segregation Principle (ISP)

**Principle**: Clients shouldn't depend on interfaces they don't use.

**Application in Mappers**:

```dart
// ✅ GOOD: Segregated interfaces
abstract interface class DtoMapper<Dto> {
  Dto toDto(Json json);
}

abstract interface class JsonMapper<Dto> {
  Json toJson(Dto dto);
}

// Repository only needs DtoMapper (reading)
final class LoadTeamRepository {
  final DtoMapper<Team> mapper;  // Only needs toDto()
}

// Cache repository needs JsonMapper (writing)
final class SaveTeamCacheRepository {
  final JsonMapper<Team> mapper;  // Only needs toJson()
}

// Full mapper implements both when needed
final class TeamMapper implements Mapper<Team> {
  // Implements both methods
}

// ❌ BAD: One big interface
abstract interface class BigMapper<Dto> {
  Dto toDto(Json json);
  Json toJson(Dto dto);
  List<Dto> toDtoList(List json);
  List<Json> toJsonList(List<Dto> dtos);
}

// Repository forced to depend on unused methods
final class LoadTeamRepository {
  final BigMapper<Team> mapper;  // Must depend on entire interface!
  // Only uses toDto(), but must know about all methods
}
```

**Benefit**: Clients depend only on what they need, reducing coupling.

---

### 5. Dependency Inversion Principle (DIP)

**Principle**: Depend on abstractions, not concretions.

**Application in Mappers**:

```dart
// ✅ GOOD: TeamMapper depends on abstraction (ListMapper interface)
final class TeamMapper implements Mapper<Team> {
  final ListMapper<TeamMember> memberMapper;  // Abstraction!

  const TeamMapper({required this.memberMapper});

  @override
  Team toDto(Json json) => Team(
    members: memberMapper.toDtoList(json['members']),
  );
}

// Can inject any ListMapper<TeamMember>
final mapper1 = TeamMapper(memberMapper: TeamMemberMapper());
final mapper2 = TeamMapper(memberMapper: TeamMemberMapperV2());
final mapper3 = TeamMapper(memberMapper: MockTeamMemberMapper());  // Test

// ❌ BAD: TeamMapper depends on concrete class
final class TeamMapper {
  final TeamMemberMapper memberMapper;  // Concrete class!

  // Now tightly coupled to specific implementation
  // Can't easily swap or test
}
```

**Benefit**: Flexible composition, easy testing, loose coupling.

---

## Best Practices

### 1. Always Use Bidirectional Mapping

Implement both `toDto()` and `toJson()`:

```dart
// ✅ GOOD: Bidirectional
final class TeamMapper implements Mapper<Team> {
  @override
  Team toDto(Json json) => ...;  // JSON → Entity

  @override
  Json toJson(Team team) => ...;  // Entity → JSON
}
```

**Why?**: Even if you only read now, you might need to write later (updates, caching).

---

### 2. Handle Null Safety Properly

Use null-aware operators and provide defaults:

```dart
@override
Player toDto(Json json) => Player(
  id: json['id'] as String,  // Required
  name: json['name'] as String,  // Required
  email: json['email'] as String?,  // Optional
  joinedDate: json['joined_at'] != null
      ? DateTime.tryParse(json['joined_at'])
      : null,  // Safe parsing
  role: json['role'] ?? 'member',  // Default value
);
```

---

### 3. Use Type Casting for Safety

Explicitly cast JSON values:

```dart
// ✅ GOOD: Explicit casting
id: json['id'] as String,
count: json['count'] as int,
price: json['price'] as double,
isActive: json['is_active'] as bool?,

// ❌ BAD: No casting (runtime errors possible)
id: json['id'],  // Type not guaranteed!
```

---

### 4. Delegate to Nested Mappers

Don't duplicate mapping logic:

```dart
// ✅ GOOD: Delegate
final class TeamMapper {
  final ListMapper<TeamMember> memberMapper;

  @override
  Team toDto(Json json) => Team(
    members: memberMapper.toDtoList(json['members']),  // Delegate!
  );
}

// ❌ BAD: Duplicate mapping logic
final class TeamMapper {
  @override
  Team toDto(Json json) => Team(
    members: (json['members'] as List).map((m) => TeamMember(
      name: m['name'],  // Duplicated from TeamMemberMapper!
      email: m['email'],
    )).toList(),
  );
}
```

---

### 5. Test Edge Cases

Always test:
- Null values
- Missing fields
- Invalid formats
- Empty arrays
- Malformed data

```dart
test('should handle null optional fields', () { });
test('should handle empty member list', () { });
test('should handle invalid date format', () { });
test('should handle missing required field', () {
  // Should throw or return safe default
});
```

---

### 6. Keep Mappers Pure

Mappers should be stateless and deterministic:

```dart
// ✅ GOOD: Pure mapper
final class TeamMapper {
  const TeamMapper({required this.memberMapper});  // Const constructor

  @override
  Team toDto(Json json) => Team(...);  // No side effects
}

// ❌ BAD: Stateful mapper
final class TeamMapper {
  int mappingCount = 0;  // State!

  @override
  Team toDto(Json json) {
    mappingCount++;  // Side effect!
    return Team(...);
  }
}
```

---

### 7. Document Field Mappings

Use comments to document non-obvious mappings:

```dart
@override
Player toDto(Json json) => Player(
  id: json['id'],
  name: json['full_name'],  // API uses 'full_name', we use 'name'
  position: json['role'],  // API uses 'role', we use 'position'
  joinedDate: DateTime.tryParse(json['joined_at'] ?? ''),  // Nullable, safe parse
);
```

---

### 8. Version Your Mappers

When API changes, create new mapper versions:

```dart
// Old API
final class TeamMapperV1 implements Mapper<Team> { }

// New API
final class TeamMapperV2 implements Mapper<Team> { }

// Factory decides which to use based on API version
TeamMapper makeTeamMapper() {
  if (useNewApi) {
    return TeamMapperV2(...);
  }
  return TeamMapperV1(...);
}
```

---

## Summary

### Key Takeaways

1. **Mappers Protect Your Domain**: They implement the Anti-Corruption Layer, shielding your domain from external changes.

2. **Bidirectional Transformation**: Always implement both `toDto()` (JSON → Entity) and `toJson()` (Entity → JSON).

3. **Composition Over Duplication**: Use mapper injection for nested entities (e.g., TeamMapper uses TeamMemberMapper).

4. **SOLID Principles**: Mappers exemplify all five SOLID principles through interface segregation, dependency inversion, and single responsibility.

5. **Type Safety**: Mappers provide type-safe boundaries between dynamic JSON and strongly-typed domain entities.

6. **Testability**: Pure, stateless mappers are easy to test with simple unit tests.

7. **Maintainability**: API changes are localized to mappers, not scattered across the codebase.

### Complete CRUD Flow Summary

For the Team example:

```
CREATE: TeamViewModel → Team → JSON → API → JSON → Team → TeamViewModel
READ:   API → JSON → Team → TeamViewModel → UI Display
UPDATE: TeamViewModel → Team → JSON → API → JSON → Team → TeamViewModel
DELETE: teamId → API → Success → Reload list
```

At each step, **mappers ensure clean transformation** between external JSON and internal domain entities, **protecting your domain** from the chaos of the external world.

---

## Next Steps

1. **Practice**: Implement the Team CRUD example in your project
2. **Experiment**: Try mapping different API formats to the same domain entity
3. **Test**: Write comprehensive tests for all your mappers
4. **Refactor**: Review existing code and identify where mappers could improve structure
5. **Extend**: Add cache repositories for offline support (following the same patterns)

**Remember**: The mapper pattern is your **first line of defense** against external systems. Invest time in building robust mappers, and your domain layer will remain clean, stable, and maintainable.

Happy mapping! 🗺️
