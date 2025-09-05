import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared/shared.dart';

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
  /// Validates that the user exists in the users collection and is active
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // First check if user exists in our system
      final bool userExists = await _usersDataProvider.userExistsByEmail(email);
      if (!userExists) {
        throw Exception('User not found in system. Please contact administrator.');
      }

      // Attempt Firebase Auth sign in
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Authentication failed');
      }

      // Get user data from Firestore
      final AppUser? appUser = await _usersDataProvider.getUser(userCredential.user!.uid);
      
      if (appUser == null) {
        // Sign out if user not found in our system
        await _firebaseAuth.signOut();
        throw Exception('User account not found in system. Please contact administrator.');
      }

      if (!appUser.active) {
        // Sign out if user is not active
        await _firebaseAuth.signOut();
        throw Exception('User account is inactive. Please contact administrator.');
      }

      // Update last login time
      await _usersDataProvider.updateLastLogin(userCredential.user!.uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
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
      if (e.toString().contains('User not found in system') ||
          e.toString().contains('User account not found') ||
          e.toString().contains('User account is inactive')) {
        rethrow;
      }
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  /// Register with email and password
  /// Note: This creates a Firebase Auth user but does NOT create the user document
  /// The user document should be created by an administrator
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Check if user already exists in our system
      final bool userExists = await _usersDataProvider.userExistsByEmail(email);
      if (!userExists) {
        throw Exception('User not found in system. Please contact administrator to add your account first.');
      }

      // Create Firebase Auth user
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw Exception('Registration failed');
      }

      // Verify user exists and is active in our system
      final AppUser? appUser = await _usersDataProvider.getUser(userCredential.user!.uid);
      
      if (appUser == null) {
        // Delete the Firebase Auth user if not in our system
        await userCredential.user!.delete();
        throw Exception('User account not found in system. Please contact administrator.');
      }

      if (!appUser.active) {
        // Delete the Firebase Auth user if not active
        await userCredential.user!.delete();
        throw Exception('User account is inactive. Please contact administrator.');
      }

      // Update last login time
      await _usersDataProvider.updateLastLogin(userCredential.user!.uid);

      return userCredential;
    } on FirebaseAuthException catch (e) {
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
      if (e.toString().contains('User not found in system') ||
          e.toString().contains('User account not found') ||
          e.toString().contains('User account is inactive')) {
        rethrow;
      }
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
}
