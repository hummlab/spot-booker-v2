import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../utils/converters.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// Application user model
@freezed
class AppUser with _$AppUser {
  /// Creates an [AppUser] instance
  const factory AppUser({
    /// Unique user identifier (Firebase Auth UID)
    required String uid,
    
    /// User's email address
    required String email,
    
    /// User's first name
    required String firstName,
    
    /// User's last name
    required String lastName,
    
    /// Whether the user account is active
    required bool active,
    
    /// When the user account was created
    @TimestampConverter() DateTime? createdAt,
    
    /// When the user last logged in
    @TimestampConverter() DateTime? lastLoginAt,
  }) = _AppUser;

  /// Creates an [AppUser] from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) => 
      _$AppUserFromJson(json);
}

/// Extension methods for [AppUser]
extension AppUserExtension on AppUser {
  /// Get the user's full name
  String get fullName => '$firstName $lastName';
  
  /// Check if the user is a new user (created within the last 24 hours)
  bool get isNewUser {
    if (createdAt == null) return false;
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(createdAt!);
    return difference.inHours < 24;
  }
  
  /// Check if the user has logged in recently (within the last 7 days)
  bool get hasRecentLogin {
    if (lastLoginAt == null) return false;
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastLoginAt!);
    return difference.inDays < 7;
  }
}
