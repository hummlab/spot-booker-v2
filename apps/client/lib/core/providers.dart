import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../services/auth_service.dart';

// Firebase providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ProviderRef<FirebaseAuth> ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ProviderRef<FirebaseFirestore> ref) {
  return FirebaseFirestore.instance;
});

// Data providers
final usersDataProvider = Provider<UsersDataProvider>((ProviderRef<UsersDataProvider> ref) {
  final FirebaseFirestore firestore = ref.watch(firestoreProvider);
  return UsersDataProvider(firestore: firestore);
});

final desksDataProvider = Provider<DesksDataProvider>((ProviderRef<DesksDataProvider> ref) {
  final FirebaseFirestore firestore = ref.watch(firestoreProvider);
  return DesksDataProvider(firestore: firestore);
});

final reservationsDataProvider = Provider<ReservationsDataProvider>((ProviderRef<ReservationsDataProvider> ref) {
  final FirebaseFirestore firestore = ref.watch(firestoreProvider);
  return ReservationsDataProvider(firestore: firestore);
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ProviderRef<AuthService> ref) {
  final FirebaseAuth firebaseAuth = ref.watch(firebaseAuthProvider);
  final UsersDataProvider usersProvider = ref.watch(usersDataProvider);
  return AuthService(
    firebaseAuth: firebaseAuth,
    usersDataProvider: usersProvider,
  );
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((StreamProviderRef<User?> ref) {
  final FirebaseAuth auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// Current user provider
final currentUserProvider = StreamProvider<AppUser?>((StreamProviderRef<AppUser?> ref) {
  final AsyncValue<User?> authState = ref.watch(authStateProvider);
  final UsersDataProvider usersProvider = ref.watch(usersDataProvider);
  
  return authState.when(
    data: (User? firebaseUser) {
      if (firebaseUser == null) {
        return Stream.value(null);
      }
      
      return Stream.fromFuture(usersProvider.getUser(firebaseUser.uid));
    },
    loading: () => Stream.value(null),
    error: (Object error, StackTrace stackTrace) => Stream.value(null),
  );
});

// User reservations provider
final userReservationsProvider = StreamProvider.family<List<Reservation>, String>(
  (StreamProviderRef<List<Reservation>> ref, String userId) {
    final ReservationsDataProvider reservationsProvider = ref.watch(reservationsDataProvider);
    return reservationsProvider.getUserReservationsStream(userId);
  },
);

// User active reservations provider
final userActiveReservationsProvider = StreamProvider.family<List<Reservation>, String>(
  (StreamProviderRef<List<Reservation>> ref, String userId) {
    final ReservationsDataProvider reservationsProvider = ref.watch(reservationsDataProvider);
    return reservationsProvider.getUserActiveReservationsStream(userId);
  },
);

// Available desks provider for a specific date
final availableDesksProvider = FutureProvider.family<List<Desk>, String>(
  (FutureProviderRef<List<Desk>> ref, String date) {
    final DesksDataProvider desksProvider = ref.watch(desksDataProvider);
    return desksProvider.getAvailableDesks(date);
  },
);

// All desks provider
final allDesksProvider = StreamProvider<List<Desk>>((StreamProviderRef<List<Desk>> ref) {
  final DesksDataProvider desksProvider = ref.watch(desksDataProvider);
  return desksProvider.getDesksStream();
});

// Selected date provider for booking
final selectedDateProvider = StateProvider<DateTime>((StateProviderRef<DateTime> ref) {
  return DateTime.now();
});

// Loading state provider
final isLoadingProvider = StateProvider<bool>((StateProviderRef<bool> ref) {
  return false;
});

// Error message provider
final errorMessageProvider = StateProvider<String?>((StateProviderRef<String?> ref) {
  return null;
});

// Success message provider
final successMessageProvider = StateProvider<String?>((StateProviderRef<String?> ref) {
  return null;
});
