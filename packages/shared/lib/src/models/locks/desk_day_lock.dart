import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/converters.dart';
import '../../utils/refs.dart';

part 'desk_day_lock.freezed.dart';
part 'desk_day_lock.g.dart';

/// Desk day lock model to prevent double booking of desks
@freezed
class DeskDayLock with _$DeskDayLock {
  /// Creates a [DeskDayLock] instance
  const factory DeskDayLock({
    /// Unique lock identifier in format: deskId_YYYY-MM-DD
    required String id,
    
    /// ID of the desk being locked
    required String deskId,
    
    /// Date of the lock in YYYY-MM-DD format
    required String date,
    
    /// ID of the reservation that created this lock
    required String reservationId,
    
    /// ID of the user who made the reservation
    required String userId,
    
    /// When the lock was created
    @TimestampConverter() DateTime? createdAt,
  }) = _DeskDayLock;

  /// Creates a [DeskDayLock] from JSON
  factory DeskDayLock.fromJson(Map<String, dynamic> json) => 
      _$DeskDayLockFromJson(json);
}

/// Extension methods for [DeskDayLock]
extension DeskDayLockExtension on DeskDayLock {
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
      final ({String deskId, String date}) parsed = 
          LockIdHelpers.parseDeskDayLockId(id);
      return parsed.deskId == deskId && 
             parsed.date == date &&
             LockIdHelpers.isValidLockDate(date);
    } catch (e) {
      return false;
    }
  }
  
}
