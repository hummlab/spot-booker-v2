import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';

/// Repository for managing reservations
class ReservationsRepository {
  const ReservationsRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Get all reservations with optional filtering
  Stream<List<Reservation>> getReservations({
    String? searchQuery,
    String? date,
    ReservationStatus? status,
    String? userId,
    String? deskId,
  }) {
    Query<Map<String, dynamic>> query = FirestoreRefs.reservationsRef;
    
    // Apply filters
    if (date != null) {
      query = query.where('date', isEqualTo: date);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }
    if (userId != null) {
      query = query.where('userId', isEqualTo: userId);
    }
    if (deskId != null) {
      query = query.where('deskId', isEqualTo: deskId);
    }
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      List<Reservation> reservations = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson(doc.data());
            } catch (e) {
              // Skip invalid documents
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final String query = searchQuery.toLowerCase();
        reservations = reservations.where((Reservation reservation) {
          // Search in reservation ID, user ID, desk ID, notes
          return reservation.id.toLowerCase().contains(query) ||
              reservation.userId.toLowerCase().contains(query) ||
              reservation.deskId.toLowerCase().contains(query) ||
              (reservation.notes?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      return reservations;
    });
  }

  /// Get a single reservation by ID
  Future<Reservation?> getReservation(String reservationId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = 
          await FirestoreRefs.reservationDocRef(reservationId).get();
      
      if (!doc.exists) return null;
      
      return Reservation.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new reservation (admin only)
  Future<void> createReservation({
    required String userId,
    required String deskId,
    required String date,
    DateTime? start,
    DateTime? end,
    String? notes,
  }) async {
    final WriteBatch batch = _firestore.batch();
    
    try {
      final String reservationId = FirestoreRefs.reservationsRef.doc().id;
      final DateTime now = DateTime.now();
      
      // Create reservation
      final Reservation reservation = Reservation(
        id: reservationId,
        userId: userId,
        deskId: deskId,
        date: date,
        start: start,
        end: end,
        status: ReservationStatus.active,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: now,
      );

      batch.set(
        FirestoreRefs.reservationDocRef(reservationId),
        reservation.toJson(),
      );

      // Create desk day lock
      final String lockId = '${deskId}_$date';
      final DeskDayLock deskLock = DeskDayLock(
        id: lockId,
        deskId: deskId,
        date: date,
        reservationId: reservationId,
        userId: userId,
        createdAt: now,
      );

      batch.set(
        FirestoreRefs.deskDayLockDocRef(lockId),
        deskLock.toJson(),
      );

      // Create user day lock
      final String userLockId = '${userId}_$date';
      final UserDayLock userLock = UserDayLock(
        id: userLockId,
        userId: userId,
        date: date,
        reservationId: reservationId,
        deskId: deskId,
        createdAt: now,
      );

      batch.set(
        FirestoreRefs.userDayLockDocRef(userLockId),
        userLock.toJson(),
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create reservation: $e');
    }
  }

  /// Cancel a reservation
  Future<void> cancelReservation(String reservationId) async {
    final WriteBatch batch = _firestore.batch();
    
    try {
      // Get the reservation first
      final Reservation? reservation = await getReservation(reservationId);
      if (reservation == null) {
        throw Exception('Reservation not found');
      }

      if (reservation.status == ReservationStatus.cancelled) {
        throw Exception('Reservation is already cancelled');
      }

      // Update reservation status
      final Reservation cancelledReservation = reservation.copyWith(
        status: ReservationStatus.cancelled,
        cancelledAt: DateTime.now(),
      );

      batch.update(
        FirestoreRefs.reservationDocRef(reservationId),
        cancelledReservation.toJson(),
      );

      // Remove desk day lock
      final String deskLockId = '${reservation.deskId}_${reservation.date}';
      batch.delete(FirestoreRefs.deskDayLockDocRef(deskLockId));

      // Remove user day lock
      final String userLockId = '${reservation.userId}_${reservation.date}';
      batch.delete(FirestoreRefs.userDayLockDocRef(userLockId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  /// Delete a reservation permanently (admin only)
  Future<void> deleteReservation(String reservationId) async {
    final WriteBatch batch = _firestore.batch();
    
    try {
      // Get the reservation first
      final Reservation? reservation = await getReservation(reservationId);
      if (reservation == null) {
        throw Exception('Reservation not found');
      }

      // Delete reservation
      batch.delete(FirestoreRefs.reservationDocRef(reservationId));

      // Delete desk day lock (if exists)
      final String deskLockId = '${reservation.deskId}_${reservation.date}';
      batch.delete(FirestoreRefs.deskDayLockDocRef(deskLockId));

      // Delete user day lock (if exists)
      final String userLockId = '${reservation.userId}_${reservation.date}';
      batch.delete(FirestoreRefs.userDayLockDocRef(userLockId));

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete reservation: $e');
    }
  }

  /// Get reservations count for statistics
  Future<int> getReservationsCount() async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.reservationsRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get active reservations count
  Future<int> getActiveReservationsCount() async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.reservationsRef
              .where('status', isEqualTo: 'active')
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get reservations for a specific date
  Future<List<Reservation>> getReservationsForDate(String date) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('date', isEqualTo: date)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get reservations for date: $e');
    }
  }

  /// Get reservations for a specific user
  Future<List<Reservation>> getReservationsForUser(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get reservations for user: $e');
    }
  }

  /// Get reservations for a specific desk
  Future<List<Reservation>> getReservationsForDesk(String deskId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('deskId', isEqualTo: deskId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get reservations for desk: $e');
    }
  }

  /// Check if a desk is available for a specific date
  Future<bool> isDeskAvailable(String deskId, String date) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('deskId', isEqualTo: deskId)
              .where('date', isEqualTo: date)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if a user can make a reservation for a specific date
  Future<bool> canUserReserve(String userId, String date) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('userId', isEqualTo: userId)
              .where('date', isEqualTo: date)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .get();

      return snapshot.docs.isEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for ReservationsRepository
final reservationsRepositoryProvider = Provider<ReservationsRepository>((ProviderRef<ReservationsRepository> ref) {
  return ReservationsRepository(firestore: FirebaseFirestore.instance);
});

/// Provider for reservations stream with optional filters
final reservationsStreamProvider = StreamProvider.family<List<Reservation>, ReservationFilters?>((
  StreamProviderRef<List<Reservation>> ref,
  ReservationFilters? filters,
) {
  final ReservationsRepository repository = ref.watch(reservationsRepositoryProvider);
  return repository.getReservations(
    searchQuery: filters?.searchQuery,
    date: filters?.date,
    status: filters?.status,
    userId: filters?.userId,
    deskId: filters?.deskId,
  );
});

/// Provider for reservations count
final reservationsCountProvider = FutureProvider<int>((FutureProviderRef<int> ref) {
  final ReservationsRepository repository = ref.watch(reservationsRepositoryProvider);
  return repository.getReservationsCount();
});

/// Provider for active reservations count
final activeReservationsCountProvider = FutureProvider<int>((FutureProviderRef<int> ref) {
  final ReservationsRepository repository = ref.watch(reservationsRepositoryProvider);
  return repository.getActiveReservationsCount();
});

/// Provider for reservations for a specific date
final reservationsForDateProvider = FutureProvider.family<List<Reservation>, String>((
  FutureProviderRef<List<Reservation>> ref,
  String date,
) {
  final ReservationsRepository repository = ref.watch(reservationsRepositoryProvider);
  return repository.getReservationsForDate(date);
});

/// Provider for reservations for a specific user
final reservationsForUserProvider = FutureProvider.family<List<Reservation>, String>((
  FutureProviderRef<List<Reservation>> ref,
  String userId,
) {
  final ReservationsRepository repository = ref.watch(reservationsRepositoryProvider);
  return repository.getReservationsForUser(userId);
});

/// Provider for reservations for a specific desk
final reservationsForDeskProvider = FutureProvider.family<List<Reservation>, String>((
  FutureProviderRef<List<Reservation>> ref,
  String deskId,
) {
  final ReservationsRepository repository = ref.watch(reservationsRepositoryProvider);
  return repository.getReservationsForDesk(deskId);
});
