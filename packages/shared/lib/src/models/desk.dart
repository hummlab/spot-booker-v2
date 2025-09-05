import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/converters.dart';

part 'desk.freezed.dart';
part 'desk.g.dart';

/// Desk model representing a bookable workspace
@freezed
class Desk with _$Desk {
  /// Creates a [Desk] instance
  const factory Desk({
    /// Unique desk identifier
    required String id,
    
    /// Display name of the desk
    required String name,
    
    /// Short code for the desk (e.g., "A1", "B2")
    required String code,
    
    /// Whether the desk is available for booking
    required bool enabled,
    
    /// Optional notes about the desk
    String? notes,
    
    /// When the desk was created
    @TimestampConverter() DateTime? createdAt,
    
    /// When the desk was last updated
    @TimestampConverter() DateTime? updatedAt,
  }) = _Desk;

  /// Creates a [Desk] from JSON
  factory Desk.fromJson(Map<String, dynamic> json) => _$DeskFromJson(json);
}

/// Extension methods for [Desk]
extension DeskExtension on Desk {
  /// Get a display string for the desk
  String get displayName => '$name ($code)';
  
  /// Check if the desk is available for booking
  bool get isAvailable => enabled;
  
  /// Check if the desk has notes
  bool get hasNotes => notes != null && notes!.isNotEmpty;
}
