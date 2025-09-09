import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/shared.dart';

/// Repository for managing desks
class DesksRepository {
  const DesksRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Get all desks with optional search filtering
  Stream<List<Desk>> getDesks({String? searchQuery}) {
    Query<Map<String, dynamic>> query = _firestore.collection('desks');
    
    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      List<Desk> desks = snapshot.docs
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

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final String query = searchQuery.toLowerCase();
        desks = desks.where((Desk desk) {
          return desk.name.toLowerCase().contains(query) ||
              desk.code.toLowerCase().contains(query) ||
              (desk.notes?.toLowerCase().contains(query) ?? false);
        }).toList();
      }

      return desks;
    });
  }

  /// Get a single desk by ID
  Future<Desk?> getDesk(String deskId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = 
          await _firestore.collection('desks').doc(deskId).get();
      
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

  /// Get desks count for statistics
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
}

/// Provider for DesksRepository
final desksRepositoryProvider = Provider<DesksRepository>((ProviderRef<DesksRepository> ref) {
  return DesksRepository(firestore: FirebaseFirestore.instance);
});

/// Provider for desks stream with search
final desksStreamProvider = StreamProvider.family<List<Desk>, String?>((
  StreamProviderRef<List<Desk>> ref,
  String? searchQuery,
) {
  final DesksRepository repository = ref.watch(desksRepositoryProvider);
  return repository.getDesks(searchQuery: searchQuery);
});

/// Provider for desks count
final desksCountProvider = FutureProvider<int>((FutureProviderRef<int> ref) {
  final DesksRepository repository = ref.watch(desksRepositoryProvider);
  return repository.getDesksCount();
});

/// Provider for enabled desks count
final enabledDesksCountProvider = FutureProvider<int>((FutureProviderRef<int> ref) {
  final DesksRepository repository = ref.watch(desksRepositoryProvider);
  return repository.getEnabledDesksCount();
});

/// Provider for available desks for a specific date
final availableDesksProvider = FutureProvider.family<List<Desk>, String>((
  FutureProviderRef<List<Desk>> ref,
  String date,
) {
  final DesksRepository repository = ref.watch(desksRepositoryProvider);
  return repository.getAvailableDesks(date);
});
