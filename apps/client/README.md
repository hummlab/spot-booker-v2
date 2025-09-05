# Spot Booker Client App

Flutter web application for desk booking system. This is the end-user client application that allows users to book and manage their desk reservations.

## Features Implemented

### 🔐 Authentication
- **Email/Password Login** with Firebase Auth
- **User Registration** (requires admin pre-approval)
- **Forgot Password** functionality
- **User Validation** - checks if user exists in Firestore and is active
- **Auto-redirect** based on authentication state

### 🏠 Home Screen
- **Welcome Message** with user's first name
- **Date Picker** for selecting booking date
- **Quick Actions** for common tasks
- **Navigation** to available desks and reservations

### 📋 Desk Management
- **Available Desks List** filtered by selected date
- **Real-time Filtering** - excludes desks with active reservations
- **Search Functionality** by desk name, code, or notes
- **Desk Details** with code, name, and notes display

### ✅ Reservation System
- **Reservation Confirmation** with full details
- **Notes Support** for special requirements
- **Atomic Transactions** to prevent double bookings
- **Date Validation** - prevents past date bookings
- **Desk Availability Check** in real-time

### 📱 My Reservations
- **Upcoming Reservations** tab with cancellation option
- **Reservation History** tab for past bookings
- **Detailed Reservation Cards** with desk information
- **Cancel Functionality** with confirmation dialog
- **Real-time Status Updates**

## Technical Architecture

### 🏗️ State Management
- **Riverpod** for dependency injection and state management
- **Providers** for Firebase services, data providers, and auth state
- **Reactive UI** that updates based on state changes

### 🗺️ Navigation
- **go_router** for declarative routing
- **Protected Routes** with authentication guards
- **Deep Linking** support with query parameters
- **Auto-redirect** logic for authenticated/unauthenticated users

### 🎨 UI/UX
- **Material 3** design system
- **Responsive Design** for web, mobile, and tablet
- **Loading States** and error handling
- **Snackbar Notifications** for user feedback
- **Form Validation** with visual feedback

### 🔥 Firebase Integration
- **Firebase Auth** for user authentication
- **Cloud Firestore** for data storage
- **Real-time Listeners** for live updates
- **Transaction Support** for data consistency

## Project Structure

```
lib/
├── core/
│   ├── providers.dart          # Riverpod providers
│   └── router.dart             # Go router configuration
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── desks/
│   │   └── desk_list_screen.dart
│   ├── reservations/
│   │   ├── reservation_confirmation_screen.dart
│   │   └── my_reservations_screen.dart
│   └── splash_screen.dart
├── services/
│   └── auth_service.dart       # Authentication service
├── firebase_options.dart       # Firebase configuration
└── main.dart                   # App entry point
```

## Data Models

The app uses shared models from the `packages/shared` directory:

- **AppUser** - User profile with email, name, active status
- **Desk** - Workspace with name, code, enabled status, notes
- **Reservation** - Booking with user, desk, date, status, notes
- **DeskDayLock** - Prevents double bookings for specific desk/date

## Key Features

### User Authentication Flow
1. User enters email/password
2. System checks if user exists in Firestore
3. Validates user is active in the system
4. Creates Firebase Auth session
5. Updates last login timestamp

### Booking Flow
1. User selects date from home screen
2. System shows available desks (excludes locked ones)
3. User selects desk and confirms booking
4. Transaction creates reservation and desk lock
5. Success confirmation with navigation options

### Cancellation Flow
1. User views upcoming reservations
2. Selects cancel on active reservation
3. Confirmation dialog prevents accidental cancellation
4. Transaction updates reservation status and removes lock
5. Real-time UI update reflects changes

## Firestore Collections

### users/{uid}
- email, firstName, lastName, active, createdAt, lastLoginAt

### desks/{deskId}
- name, code, enabled, notes, createdAt, updatedAt

### reservations/{reservationId}
- userId, deskId, date (YYYY-MM-DD), status, createdAt, cancelledAt, notes

### deskDayLocks/{deskId}_{date}
- deskId, date, reservationId, userId, createdAt

## Security Features

- **Email Validation** - Only pre-approved users can register
- **Active User Check** - Inactive users cannot access system
- **Past Date Prevention** - Cannot book or cancel past reservations
- **Atomic Transactions** - Prevents race conditions in bookings
- **Input Validation** - All forms have comprehensive validation

## Getting Started

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**
   - Update `firebase_options.dart` with your project settings
   - Ensure Firestore rules allow authenticated access

3. **Run the App**
   ```bash
   flutter run -d web-server --web-port 8080
   ```

4. **Build for Production**
   ```bash
   flutter build web --release
   ```

## Admin Requirements

Before users can access the system:

1. **Add Users** - Admin must create user documents in Firestore
2. **Create Desks** - Admin must set up available desks
3. **Enable Desks** - Only enabled desks appear in booking flow

## Future Enhancements

- Push notifications for booking reminders
- Recurring reservations
- Desk filtering by location/features
- Calendar integration
- Mobile app versions (iOS/Android)
- Offline support with sync
- User preferences and favorites
- Booking analytics and reporting

## Dependencies

- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Database operations
- `flutter_riverpod` - State management
- `go_router` - Navigation and routing
- `flutter_form_builder` - Form handling
- `form_builder_validators` - Input validation
- `shared` - Shared models and utilities

## License

This project is part of the Spot Booker v2 system.