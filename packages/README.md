# Packages Directory

This directory contains shared Flutter packages that can be used across multiple applications.

## Purpose

The `packages/` directory houses reusable Flutter packages that provide common functionality, models, and business logic shared between different applications in the project.

## Structure

```
packages/
└── shared/               # Main shared package
    ├── models/          # Data models and entities
    ├── data_providers/  # Data providers and services
    └── repositories/    # Repository layer for data access
```

## Shared Package

The `shared/` package contains the core shared functionality:

### Models (`models/`)
- Data models and entities
- DTOs (Data Transfer Objects)
- Enums and constants
- Type definitions

### Data Providers (`data_providers/`)
- API clients
- Local storage providers
- Firebase services
- External service integrations

### Repositories (`repositories/`)
- Data access layer
- Business logic implementation
- Data transformation logic
- Caching strategies

## Usage

To use shared packages in your Flutter applications:

1. Add the package dependency to your app's `pubspec.yaml`:
```yaml
dependencies:
  shared:
    path: ../../packages/shared
```

2. Import the shared components:
```dart
import 'package:shared/models/user_model.dart';
import 'package:shared/repositories/user_repository.dart';
```

## Development Guidelines

- Keep packages focused and single-purpose
- Maintain backward compatibility
- Include comprehensive documentation
- Write unit tests for all shared functionality
- Follow Flutter package conventions
- Use strong typing for all variables and functions

## Creating New Packages

When creating new shared packages:

1. Create a new directory in `packages/`
2. Initialize as a Flutter package: `flutter create --template=package package_name`
3. Define clear APIs and interfaces
4. Document all public methods and classes
5. Include example usage 