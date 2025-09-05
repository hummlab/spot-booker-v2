# Project Template

A comprehensive Flutter-based mobile development project template designed for rapid development of mobile applications with web panels.

## Project Structure

This project follows a monorepo structure optimized for Flutter development:

```
project_template/
├── apps/                    # Flutter applications
├── packages/                # Shared Flutter packages
│   └── shared/             # Common shared code
│       ├── models/         # Data models
│       ├── data_providers/ # Data providers
│       └── repositories/   # Repository layer
├── backend/                # Firebase Cloud Functions
└── website/                # Landing page
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Firebase CLI
- Node.js (for backend functions)

### Development Setup

1. Clone the repository
2. Install Flutter dependencies: `flutter pub get`
3. Set up Firebase project and configure Firebase CLI
4. Install backend dependencies: `cd backend && npm install`

## Development Guidelines

- All code must be written in English
- All comments must be in English
- Strong typing is required for all variables
- Follow Flutter best practices and conventions
- Use shared packages for common functionality

## Architecture

This project follows a clean architecture approach with:
- **Apps**: Individual Flutter applications
- **Packages**: Reusable Flutter packages for shared code
- **Backend**: Firebase Cloud Functions for server-side logic
- **Website**: Landing page and web presence

## Contributing

Please ensure all code follows the established conventions and includes proper documentation. 