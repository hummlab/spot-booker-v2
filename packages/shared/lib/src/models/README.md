# Models Directory

This directory contains all data models, entities, and type definitions used across the project.

## Purpose

The `models/` directory provides a centralized location for all data structures, ensuring consistency and type safety across all Flutter applications.

## Cursor Rules

This directory has its own `.cursorrules` file that enforces:
- Automatic organization of models in subdirectories
- Freezed code generation for all models
- Strong typing requirements
- JSON serialization standards
- Testing guidelines

## Structure

Models should be organized by domain or feature in subdirectories:

```
models/
├── user/              # User-related models
│   ├── user.dart
│   ├── user_profile.dart
│   ├── user_preferences.dart
│   └── user.freezed.dart
├── product/           # Product-related models
│   ├── product.dart
│   ├── category.dart
│   ├── inventory.dart
│   └── product.freezed.dart
├── order/             # Order-related models
│   ├── order.dart
│   ├── order_item.dart
│   ├── order_status.dart
│   └── order.freezed.dart
└── common/            # Common/shared models
    ├── api_response.dart
    ├── pagination.dart
    ├── error_model.dart
    └── api_response.freezed.dart
```

## Freezed Code Generation

This project uses **Freezed** for automatic code generation, providing:
- Immutable data classes
- JSON serialization/deserialization
- Union types for error handling
- Copy with functionality
- Equality and toString methods

## Model Types

### Entities
Core business objects that represent real-world entities using Freezed:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### DTOs (Data Transfer Objects)
Objects used for API communication with Freezed:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDTO with _$UserDTO {
  const factory UserDTO({
    required String id,
    required String email,
    required String name,
    required String createdAt,
  }) = _UserDTO;

  factory UserDTO.fromJson(Map<String, dynamic> json) => _$UserDTOFromJson(json);
}
```

### Enums
Shared enumerations and constants:

```dart
enum UserRole {
  admin,
  user,
  moderator,
}

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}
```

## Development Guidelines

- **Strong Typing**: All properties must have explicit types
- **Freezed Usage**: Use Freezed for all models with `@freezed` annotation
- **Documentation**: Document all public classes and methods
- **JSON Serialization**: Use Freezed's automatic JSON serialization
- **Validation**: Use `@Assert` for property validation
- **Immutability**: All models are immutable by default with Freezed
- **Code Generation**: Run `flutter packages pub run build_runner build` after changes

## Example Model

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const User._(); // Private constructor for custom methods

  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isActive,
    @Default([]) List<String> permissions,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Custom methods
  bool get isAdmin => role == UserRole.admin;
  bool get isActive => updatedAt != null;
  
  String get displayName => name.isNotEmpty ? name : email.split('@').first;
}

enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('user')
  user,
  @JsonValue('moderator')
  moderator,
}
```

## Best Practices

1. **Naming**: Use descriptive names that clearly indicate the model's purpose
2. **Organization**: Group related models in subdirectories with proper naming
3. **Freezed Usage**: Always use Freezed for code generation and immutability
4. **Validation**: Use `@Assert` for property validation
5. **Testing**: Write unit tests for all models including JSON serialization
6. **Documentation**: Include examples in documentation
7. **Code Generation**: Run build_runner after creating or modifying models
8. **Union Types**: Use Freezed union types for error handling and state management 