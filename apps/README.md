# Apps Directory

This directory contains all Flutter applications in the project.

## Purpose

The `apps/` directory is designed to house multiple Flutter applications that can share common code through the packages in the `packages/` directory.

## Structure

Each application should be placed in its own subdirectory with a descriptive name:

```
apps/
├── client/              # Mobile client application (iOS/Android)
│   ├── lib/            # Flutter source code
│   ├── android/        # Android-specific files
│   ├── ios/            # iOS-specific files
│   ├── web/            # Web platform files
│   └── pubspec.yaml    # Dependencies and configuration
├── panel/               # Web admin panel (Flutter web)
│   ├── lib/            # Flutter source code
│   ├── web/            # Web-specific files
│   └── pubspec.yaml    # Dependencies and configuration
└── [other_apps]/        # Additional applications
```

## Development Guidelines

- Each app should be a complete Flutter project with its own `pubspec.yaml`
- Use shared packages from `packages/shared/` for common functionality
- Follow consistent naming conventions
- Implement proper state management
- Include comprehensive testing

## Getting Started

### Existing Applications

#### Client App (Mobile)
- **Platforms**: iOS, Android, Web
- **Purpose**: Mobile client application for end users
- **Location**: `apps/client/`
- **Run**: `cd apps/client && flutter run`

#### Panel App (Web)
- **Platforms**: Web only
- **Purpose**: Administrative web panel
- **Location**: `apps/panel/`
- **Run**: `cd apps/panel && flutter run -d chrome`

### Creating New Applications

To create a new Flutter app in this directory:

1. Create a new directory for your app
2. Initialize a new Flutter project: `flutter create app_name`
3. Add dependencies to shared packages in `pubspec.yaml`
4. Follow the project's coding standards

## Shared Code

Leverage the shared packages for:
- Data models (`packages/shared/models/`)
- Data providers (`packages/shared/data_providers/`)
- Repository layer (`packages/shared/repositories/`)

This ensures consistency across all applications and reduces code duplication. 