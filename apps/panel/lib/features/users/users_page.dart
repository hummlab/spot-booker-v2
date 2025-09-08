import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/table_toolbar.dart';
import 'add_user_dialog.dart';
import 'users_repository.dart';

/// Users management page
class UsersPage extends HookConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> searchQuery = useState('');
    final UsersRepository repository = ref.read(usersRepositoryProvider);

    // Watch users stream with current search query
    final AsyncValue<List<AppUser>> usersAsync = ref.watch(
      usersStreamProvider(searchQuery.value.isEmpty ? null : searchQuery.value),
    );

    // Watch user counts
    final AsyncValue<int> totalCountAsync = ref.watch(usersCountProvider);
    final AsyncValue<int> activeCountAsync = ref.watch(activeUsersCountProvider);

    Future<void> handleAddUser() async {
      final bool? result = await AddUserDialog.show(context);
      if (result == true) {
        // Refresh providers
        ref.invalidate(usersStreamProvider);
        ref.invalidate(usersCountProvider);
        ref.invalidate(activeUsersCountProvider);
      }
    }

    Future<void> handleToggleUserStatus(AppUser user) async {
      final String action = user.active ? 'disable' : 'enable';
      final bool confirmed = await ConfirmDialog.showAction(
        context: context,
        action: action,
        itemName: 'user ${user.fullName}',
        customMessage: user.active
            ? 'This will prevent ${user.fullName} from accessing the system.'
            : 'This will allow ${user.fullName} to access the system.',
      );

      if (confirmed) {
        try {
          await repository.toggleUserStatus(user.uid, !user.active);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'User ${user.fullName} ${user.active ? 'disabled' : 'enabled'} successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update user: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }

    Future<void> handleDeleteUser(AppUser user) async {
      final bool confirmed = await ConfirmDialog.showAction(
        context: context,
        action: 'permanently delete',
        itemName: 'user ${user.fullName}',
        customMessage: 'This action cannot be undone. The user ${user.fullName} and all associated data will be permanently removed from the system.',
        isDestructive: true,
      );

      if (confirmed) {
        try {
          await repository.permanentlyDeleteUser(user.uid);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('User ${user.fullName} deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Refresh providers after deletion
            ref.invalidate(usersStreamProvider);
            ref.invalidate(usersCountProvider);
            ref.invalidate(activeUsersCountProvider);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete user: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Toolbar with search and actions
          TableToolbar(
            title: 'Users',
            onSearchChanged: (String value) => searchQuery.value = value,
            actions: <Widget>[
              // Statistics chips
              totalCountAsync.when(
                data: (int count) => Chip(
                  label: Text('Total: $count'),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                loading: () => const SizedBox.shrink(),
                error: (Object _, StackTrace __) => const SizedBox.shrink(),
              ),
              
              activeCountAsync.when(
                data: (int count) => Chip(
                  label: Text('Active: $count'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
                loading: () => const SizedBox.shrink(),
                error: (Object _, StackTrace __) => const SizedBox.shrink(),
              ),
              
              // Add user button
              ElevatedButton.icon(
                onPressed: handleAddUser,
                icon: const Icon(Icons.person_add),
                label: const Text('Add User'),
              ),
            ],
          ),

          // Users table
          Expanded(
            child: AsyncValueView<List<AppUser>>(
              value: usersAsync,
              emptyMessage: searchQuery.value.isEmpty
                  ? 'No users found. Add your first user to get started.'
                  : 'No users match your search criteria.',
              data: (List<AppUser> users) => _UsersTable(
                users: users,
                onToggleStatus: handleToggleUserStatus,
                onDeleteUser: handleDeleteUser,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data table for displaying users
class _UsersTable extends StatelessWidget {
  const _UsersTable({
    required this.users,
    required this.onToggleStatus,
    required this.onDeleteUser,
  });

  final List<AppUser> users;
  final void Function(AppUser user) onToggleStatus;
  final void Function(AppUser user) onDeleteUser;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    final DateFormat timeFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return SingleChildScrollView(
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text('Name'),
            tooltip: 'User\'s full name',
          ),
          DataColumn(
            label: Text('Email'),
            tooltip: 'User\'s email address',
          ),
          DataColumn(
            label: Text('Status'),
            tooltip: 'Account status',
          ),
          DataColumn(
            label: Text('Created'),
            tooltip: 'Account creation date',
          ),
          DataColumn(
            label: Text('Last Login'),
            tooltip: 'Last login date and time',
          ),
          DataColumn(
            label: Text('Actions'),
            tooltip: 'Available actions',
          ),
        ],
        rows: users.map((AppUser user) {
          return DataRow(
            cells: <DataCell>[
              // Name
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      user.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (user.isNewUser) ...<Widget>[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Email
              DataCell(
                SelectableText(user.email),
              ),

              // Status
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      user.active ? Icons.check_circle : Icons.cancel,
                      color: user.active ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.active ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: user.active ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Created date
              DataCell(
                Text(
                  user.createdAt != null
                      ? dateFormat.format(user.createdAt!)
                      : 'Unknown',
                ),
              ),

              // Last login
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      user.lastLoginAt != null
                          ? timeFormat.format(user.lastLoginAt!)
                          : 'Never',
                    ),
                    if (user.lastLoginAt != null && user.hasRecentLogin) ...<Widget>[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'RECENT',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              DataCell(
                  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Toggle status button
                    IconButton(
                      icon: Icon(
                        user.active ? Icons.person_off : Icons.person,
                        color: user.active ? Colors.red : Colors.green,
                      ),
                      tooltip: user.active ? 'Disable user' : 'Enable user',
                      onPressed: () => onToggleStatus(user),
                    ),
                    
                    // Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      tooltip: 'Delete user permanently',
                      onPressed: () => onDeleteUser(user),
                    ),
                    
                    // More actions menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'More actions',
                      onSelected: (String action) {
                        switch (action) {
                          case 'toggle_status':
                            onToggleStatus(user);
                            break;
                          case 'delete':
                            onDeleteUser(user);
                            break;
                          case 'view_details':
                            // TODO: Implement user details view
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('User details view coming soon'),
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'toggle_status',
                          child: ListTile(
                            leading: Icon(
                              user.active ? Icons.person_off : Icons.person,
                              color: user.active ? Colors.red : Colors.green,
                            ),
                            title: Text(user.active ? 'Disable' : 'Enable'),
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'view_details',
                          child: ListTile(
                            leading: Icon(Icons.info_outline),
                            title: Text('View Details'),
                            dense: true,
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            title: Text(
                              'Delete User',
                              style: TextStyle(color: Colors.red),
                            ),
                            dense: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
