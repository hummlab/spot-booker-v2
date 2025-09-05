import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../utils/refs.dart';

/// Data provider for user operations
class UsersDataProvider {
  const UsersDataProvider({
    required FirebaseFirestore firestore,
  });

  /// Get all users stream
  Stream<List<AppUser>> getUsersStream() {
    return FirestoreRefs.usersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return AppUser.fromJson(doc.data());
            } catch (e) {
              // Skip invalid documents
              return null;
            }
          })
          .whereType<AppUser>()
          .toList();
    });
  }

  /// Get a single user by ID
  Future<AppUser?> getUser(String userId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = 
          await FirestoreRefs.userDocRef(userId).get();
      
      if (!doc.exists) return null;
      
      return AppUser.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new user document in Firestore
  Future<void> createUser({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required bool active,
  }) async {
    try {
      final DateTime now = DateTime.now();
      
      final AppUser user = AppUser(
        uid: uid,
        email: email.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        active: active,
        createdAt: now,
        lastLoginAt: null,
      );

      await FirestoreRefs.userDocRef(uid).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Update an existing user
  Future<void> updateUser(AppUser user) async {
    try {
      await FirestoreRefs.userDocRef(user.uid).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Update specific user fields
  Future<void> updateUserFields(String userId, Map<String, dynamic> fields) async {
    try {
      await FirestoreRefs.userDocRef(userId).update(fields);
    } catch (e) {
      throw Exception('Failed to update user fields: $e');
    }
  }

  /// Toggle user active status
  Future<void> toggleUserStatus(String userId, bool active) async {
    try {
      await FirestoreRefs.userDocRef(userId).update(<String, dynamic>{
        'active': active,
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Update user last login time
  Future<void> updateLastLogin(String userId) async {
    try {
      await FirestoreRefs.userDocRef(userId).update(<String, dynamic>{
        'lastLoginAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update last login: $e');
    }
  }

  /// Delete a user (soft delete by setting active to false)
  Future<void> deleteUser(String userId) async {
    try {
      await FirestoreRefs.userDocRef(userId).update(<String, dynamic>{
        'active': false,
      });
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Get users count
  Future<int> getUsersCount() async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.usersRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get active users count
  Future<int> getActiveUsersCount() async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.usersRef
              .where('active', isEqualTo: true)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if user exists by email
  Future<bool> userExistsByEmail(String email) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.usersRef
              .where('email', isEqualTo: email.trim().toLowerCase())
              .limit(1)
              .get();
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Search users by query
  Future<List<AppUser>> searchUsers(String query) async {
    try {
      // Get all users and filter in memory
      // For production, consider using a search service like Algolia
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.usersRef.get();
      
      final List<AppUser> allUsers = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return AppUser.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .whereType<AppUser>()
          .toList();

      final String searchQuery = query.toLowerCase();
      
      return allUsers.where((AppUser user) {
        return user.email.toLowerCase().contains(searchQuery) ||
            user.firstName.toLowerCase().contains(searchQuery) ||
            user.lastName.toLowerCase().contains(searchQuery) ||
            user.fullName.toLowerCase().contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
