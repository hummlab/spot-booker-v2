import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/converters.dart';
import '../../utils/refs.dart';

part 'user_day_lock.freezed.dart';
part 'user_day_lock.g.dart';

/// User day lock model to prevent users from making multiple reservations per day
@freezed
class UserDayLock with _$UserDayLock {
  /// Creates a [UserDayLock] instance
  const factory UserDayLock({
    /// Unique lock identifier in format: userId_YYYY-MM-DD
    required String id,
    
    /// ID of the user being locked
    required String userId,
    
    /// Date of the lock in YYYY-MM-DD format
    required String date,
    
    /// ID of the reservation that created this lock
    required String reservationId,
    
    /// ID of the desk being reserved
    required String deskId,
    
    /// When the lock was created
    @TimestampConverter() DateTime? createdAt,
  }) = _UserDayLock;

  /// Creates a [UserDayLock] from JSON
  factory UserDayLock.fromJson(Map<String, dynamic> json) => 
      _$UserDayLockFromJson(json);
}

/// Extension methods for [UserDayLock]
extension UserDayLockExtension on UserDayLock {
  /// Parse the date string to DateTime
  DateTime get dateAsDateTime {
    final List<String> parts = date.split('-');
    return DateTime(
      int.parse(parts[0]), // year
      int.parse(parts[1]), // month
      int.parse(parts[2]), // day
    );
  }
  
  /// Check if the lock is for today
  bool get isToday {
    final DateTime now = DateTime.now();
    final DateTime lockDate = dateAsDateTime;
    return now.year == lockDate.year &&
        now.month == lockDate.month &&
        now.day == lockDate.day;
  }
  
  /// Check if the lock is in the past
  bool get isPast {
    final DateTime now = DateTime.now();
    final DateTime lockDate = dateAsDateTime;
    return lockDate.isBefore(DateTime(now.year, now.month, now.day));
  }
  
  /// Check if the lock is in the future
  bool get isFuture {
    final DateTime now = DateTime.now();
    final DateTime lockDate = dateAsDateTime;
    return lockDate.isAfter(DateTime(now.year, now.month, now.day));
  }
  
  /// Validate that the lock ID matches the expected format
  bool get hasValidId {
    try {
      final ({String userId, String date}) parsed = 
          LockIdHelpers.parseUserDayLockId(id);
      return parsed.userId == userId && 
             parsed.date == date &&
             LockIdHelpers.isValidLockDate(date);
    } catch (e) {
      return false;
    }
  }
  
}
