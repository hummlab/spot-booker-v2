import 'package:cloud_firestore/cloud_firestore.dart';

/// Collection names as constants to avoid typos
class CollectionNames {
  static const String users = 'users';
  static const String desks = 'desks';
  static const String reservations = 'reservations';
  static const String deskDayLocks = 'deskDayLocks';
  static const String userDayLocks = 'userDayLocks';
}

/// Type-safe Firestore collection references
class FirestoreRefs {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Users collection reference
  static CollectionReference<Map<String, dynamic>> get usersRef =>
      _firestore.collection(CollectionNames.users);

  /// Desks collection reference
  static CollectionReference<Map<String, dynamic>> get desksRef =>
      _firestore.collection(CollectionNames.desks);

  /// Reservations collection reference
  static CollectionReference<Map<String, dynamic>> get reservationsRef =>
      _firestore.collection(CollectionNames.reservations);

  /// Desk day locks collection reference
  static CollectionReference<Map<String, dynamic>> get deskDayLocksRef =>
      _firestore.collection(CollectionNames.deskDayLocks);

  /// User day locks collection reference
  static CollectionReference<Map<String, dynamic>> get userDayLocksRef =>
      _firestore.collection(CollectionNames.userDayLocks);

  /// Get a specific user document reference
  static DocumentReference<Map<String, dynamic>> userDocRef(String userId) =>
      usersRef.doc(userId);

  /// Get a specific desk document reference
  static DocumentReference<Map<String, dynamic>> deskDocRef(String deskId) =>
      desksRef.doc(deskId);

  /// Get a specific reservation document reference
  static DocumentReference<Map<String, dynamic>> reservationDocRef(
    String reservationId,
  ) =>
      reservationsRef.doc(reservationId);

  /// Get a specific desk day lock document reference
  static DocumentReference<Map<String, dynamic>> deskDayLockDocRef(
    String lockId,
  ) =>
      deskDayLocksRef.doc(lockId);

  /// Get a specific user day lock document reference
  static DocumentReference<Map<String, dynamic>> userDayLockDocRef(
    String lockId,
  ) =>
      userDayLocksRef.doc(lockId);
}

/// Helper functions for generating lock IDs
class LockIdHelpers {
  /// Generate desk day lock ID: deskId_YYYY-MM-DD
  static String generateDeskDayLockId(String deskId, String date) {
    return '${deskId}_$date';
  }

  /// Generate user day lock ID: userId_YYYY-MM-DD
  static String generateUserDayLockId(String userId, String date) {
    return '${userId}_$date';
  }

  /// Parse desk day lock ID to extract desk ID and date
  static ({String deskId, String date}) parseDeskDayLockId(String lockId) {
    final List<String> parts = lockId.split('_');
    if (parts.length < 2) {
      throw FormatException('Invalid desk day lock ID format: $lockId');
    }
    
    final String deskId = parts.sublist(0, parts.length - 1).join('_');
    final String date = parts.last;
    
    return (deskId: deskId, date: date);
  }

  /// Parse user day lock ID to extract user ID and date
  static ({String userId, String date}) parseUserDayLockId(String lockId) {
    final List<String> parts = lockId.split('_');
    if (parts.length < 2) {
      throw FormatException('Invalid user day lock ID format: $lockId');
    }
    
    final String userId = parts.sublist(0, parts.length - 1).join('_');
    final String date = parts.last;
    
    return (userId: userId, date: date);
  }

  /// Validate date format for lock IDs (YYYY-MM-DD)
  static bool isValidLockDate(String date) {
    final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      return false;
    }
    
    try {
      final List<String> parts = date.split('-');
      final int year = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int day = int.parse(parts[2]);
      
      // Basic validation
      if (year < 1900 || year > 2100) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;
      
      // More precise validation using DateTime
      final DateTime parsedDate = DateTime(year, month, day);
      return parsedDate.year == year &&
          parsedDate.month == month &&
          parsedDate.day == day;
    } catch (e) {
      return false;
    }
  }
}
