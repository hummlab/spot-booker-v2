import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import '../models/reservation.dart';
import '../models/locks/desk_day_lock.dart';
import '../utils/refs.dart';
import '../utils/converters.dart';

/// Data provider for reservation operations
class ReservationsDataProvider {
  const ReservationsDataProvider({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Get all reservations stream
  Stream<List<Reservation>> getReservationsStream() {
    return FirestoreRefs.reservationsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              // Skip invalid documents
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    });
  }

  /// Get reservations for a specific user
  Stream<List<Reservation>> getUserReservationsStream(String userId) {
    return FirestoreRefs.reservationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              // Skip invalid documents
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    });
  }

  /// Get active reservations for a specific user
  Stream<List<Reservation>> getUserActiveReservationsStream(String userId) {
    return FirestoreRefs.reservationsRef
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('date', descending: false)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              // Skip invalid documents
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    });
  }

  /// Get a single reservation by ID
  Future<Reservation?> getReservation(String reservationId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = 
          await FirestoreRefs.reservationDocRef(reservationId).get();
      
      if (!doc.exists) return null;
      
      return Reservation.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new reservation with transaction to ensure atomicity
  Future<String> createReservation({
    required String userId,
    required String deskId,
    required String date,
    String? notes,
  }) async {
    try {
      // Validate date format
      if (!isValidDateYmd(date)) {
        throw Exception('Invalid date format. Expected YYYY-MM-DD');
      }

      // Check if date is not in the past
      final DateTime reservationDate = parseDateYmd(date);
      final DateTime today = DateTime.now();
      final DateTime todayDate = DateTime(today.year, today.month, today.day);
      
      if (reservationDate.isBefore(todayDate)) {
        throw Exception('Cannot create reservation in the past');
      }

      final String reservationId = FirestoreRefs.reservationsRef.doc().id;
      final String lockId = LockIdHelpers.generateDeskDayLockId(deskId, date);
      final DateTime now = DateTime.now();

      // Use transaction to ensure atomicity
      await _firestore.runTransaction((Transaction transaction) async {
        // Check if desk is already booked for this date
        final DocumentSnapshot<Map<String, dynamic>> lockDoc = 
            await transaction.get(FirestoreRefs.deskDayLockDocRef(lockId));

        if (lockDoc.exists) {
          throw Exception('Desk is already booked for this date');
        }

        // Check if desk exists and is enabled
        final DocumentSnapshot<Map<String, dynamic>> deskDoc = 
            await transaction.get(FirestoreRefs.deskDocRef(deskId));

        if (!deskDoc.exists) {
          throw Exception('Desk not found');
        }

        final Map<String, dynamic> deskData = deskDoc.data()!;
        if (deskData['enabled'] != true) {
          throw Exception('Desk is not available for booking');
        }

        // Check if user exists and is active
        final DocumentSnapshot<Map<String, dynamic>> userDoc = 
            await transaction.get(FirestoreRefs.userDocRef(userId));

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final Map<String, dynamic> userData = userDoc.data()!;
        if (userData['active'] != true) {
          throw Exception('User account is not active');
        }

        // Create reservation
        final Reservation reservation = Reservation(
          id: reservationId,
          userId: userId,
          deskId: deskId,
          date: date,
          status: ReservationStatus.active,
          createdAt: now,
          notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        );

        // Create desk day lock
        final DeskDayLock deskLock = DeskDayLock(
          id: lockId,
          deskId: deskId,
          date: date,
          reservationId: reservationId,
          userId: userId,
          createdAt: now,
        );

        // Write both documents
        transaction.set(
          FirestoreRefs.reservationDocRef(reservationId),
          reservation.toJson(),
        );
        
        transaction.set(
          FirestoreRefs.deskDayLockDocRef(lockId),
          deskLock.toJson(),
        );
      });

      return reservationId;
    } catch (e) {
      if (e.toString().contains('already booked') ||
          e.toString().contains('not found') ||
          e.toString().contains('not available') ||
          e.toString().contains('not active') ||
          e.toString().contains('Invalid date') ||
          e.toString().contains('Cannot create reservation')) {
        rethrow;
      }
      throw Exception('Failed to create reservation: $e');
    }
  }

  /// Cancel a reservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _firestore.runTransaction((Transaction transaction) async {
        // Get the reservation
        final DocumentSnapshot<Map<String, dynamic>> reservationDoc = 
            await transaction.get(FirestoreRefs.reservationDocRef(reservationId));

        if (!reservationDoc.exists) {
          throw Exception('Reservation not found');
        }

        final Map<String, dynamic> reservationData = reservationDoc.data()!;
        
        if (reservationData['status'] == 'cancelled') {
          throw Exception('Reservation is already cancelled');
        }

        // Check if reservation is in the past
        final String date = reservationData['date'] as String;
        final DateTime reservationDate = parseDateYmd(date);
        final DateTime today = DateTime.now();
        final DateTime todayDate = DateTime(today.year, today.month, today.day);
        
        if (reservationDate.isBefore(todayDate)) {
          throw Exception('Cannot cancel past reservations');
        }

        final String deskId = reservationData['deskId'] as String;
        final String lockId = LockIdHelpers.generateDeskDayLockId(deskId, date);
        final DateTime now = DateTime.now();

        // Update reservation status
        transaction.update(
          FirestoreRefs.reservationDocRef(reservationId),
          <String, dynamic>{
            'status': 'cancelled',
            'cancelledAt': Timestamp.fromDate(now),
          },
        );

        // Delete the desk day lock
        transaction.delete(FirestoreRefs.deskDayLockDocRef(lockId));
      });
    } catch (e) {
      if (e.toString().contains('not found') ||
          e.toString().contains('already cancelled') ||
          e.toString().contains('Cannot cancel')) {
        rethrow;
      }
      throw Exception('Failed to cancel reservation: $e');
    }
  }

  /// Get reservations for a specific desk and date range
  Future<List<Reservation>> getDeskReservations({
    required String deskId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      Query<Map<String, dynamic>> query = FirestoreRefs.reservationsRef
          .where('deskId', isEqualTo: deskId)
          .where('status', isEqualTo: 'active');

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get desk reservations: $e');
    }
  }

  /// Get upcoming reservations for a user
  Future<List<Reservation>> getUserUpcomingReservations(String userId) async {
    try {
      developer.log('📋 Getting upcoming reservations for userId: $userId', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('📋 Getting upcoming reservations for userId: $userId');
      
      final String today = getTodayYmd();
      developer.log('📅 Today date: $today', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('📅 Today date: $today');
      
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'active')
              .where('date', isGreaterThanOrEqualTo: today)
              .orderBy('date', descending: false)
              .get();

      developer.log('✅ Successfully retrieved ${snapshot.docs.length} upcoming reservations', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('✅ Successfully retrieved ${snapshot.docs.length} upcoming reservations');

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    } catch (e) {
      // Use both developer.log and print to ensure visibility
      developer.log('💥 FIRESTORE INDEX ERROR in getUserUpcomingReservations:', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('💥 FIRESTORE INDEX ERROR in getUserUpcomingReservations:');
      
      developer.log('🔗 ERROR DETAILS: ${e.toString()}', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('🔗 ERROR DETAILS: ${e.toString()}');
      
      developer.log('📋 Query details:', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('📋 Query details:');
      
      developer.log('   - Collection: reservations', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('   - Collection: reservations');
      
      developer.log('   - where("userId", "==", "$userId")', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('   - where("userId", "==", "$userId")');
      
      developer.log('   - where("status", "==", "active")', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('   - where("status", "==", "active")');
      
      developer.log('   - where("date", ">=", "${getTodayYmd()}")', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('   - where("date", ">=", "${getTodayYmd()}")');
      
      developer.log('   - orderBy("date", descending: false)', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('   - orderBy("date", descending: false)');
      
      developer.log('🔧 COPY THIS ERROR TO CREATE INDEX:', name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print('🔧 COPY THIS ERROR TO CREATE INDEX:');
      
      developer.log(e.toString(), name: 'ReservationsDataProvider.getUserUpcomingReservations');
      print(e.toString());
      
      throw Exception('Failed to get upcoming reservations: $e');
    }
  }

  /// Get reservation history for a user
  Future<List<Reservation>> getUserReservationHistory(String userId) async {
    try {
      developer.log('📋 Getting reservation history for userId: $userId', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('📋 Getting reservation history for userId: $userId');
      
      final String today = getTodayYmd();
      developer.log('📅 Today date: $today', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('📅 Today date: $today');
      
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('userId', isEqualTo: userId)
              .where('date', isLessThan: today)
              .orderBy('date', descending: true)
              .get();

      developer.log('✅ Successfully retrieved ${snapshot.docs.length} history reservations', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('✅ Successfully retrieved ${snapshot.docs.length} history reservations');

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Reservation.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              return null;
            }
          })
          .whereType<Reservation>()
          .toList();
    } catch (e) {
      // Use both developer.log and print to ensure visibility
      developer.log('💥 FIRESTORE INDEX ERROR in getUserReservationHistory:', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('💥 FIRESTORE INDEX ERROR in getUserReservationHistory:');
      
      developer.log('🔗 ERROR DETAILS: ${e.toString()}', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('🔗 ERROR DETAILS: ${e.toString()}');
      
      developer.log('📋 Query details:', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('📋 Query details:');
      
      developer.log('   - Collection: reservations', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('   - Collection: reservations');
      
      developer.log('   - where("userId", "==", "$userId")', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('   - where("userId", "==", "$userId")');
      
      developer.log('   - where("date", "<", "${getTodayYmd()}")', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('   - where("date", "<", "${getTodayYmd()}")');
      
      developer.log('   - orderBy("date", descending: true)', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('   - orderBy("date", descending: true)');
      
      developer.log('🔧 COPY THIS ERROR TO CREATE INDEX:', name: 'ReservationsDataProvider.getUserReservationHistory');
      print('🔧 COPY THIS ERROR TO CREATE INDEX:');
      
      developer.log(e.toString(), name: 'ReservationsDataProvider.getUserReservationHistory');
      print(e.toString());
      
      throw Exception('Failed to get reservation history: $e');
    }
  }

  /// Check if user has active reservation for a specific date
  Future<bool> userHasReservationForDate(String userId, String date) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.reservationsRef
              .where('userId', isEqualTo: userId)
              .where('date', isEqualTo: date)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get reservations count for a user
  Future<int> getUserReservationsCount(String userId) async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.reservationsRef
              .where('userId', isEqualTo: userId)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get active reservations count for a user
  Future<int> getUserActiveReservationsCount(String userId) async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.reservationsRef
              .where('userId', isEqualTo: userId)
              .where('status', isEqualTo: 'active')
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
