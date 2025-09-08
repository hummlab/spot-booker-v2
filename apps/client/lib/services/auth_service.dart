import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';
import 'dart:developer' as developer;

/// Service for handling authentication operations
class AuthService {
  const AuthService({
    required FirebaseAuth firebaseAuth,
    required UsersDataProvider usersDataProvider,
  }) : _firebaseAuth = firebaseAuth,
       _usersDataProvider = usersDataProvider;

  final FirebaseAuth _firebaseAuth;
  final UsersDataProvider _usersDataProvider;

  /// Sign in with email and password
  /// Signs in to Firebase Auth - system approval will be checked separately
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      developer.log('🔐 Starting sign in process for email: $email', name: 'AuthService.signIn');

      // Attempt Firebase Auth sign in
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      developer.log('🔐 Firebase Auth sign in successful. UID: ${userCredential.user?.uid}', name: 'AuthService.signIn');

      if (userCredential.user == null) {
        developer.log('❌ Authentication failed: Firebase Auth returned null user', name: 'AuthService.signIn');
        throw Exception('Authentication failed');
      }

      // Try to update last login time if user exists in our system
      try {
        final String userEmail = userCredential.user!.email ?? '';
        if (userEmail.isNotEmpty) {
          final AppUser? appUser = await _usersDataProvider.getUserByEmail(userEmail);
          if (appUser != null && appUser.active) {
            await _usersDataProvider.updateLastLogin(appUser.uid);
            developer.log('⏰ Last login time updated for approved user (Firestore UID: ${appUser.uid})', name: 'AuthService.signIn');
          } else {
            developer.log('ℹ️ User not yet approved or not found in system - login time not updated', name: 'AuthService.signIn');
          }
        }
      } catch (e) {
        developer.log('⚠️ Could not update last login time: ${e.toString()}', name: 'AuthService.signIn');
        // Don't fail the login just because we couldn't update the timestamp
      }

      developer.log('🎉 Sign in completed successfully', name: 'AuthService.signIn');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('🔥 Firebase Auth Exception: ${e.code} - ${e.message}', name: 'AuthService.signIn');
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email address.');
        case 'wrong-password':
          throw Exception('Incorrect password.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'user-disabled':
          throw Exception('This user account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many failed attempts. Please try again later.');
        case 'invalid-credential':
          throw Exception('Invalid credentials provided.');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      developer.log('💥 General Exception during sign in: ${e.toString()}', name: 'AuthService.signIn');
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  /// Register with email and password
  /// Creates a Firebase Auth user - admin approval will be checked during login
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    developer.log('🚀 Starting registration process for email: $email', name: 'AuthService.register');
    
    try {
      // Create Firebase Auth user directly - no pre-checks needed
      developer.log('🔐 Step 1: Creating Firebase Auth user', name: 'AuthService.register');
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      developer.log('🔐 Step 1 Result: Firebase Auth user created successfully. UID: ${userCredential.user?.uid}', name: 'AuthService.register');

      if (userCredential.user == null) {
        developer.log('❌ Registration failed: Firebase Auth returned null user', name: 'AuthService.register');
        throw Exception('Registration failed');
      }

      developer.log('🎉 Registration completed successfully for user: ${userCredential.user!.uid}', name: 'AuthService.register');
      developer.log('ℹ️ Note: User will need admin approval to access the system', name: 'AuthService.register');
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      developer.log('🔥 Firebase Auth Exception: ${e.code} - ${e.message}', name: 'AuthService.register');
      switch (e.code) {
        case 'weak-password':
          throw Exception('Password is too weak. Please choose a stronger password.');
        case 'email-already-in-use':
          throw Exception('An account already exists with this email address.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      developer.log('💥 General Exception during registration: ${e.toString()}', name: 'AuthService.register');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      // Check if user exists in our system first
      final bool userExists = await _usersDataProvider.userExistsByEmail(email);
      if (!userExists) {
        throw Exception('User not found in system. Please contact administrator.');
      }

      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email address.');
        case 'invalid-email':
          throw Exception('Invalid email address format.');
        case 'too-many-requests':
          throw Exception('Too many requests. Please try again later.');
        default:
          throw Exception('Failed to send reset email: ${e.message}');
      }
    } catch (e) {
      if (e.toString().contains('User not found in system')) {
        rethrow;
      }
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Check if user is signed in
  bool isSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  /// Get auth state changes stream
  Stream<User?> getAuthStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  /// Check user status in the system by email
  /// Returns null if user doesn't exist in Firestore
  /// Returns AppUser if user exists (regardless of active status)
  Future<AppUser?> checkUserStatus() async {
    try {
      final User? currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        developer.log('❌ No current Firebase Auth user', name: 'AuthService.checkUserStatus');
        return null;
      }

      final String email = currentUser.email ?? '';
      if (email.isEmpty) {
        developer.log('❌ Current user has no email', name: 'AuthService.checkUserStatus');
        return null;
      }

      developer.log('🔍 Checking user status by email: $email (Firebase UID: ${currentUser.uid})', name: 'AuthService.checkUserStatus');
      
      // Check if user exists in our Firestore database BY EMAIL
      final bool userExistsByEmail = await _usersDataProvider.userExistsByEmail(email);
      
      if (!userExistsByEmail) {
        developer.log('⏳ User not yet added to system by administrator (email not found)', name: 'AuthService.checkUserStatus');
        return null;
      }

      // Get user by email to find the actual user document
      final AppUser? appUser = await _usersDataProvider.getUserByEmail(email);
      
      if (appUser == null) {
        developer.log('⚠️ User exists by email check but getUserByEmail returned null', name: 'AuthService.checkUserStatus');
        return null;
      }

      developer.log('✅ User found in system by email. Active: ${appUser.active}, Firestore UID: ${appUser.uid}', name: 'AuthService.checkUserStatus');
      return appUser;
    } catch (e) {
      developer.log('💥 Error checking user status: ${e.toString()}', name: 'AuthService.checkUserStatus');
      return null;
    }
  }


  /// Check if current user is approved and active
  Future<bool> isUserApprovedAndActive() async {
    try {
      developer.log('🔍 Starting isUserApprovedAndActive check', name: 'AuthService.isUserApprovedAndActive');
      final AppUser? appUser = await checkUserStatus();
      
      if (appUser == null) {
        developer.log('❌ User not found in system (appUser is null)', name: 'AuthService.isUserApprovedAndActive');
        return false;
      }
      
      developer.log('👤 User found: ${appUser.email}, active: ${appUser.active}', name: 'AuthService.isUserApprovedAndActive');
      final bool result = appUser.active;
      developer.log('✅ Final approval result: $result', name: 'AuthService.isUserApprovedAndActive');
      return result;
    } catch (e) {
      developer.log('💥 Error checking if user is approved and active: ${e.toString()}', name: 'AuthService.isUserApprovedAndActive');
      return false;
    }
  }
}
