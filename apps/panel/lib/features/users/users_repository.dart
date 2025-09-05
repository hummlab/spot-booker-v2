import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';

/// Repository for managing users
class UsersRepository {
  const UsersRepository({
    required UsersDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final UsersDataProvider _dataProvider;

  /// Get all users with optional search filtering
  Stream<List<AppUser>> getUsers({String? searchQuery}) {
    final Stream<List<AppUser>> usersStream = _dataProvider.getUsersStream();
    
    if (searchQuery == null || searchQuery.isEmpty) {
      return usersStream;
    }
    
    // Apply search filter
    return usersStream.map((List<AppUser> users) {
      final String query = searchQuery.toLowerCase();
      return users.where((AppUser user) {
        return user.email.toLowerCase().contains(query) ||
            user.firstName.toLowerCase().contains(query) ||
            user.lastName.toLowerCase().contains(query) ||
            user.fullName.toLowerCase().contains(query);
      }).toList();
    });
  }

  /// Get a single user by ID
  Future<AppUser?> getUser(String userId) async {
    return _dataProvider.getUser(userId);
  }

  /// Create a new user directly in Firestore
  /// Note: This only creates the Firestore document, not the Firebase Auth account
  Future<void> createUser({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    required bool active,
  }) async {
    return _dataProvider.createUser(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      active: active,
    );
  }

  /// Update an existing user
  Future<void> updateUser(AppUser user) async {
    return _dataProvider.updateUser(user);
  }

  /// Toggle user active status
  Future<void> toggleUserStatus(String userId, bool active) async {
    return _dataProvider.toggleUserStatus(userId, active);
  }

  /// Delete a user (soft delete by setting active to false)
  Future<void> deleteUser(String userId) async {
    return _dataProvider.deleteUser(userId);
  }

  /// Get users count for pagination/statistics
  Future<int> getUsersCount() async {
    return _dataProvider.getUsersCount();
  }

  /// Get active users count
  Future<int> getActiveUsersCount() async {
    return _dataProvider.getActiveUsersCount();
  }

  /// Check if user exists by email
  Future<bool> userExistsByEmail(String email) async {
    return _dataProvider.userExistsByEmail(email);
  }
}

/// Provider for UsersDataProvider
final usersDataProviderProvider = Provider<UsersDataProvider>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return UsersDataProvider(firestore: firestore);
});

/// Provider for UsersRepository
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final dataProvider = ref.watch(usersDataProviderProvider);
  return UsersRepository(dataProvider: dataProvider);
});

/// Provider for users stream with search
final usersStreamProvider = StreamProvider.family<List<AppUser>, String?>((
  StreamProviderRef<List<AppUser>> ref,
  String? searchQuery,
) {
  final UsersRepository repository = ref.watch(usersRepositoryProvider);
  return repository.getUsers(searchQuery: searchQuery);
});

/// Provider for users count
final usersCountProvider = FutureProvider<int>((FutureProviderRef<int> ref) {
  final UsersRepository repository = ref.watch(usersRepositoryProvider);
  return repository.getUsersCount();
});

/// Provider for active users count
final activeUsersCountProvider = FutureProvider<int>((FutureProviderRef<int> ref) {
  final UsersRepository repository = ref.watch(usersRepositoryProvider);
  return repository.getActiveUsersCount();
});
