# Spot Booker Admin Panel

Flutter Web application for managing desk reservations and users in the Spot Booker system.

## Features

- **Authentication**: Email/password login (no allowlist - any authenticated user can access)
- **User Management**: List, add, and manage user accounts
- **Desk Management**: CRUD operations for desk resources
- **Reservations**: View, create, and manage desk reservations

## Tech Stack

- **Flutter Web**: UI framework
- **Firebase**: Authentication, Firestore, Cloud Functions
- **go_router**: Navigation and routing
- **hooks_riverpod**: State management
- **Shared Package**: Common models and utilities

## Getting Started

### Prerequisites

- Flutter SDK (>=3.4.0)
- Firebase project configured
- Shared package dependencies

### Setup

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure Firebase:
   - Update `web/index.html` with your Firebase configuration
   - Ensure Firebase project has Authentication and Firestore enabled

3. Run the application:
   ```bash
   flutter run -d chrome
   ```

## Project Structure

```
lib/
├── app.dart                 # Main app configuration
├── main.dart               # Application entry point
├── router.dart             # Navigation routes
├── core/                   # Core utilities and providers
│   ├── providers.dart      # Riverpod providers
│   ├── validators.dart     # Form validation utilities
│   └── widgets/           # Reusable widgets
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── users/             # User management
│   ├── desks/             # Desk management
│   └── reservations/      # Reservation management
└── web/                   # Web-specific assets
```

## Key Features

### Authentication
- Email/password login via Firebase Auth
- No admin allowlist - any authenticated user can access
- Automatic redirect handling
- Session management

### User Management
- List all users with search functionality
- Add new users (creates Firebase Auth account + Firestore document)
- Toggle user active/inactive status
- View user statistics and recent activity

### Desk Management
- CRUD operations for desk resources
- Search and filter desks
- Enable/disable desk availability
- Validate desk codes for uniqueness

### Reservations
- View all reservations with filtering
- Create reservations on behalf of users
- Cancel existing reservations
- Date-based filtering and management

## State Management

The app uses Riverpod for state management with the following key providers:

- `currentUserProvider`: Current authenticated user
- `usersStreamProvider`: Real-time user data
- `desksStreamProvider`: Real-time desk data
- Repository providers for data access

## Security

- Authentication required for all admin features
- No allowlist validation (any authenticated user can access)
- Sensitive operations use Cloud Functions
- Input validation on all forms

## Development

### Adding New Features

1. Create feature directory under `lib/features/`
2. Implement repository for data access
3. Create Riverpod providers
4. Build UI components
5. Add routes to `router.dart`

### Code Style

- Follow Flutter/Dart style guidelines
- Use explicit typing (as per project rules)
- Implement proper error handling
- Add validation for all inputs

## Deployment

1. Build for web:
   ```bash
   flutter build web
   ```

2. Deploy to Firebase Hosting or your preferred platform

3. Ensure Firebase configuration is properly set for production

## Contributing

1. Follow the established code structure
2. Add appropriate error handling
3. Include form validation
4. Test authentication flows
5. Ensure responsive design for web

## Notes

- This is a web-only application (no mobile support)
- Requires active internet connection for Firebase services
- Real-time updates via Firestore streams
- Optimized for desktop/tablet screen sizes