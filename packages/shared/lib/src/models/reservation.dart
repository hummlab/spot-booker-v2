import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/converters.dart';

part 'reservation.freezed.dart';
part 'reservation.g.dart';

/// Reservation status enumeration
enum ReservationStatus {
  /// Reservation is active
  @JsonValue('active')
  active,
  
  /// Reservation has been cancelled
  @JsonValue('cancelled')
  cancelled,
}

/// Reservation model representing a desk booking
@freezed
class Reservation with _$Reservation {
  /// Creates a [Reservation] instance
  const factory Reservation({
    /// Unique reservation identifier
    required String id,
    
    /// ID of the user who made the reservation
    required String userId,
    
    /// ID of the desk being reserved
    required String deskId,
    
    /// Date of the reservation in YYYY-MM-DD format
    required String date,
    
    /// Optional start time for the reservation
    @TimestampConverter() DateTime? start,
    
    /// Optional end time for the reservation
    @TimestampConverter() DateTime? end,
    
    /// Status of the reservation
    @Default(ReservationStatus.active) ReservationStatus status,
    
    /// When the reservation was created
    @TimestampConverter() DateTime? createdAt,
    
    /// When the reservation was cancelled (if applicable)
    @TimestampConverter() DateTime? cancelledAt,
    
    /// Optional notes about the reservation
    String? notes,
  }) = _Reservation;

  /// Creates a [Reservation] from JSON
  factory Reservation.fromJson(Map<String, dynamic> json) => 
      _$ReservationFromJson(json);
}

/// Extension methods for [Reservation]
extension ReservationExtension on Reservation {
  /// Check if the reservation is active
  bool get isActive => status == ReservationStatus.active;
  
  /// Check if the reservation is cancelled
  bool get isCancelled => status == ReservationStatus.cancelled;
  
  /// Check if the reservation has a time range
  bool get hasTimeRange => start != null && end != null;
  
  /// Get the duration of the reservation (if time range is specified)
  Duration? get duration {
    if (!hasTimeRange) return null;
    return end!.difference(start!);
  }
  
  /// Check if the reservation has notes
  bool get hasNotes => notes != null && notes!.isNotEmpty;
  
  /// Parse the date string to DateTime
  DateTime get dateAsDateTime {
    final List<String> parts = date.split('-');
    return DateTime(
      int.parse(parts[0]), // year
      int.parse(parts[1]), // month
      int.parse(parts[2]), // day
    );
  }
  
  /// Check if the reservation is for today
  bool get isToday {
    final DateTime now = DateTime.now();
    final DateTime reservationDate = dateAsDateTime;
    return now.year == reservationDate.year &&
        now.month == reservationDate.month &&
        now.day == reservationDate.day;
  }
  
  /// Check if the reservation is in the past
  bool get isPast {
    final DateTime now = DateTime.now();
    final DateTime reservationDate = dateAsDateTime;
    return reservationDate.isBefore(DateTime(now.year, now.month, now.day));
  }
  
  /// Check if the reservation is in the future
  bool get isFuture {
    final DateTime now = DateTime.now();
    final DateTime reservationDate = dateAsDateTime;
    return reservationDate.isAfter(DateTime(now.year, now.month, now.day));
  }
}
