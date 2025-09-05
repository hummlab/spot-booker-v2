import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/desk.dart';
import '../utils/refs.dart';

/// Data provider for desk operations
class DesksDataProvider {
  const DesksDataProvider({
    required FirebaseFirestore firestore,
  });

  /// Get all desks stream
  Stream<List<Desk>> getDesksStream() {
    return FirestoreRefs.desksRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Desk.fromJson(doc.data());
            } catch (e) {
              // Skip invalid documents
              return null;
            }
          })
          .whereType<Desk>()
          .toList();
    });
  }

  /// Get a single desk by ID
  Future<Desk?> getDesk(String deskId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = 
          await FirestoreRefs.deskDocRef(deskId).get();
      
      if (!doc.exists) return null;
      
      return Desk.fromJson(doc.data()!);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new desk
  Future<void> createDesk({
    required String name,
    required String code,
    required bool enabled,
    String? notes,
  }) async {
    try {
      final String deskId = FirestoreRefs.desksRef.doc().id;
      final DateTime now = DateTime.now();
      
      final Desk desk = Desk(
        id: deskId,
        name: name.trim(),
        code: code.trim().toUpperCase(),
        enabled: enabled,
        notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await FirestoreRefs.deskDocRef(deskId).set(desk.toJson());
    } catch (e) {
      throw Exception('Failed to create desk: $e');
    }
  }

  /// Update an existing desk
  Future<void> updateDesk(Desk desk) async {
    try {
      final Desk updatedDesk = desk.copyWith(
        updatedAt: DateTime.now(),
      );
      
      await FirestoreRefs.deskDocRef(desk.id).update(updatedDesk.toJson());
    } catch (e) {
      throw Exception('Failed to update desk: $e');
    }
  }

  /// Update specific desk fields
  Future<void> updateDeskFields(String deskId, Map<String, dynamic> fields) async {
    try {
      final Map<String, dynamic> updateData = <String, dynamic>{
        ...fields,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };
      
      await FirestoreRefs.deskDocRef(deskId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update desk fields: $e');
    }
  }

  /// Toggle desk enabled status
  Future<void> toggleDeskStatus(String deskId, bool enabled) async {
    try {
      await FirestoreRefs.deskDocRef(deskId).update(<String, dynamic>{
        'enabled': enabled,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update desk status: $e');
    }
  }

  /// Delete a desk
  Future<void> deleteDesk(String deskId) async {
    try {
      // Check if desk has active reservations
      final QuerySnapshot<Map<String, dynamic>> activeReservations = 
          await FirestoreRefs.reservationsRef
              .where('deskId', isEqualTo: deskId)
              .where('status', isEqualTo: 'active')
              .limit(1)
              .get();

      if (activeReservations.docs.isNotEmpty) {
        throw Exception(
          'Cannot delete desk with active reservations. '
          'Please cancel all reservations first.',
        );
      }

      await FirestoreRefs.deskDocRef(deskId).delete();
    } catch (e) {
      if (e.toString().contains('active reservations')) {
        rethrow;
      }
      throw Exception('Failed to delete desk: $e');
    }
  }

  /// Check if desk code is available
  Future<bool> isDeskCodeAvailable(String code, {String? excludeDeskId}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.desksRef
              .where('code', isEqualTo: code.trim().toUpperCase())
              .limit(1)
              .get();

      if (snapshot.docs.isEmpty) return true;

      // If we're updating an existing desk, exclude it from the check
      if (excludeDeskId != null) {
        return snapshot.docs.first.id == excludeDeskId;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get desks count
  Future<int> getDesksCount() async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.desksRef.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get enabled desks count
  Future<int> getEnabledDesksCount() async {
    try {
      final AggregateQuerySnapshot snapshot = 
          await FirestoreRefs.desksRef
              .where('enabled', isEqualTo: true)
              .count()
              .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get available desks for a specific date
  Future<List<Desk>> getAvailableDesks(String date) async {
    try {
      // Get all enabled desks
      final QuerySnapshot<Map<String, dynamic>> desksSnapshot = 
          await FirestoreRefs.desksRef
              .where('enabled', isEqualTo: true)
              .get();

      final List<Desk> allDesks = desksSnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Desk.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .whereType<Desk>()
          .toList();

      // Get desk locks for the specific date
      final List<String> lockedDeskIds = <String>[];
      
      try {
        final QuerySnapshot<Map<String, dynamic>> locksSnapshot = 
            await FirestoreRefs.deskDayLocksRef
                .where('date', isEqualTo: date)
                .get();

        lockedDeskIds.addAll(
          locksSnapshot.docs
              .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => 
                  doc.data()['deskId'] as String?)
              .whereType<String>(),
        );
      } catch (e) {
        // If locks query fails, return all enabled desks
      }

      // Filter out locked desks
      return allDesks
          .where((Desk desk) => !lockedDeskIds.contains(desk.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get available desks: $e');
    }
  }

  /// Search desks by query
  Future<List<Desk>> searchDesks(String query) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = 
          await FirestoreRefs.desksRef.get();
      
      final List<Desk> allDesks = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
            try {
              return Desk.fromJson(doc.data());
            } catch (e) {
              return null;
            }
          })
          .whereType<Desk>()
          .toList();

      final String searchQuery = query.toLowerCase();
      
      return allDesks.where((Desk desk) {
        return desk.name.toLowerCase().contains(searchQuery) ||
            desk.code.toLowerCase().contains(searchQuery) ||
            (desk.notes?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search desks: $e');
    }
  }
}
