import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Firebase Auth instance provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ProviderRef<FirebaseAuth> ref) {
  return FirebaseAuth.instance;
});

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ProviderRef<FirebaseFirestore> ref) {
  return FirebaseFirestore.instance;
});

/// Firebase Functions instance provider
final functionsProvider = Provider<FirebaseFunctions>((ProviderRef<FirebaseFunctions> ref) {
  return FirebaseFunctions.instance;
});

/// Current user provider
final currentUserProvider = StreamProvider<User?>((StreamProviderRef<User?> ref) {
  final FirebaseAuth auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Auth state provider - returns true if user is logged in
final authStateProvider = Provider<bool>((ProviderRef<bool> ref) {
  final AsyncValue<User?> user = ref.watch(currentUserProvider);
  return user.when(
    data: (User? user) => user != null,
    loading: () => false,
    error: (Object error, StackTrace stackTrace) => false,
  );
});

/// Loading state provider for global loading indicator
final globalLoadingProvider = StateProvider<bool>((StateProviderRef<bool> ref) => false);

/// Error message provider for global error display
final globalErrorProvider = StateProvider<String?>((StateProviderRef<String?> ref) => null);

/// Selected date filter provider (for reservations)
final selectedDateProvider = StateProvider<DateTime?>((StateProviderRef<DateTime?> ref) => null);

/// Search query provider for filtering
final searchQueryProvider = StateProvider<String>((StateProviderRef<String> ref) => '');

/// Page size for pagination
final pageSizeProvider = Provider<int>((ProviderRef<int> ref) => 20);

/// Current page provider for pagination
final currentPageProvider = StateProvider<int>((StateProviderRef<int> ref) => 0);
