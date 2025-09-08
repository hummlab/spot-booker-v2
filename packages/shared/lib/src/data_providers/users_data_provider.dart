import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

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
      developer.log('👤 Getting user by UID: $userId', name: 'UsersDataProvider.getUser');
      developer.log('👤 Document path: users/$userId', name: 'UsersDataProvider.getUser');
      
      final DocumentSnapshot<Map<String, dynamic>> doc = 
          await FirestoreRefs.userDocRef(userId).get();
      
      developer.log('👤 Document exists: ${doc.exists}', name: 'UsersDataProvider.getUser');
      developer.log('👤 Document ID: ${doc.id}', name: 'UsersDataProvider.getUser');
      
      if (!doc.exists) {
        developer.log('👤 User document not found for UID: $userId', name: 'UsersDataProvider.getUser');
        
        // Let's also try to find user by email to debug
        developer.log('🔍 Searching for user in all documents to debug...', name: 'UsersDataProvider.getUser');
        try {
          final QuerySnapshot<Map<String, dynamic>> allUsers = await FirestoreRefs.usersRef.get();
          developer.log('📋 Found ${allUsers.docs.length} total user documents', name: 'UsersDataProvider.getUser');
          for (final doc in allUsers.docs) {
            developer.log('📄 Document ID: ${doc.id}, Data: ${doc.data()}', name: 'UsersDataProvider.getUser');
          }
        } catch (debugError) {
          developer.log('💥 Error in debug search: $debugError', name: 'UsersDataProvider.getUser');
        }
        
        return null;
      }
      
      final Map<String, dynamic>? data = doc.data();
      developer.log('👤 Document data: ${data.toString()}', name: 'UsersDataProvider.getUser');
      
      final AppUser user = AppUser.fromJson(data!);
      developer.log('👤 Successfully parsed user: ${user.email} (active: ${user.active}, uid: ${user.uid})', name: 'UsersDataProvider.getUser');
      
      return user;
    } catch (e) {
      developer.log('💥 Error getting user by UID: ${e.toString()}', name: 'UsersDataProvider.getUser');
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

  /// Permanently delete a user from Firestore
  Future<void> permanentlyDeleteUser(String userId) async {
    try {
      await FirestoreRefs.userDocRef(userId).delete();
    } catch (e) {
      throw Exception('Failed to permanently delete user: $e');
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
      developer.log('🔍 Checking if user exists by email: ${email.trim().toLowerCase()}', name: 'UsersDataProvider.userExistsByEmail');
      
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.usersRef
              .where('email', isEqualTo: email.trim().toLowerCase())
              .limit(1)
              .get();
      
      final bool exists = snapshot.docs.isNotEmpty;
      developer.log('🔍 User exists result: $exists (found ${snapshot.docs.length} documents)', name: 'UsersDataProvider.userExistsByEmail');
      
      if (exists) {
        final Map<String, dynamic> userData = snapshot.docs.first.data();
        developer.log('📋 Found user data: ${userData.toString()}', name: 'UsersDataProvider.userExistsByEmail');
      }
      
      return exists;
    } catch (e) {
      developer.log('💥 Error checking user existence: ${e.toString()}', name: 'UsersDataProvider.userExistsByEmail');
      return false;
    }
  }

  /// Get user by email address
  Future<AppUser?> getUserByEmail(String email) async {
    try {
      developer.log('📧 Getting user by email: ${email.trim().toLowerCase()}', name: 'UsersDataProvider.getUserByEmail');
      
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.usersRef
              .where('email', isEqualTo: email.trim().toLowerCase())
              .limit(1)
              .get();
      
      if (snapshot.docs.isEmpty) {
        developer.log('❌ No user found with email: ${email.trim().toLowerCase()}', name: 'UsersDataProvider.getUserByEmail');
        return null;
      }

      final Map<String, dynamic> userData = snapshot.docs.first.data();
      developer.log('📋 Found user document: ${userData.toString()}', name: 'UsersDataProvider.getUserByEmail');
      
      final AppUser user = AppUser.fromJson(userData);
      developer.log('✅ Successfully parsed user: ${user.email} (UID: ${user.uid}, active: ${user.active})', name: 'UsersDataProvider.getUserByEmail');
      
      return user;
    } catch (e) {
      developer.log('💥 Error getting user by email: ${e.toString()}', name: 'UsersDataProvider.getUserByEmail');
      return null;
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
