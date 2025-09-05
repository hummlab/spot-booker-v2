# Shared Package

Shared models, utilities, and data structures for Spot Booker applications.

## Overview

This package provides shared data models and utilities that are used across both the client app (`apps/client`) and admin panel (`apps/panel`). All models are built using Freezed for immutability and JSON serialization.

## Features

- **Freezed Models**: Immutable data classes with built-in JSON serialization
- **Type-Safe Firestore References**: Utilities for safe Firestore collection access
- **Date/Time Converters**: Custom converters for Firestore Timestamps and date strings
- **Comprehensive Testing**: Unit tests for all models and utilities
- **Null-Safe**: Full null safety support

## Models

### AppUser
Represents a user in the system.

```dart
final AppUser user = AppUser(
  uid: 'user-123',
  email: 'john.doe@example.com',
  firstName: 'John',
  lastName: 'Doe',
  active: true,
  createdAt: DateTime.now(),
  lastLoginAt: DateTime.now(),
);

// Access computed properties
print(user.fullName); // "John Doe"
print(user.isNewUser); // true if created within last 24 hours
```

### Desk
Represents a bookable desk/workspace.

```dart
final Desk desk = Desk(
  id: 'desk-123',
  name: 'Corner Desk',
  code: 'A1',
  enabled: true,
  notes: 'Near the window',
  createdAt: DateTime.now(),
);

print(desk.displayName); // "Corner Desk (A1)"
print(desk.isAvailable); // true
```

### Reservation
Represents a desk booking.

```dart
final Reservation reservation = Reservation(
  id: 'reservation-123',
  userId: 'user-456',
  deskId: 'desk-789',
  date: '2024-01-15',
  status: ReservationStatus.active,
  start: DateTime(2024, 1, 15, 9, 0),
  end: DateTime(2024, 1, 15, 17, 0),
  createdAt: DateTime.now(),
);

print(reservation.isActive); // true
print(reservation.hasTimeRange); // true
print(reservation.duration?.inHours); // 8
```

### Lock Models
Prevent double booking and enforce business rules.

#### DeskDayLock
Ensures a desk can only be booked once per day.

```dart
final DeskDayLock lock = DeskDayLock(
  id: 'desk-123_2024-01-15', // Generated format: deskId_YYYY-MM-DD
  deskId: 'desk-123',
  date: '2024-01-15',
  reservationId: 'reservation-456',
  userId: 'user-789',
  createdAt: DateTime.now(),
);
```

#### UserDayLock
Ensures a user can only book one desk per day.

```dart
final UserDayLock lock = UserDayLock(
  id: 'user-789_2024-01-15', // Generated format: userId_YYYY-MM-DD
  userId: 'user-789',
  date: '2024-01-15',
  reservationId: 'reservation-456',
  deskId: 'desk-123',
  createdAt: DateTime.now(),
);
```

## Utilities

### Converters

#### TimestampConverter
Converts between Firestore Timestamp and DateTime.

```dart
@TimestampConverter()
DateTime? createdAt;
```

#### DateYmdConverter
Converts between YYYY-MM-DD strings and DateTime.

```dart
@DateYmdConverter()
DateTime? dateField;
```

#### Utility Functions
```dart
// Format DateTime to YYYY-MM-DD
String dateString = formatDateYmd(DateTime.now());

// Parse YYYY-MM-DD to DateTime
DateTime date = parseDateYmd('2024-01-15');

// Get today as YYYY-MM-DD
String today = getTodayYmd();

// Validate date string format
bool isValid = isValidDateYmd('2024-01-15'); // true
bool isInvalid = isValidDateYmd('2024-1-15'); // false (not zero-padded)
```

### Firestore References

Type-safe access to Firestore collections:

```dart
// Collection references
CollectionReference usersCollection = FirestoreRefs.usersRef;
CollectionReference desksCollection = FirestoreRefs.desksRef;
CollectionReference reservationsCollection = FirestoreRefs.reservationsRef;

// Document references
DocumentReference userDoc = FirestoreRefs.userDocRef('user-123');
DocumentReference deskDoc = FirestoreRefs.deskDocRef('desk-456');

// Lock ID helpers
String deskLockId = LockIdHelpers.generateDeskDayLockId('desk-123', '2024-01-15');
String userLockId = LockIdHelpers.generateUserDayLockId('user-456', '2024-01-15');

// Parse lock IDs
var deskParsed = LockIdHelpers.parseDeskDayLockId('desk-123_2024-01-15');
print(deskParsed.deskId); // 'desk-123'
print(deskParsed.date);   // '2024-01-15'
```

## Usage

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  shared:
    path: ../../packages/shared
```

### Import

```dart
import 'package:shared/shared.dart';
```

### JSON Serialization

All models support JSON serialization:

```dart
// To JSON
Map<String, dynamic> json = user.toJson();

// From JSON
AppUser user = AppUser.fromJson(json);
```

### Firestore Integration

Models work seamlessly with Firestore:

```dart
// Save to Firestore
await FirestoreRefs.userDocRef(user.uid).set(user.toJson());

// Load from Firestore
DocumentSnapshot doc = await FirestoreRefs.userDocRef('user-123').get();
AppUser user = AppUser.fromJson(doc.data() as Map<String, dynamic>);
```

## Development

### Running Tests

```bash
flutter test
```

### Regenerating Code

After modifying models, regenerate Freezed code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Code Analysis

```bash
dart analyze
```

## Architecture Notes

### Date Handling
- All dates in Firestore are stored as Timestamps (converted to DateTime in Dart)
- Date-only fields (like reservation dates) use YYYY-MM-DD string format
- Strict validation ensures consistent date formatting

### Lock Mechanism
- Desk and User day locks prevent double bookings
- Lock IDs follow predictable patterns for efficient queries
- Validation helpers ensure data consistency

### Type Safety
- All models use explicit typing as per project rules
- Firestore references are type-safe to prevent collection name typos
- JSON converters handle type conversions automatically

## Testing

The package includes comprehensive unit tests covering:
- Model serialization/deserialization
- Date conversion and validation
- Lock ID generation and parsing
- Firestore reference utilities
- All extension methods and computed properties

Run tests with `flutter test` to ensure everything works correctly.