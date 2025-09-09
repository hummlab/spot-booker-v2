import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/table_toolbar.dart';
import 'add_desk_dialog.dart';
import 'desks_repository.dart';
import 'edit_desk_dialog.dart';

/// Desks management page
class DesksPage extends HookConsumerWidget {
  const DesksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> searchQuery = useState('');
    final DesksRepository repository = ref.read(desksRepositoryProvider);

    // Watch desks stream with current search query
    final AsyncValue<List<Desk>> desksAsync = ref.watch(
      desksStreamProvider(searchQuery.value.isEmpty ? null : searchQuery.value),
    );

    // Watch desk counts
    final AsyncValue<int> totalCountAsync = ref.watch(desksCountProvider);
    final AsyncValue<int> enabledCountAsync = ref.watch(enabledDesksCountProvider);

    Future<void> handleAddDesk() async {
      final bool? result = await AddDeskDialog.show(context);
      if (result == true) {
        // Refresh providers
        ref.invalidate(desksStreamProvider);
        ref.invalidate(desksCountProvider);
        ref.invalidate(enabledDesksCountProvider);
      }
    }

    Future<void> handleEditDesk(Desk desk) async {
      final bool? result = await EditDeskDialog.show(context, desk);
      if (result == true) {
        // Refresh providers
        ref.invalidate(desksStreamProvider);
        ref.invalidate(desksCountProvider);
        ref.invalidate(enabledDesksCountProvider);
      }
    }

    Future<void> handleToggleDeskStatus(Desk desk) async {
      final String action = desk.enabled ? 'disable' : 'enable';
      final bool confirmed = await ConfirmDialog.showAction(
        context: context,
        action: action,
        itemName: 'desk ${desk.displayName}',
        customMessage: desk.enabled
            ? 'This will prevent users from booking ${desk.displayName}.'
            : 'This will allow users to book ${desk.displayName}.',
      );

      if (confirmed) {
        try {
          await repository.toggleDeskStatus(desk.id, !desk.enabled);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Desk ${desk.displayName} ${desk.enabled ? 'disabled' : 'enabled'} successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update desk: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }

    Future<void> handleDeleteDesk(Desk desk) async {
      final bool confirmed = await ConfirmDialog.showAction(
        context: context,
        action: 'permanently delete',
        itemName: 'desk ${desk.displayName}',
        customMessage: 'This action cannot be undone. The desk ${desk.displayName} and all associated data will be permanently removed from the system.',
        isDestructive: true,
      );

      if (confirmed) {
        try {
          await repository.deleteDesk(desk.id);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Desk ${desk.displayName} deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Refresh providers after deletion
            ref.invalidate(desksStreamProvider);
            ref.invalidate(desksCountProvider);
            ref.invalidate(enabledDesksCountProvider);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete desk: $e'),
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
            title: 'Desks',
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
              
              enabledCountAsync.when(
                data: (int count) => Chip(
                  label: Text('Enabled: $count'),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
                loading: () => const SizedBox.shrink(),
                error: (Object _, StackTrace __) => const SizedBox.shrink(),
              ),
              
              // Add desk button
              ElevatedButton.icon(
                onPressed: handleAddDesk,
                icon: const Icon(Icons.add),
                label: const Text('Add Desk'),
              ),
            ],
          ),

          // Desks table
          Expanded(
            child: AsyncValueView<List<Desk>>(
              value: desksAsync,
              emptyMessage: searchQuery.value.isEmpty
                  ? 'No desks found. Add your first desk to get started.'
                  : 'No desks match your search criteria.',
              data: (List<Desk> desks) => _DesksTable(
                desks: desks,
                onEditDesk: handleEditDesk,
                onToggleStatus: handleToggleDeskStatus,
                onDeleteDesk: handleDeleteDesk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data table for displaying desks
class _DesksTable extends StatelessWidget {
  const _DesksTable({
    required this.desks,
    required this.onEditDesk,
    required this.onToggleStatus,
    required this.onDeleteDesk,
  });

  final List<Desk> desks;
  final void Function(Desk desk) onEditDesk;
  final void Function(Desk desk) onToggleStatus;
  final void Function(Desk desk) onDeleteDesk;

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text('Name'),
            tooltip: 'Desk name and code',
          ),
          DataColumn(
            label: Text('Code'),
            tooltip: 'Unique desk identifier',
          ),
          DataColumn(
            label: Text('Status'),
            tooltip: 'Desk availability status',
          ),
          DataColumn(
            label: Text('Notes'),
            tooltip: 'Additional information',
          ),
          DataColumn(
            label: Text('Created'),
            tooltip: 'Creation date',
          ),
          DataColumn(
            label: Text('Actions'),
            tooltip: 'Available actions',
          ),
        ],
        rows: desks.map((Desk desk) {
          return DataRow(
            cells: <DataCell>[
              // Name
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      desk.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desk.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Code
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    desk.code,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),

              // Status
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      desk.enabled ? Icons.check_circle : Icons.cancel,
                      color: desk.enabled ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      desk.enabled ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        color: desk.enabled ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Notes
              DataCell(
                desk.hasNotes
                    ? Tooltip(
                        message: desk.notes!,
                        child: Text(
                          desk.notes!.length > 30
                              ? '${desk.notes!.substring(0, 30)}...'
                              : desk.notes!,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      )
                    : Text(
                        'No notes',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),

              // Created date
              DataCell(
                Text(
                  desk.createdAt != null
                      ? dateFormat.format(desk.createdAt!)
                      : 'Unknown',
                ),
              ),

              // Actions
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Edit button
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit desk',
                      onPressed: () => onEditDesk(desk),
                    ),
                    
                    // Toggle status button
                    IconButton(
                      icon: Icon(
                        desk.enabled ? Icons.visibility_off : Icons.visibility,
                        color: desk.enabled ? Colors.orange : Colors.green,
                      ),
                      tooltip: desk.enabled ? 'Disable desk' : 'Enable desk',
                      onPressed: () => onToggleStatus(desk),
                    ),
                    
                    // More actions menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'More actions',
                      onSelected: (String action) {
                        switch (action) {
                          case 'edit':
                            onEditDesk(desk);
                            break;
                          case 'toggle_status':
                            onToggleStatus(desk);
                            break;
                          case 'delete':
                            onDeleteDesk(desk);
                            break;
                          case 'view_reservations':
                            // TODO: Implement view reservations for desk
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('View reservations coming soon'),
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            dense: true,
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'toggle_status',
                          child: ListTile(
                            leading: Icon(
                              desk.enabled ? Icons.visibility_off : Icons.visibility,
                              color: desk.enabled ? Colors.orange : Colors.green,
                            ),
                            title: Text(desk.enabled ? 'Disable' : 'Enable'),
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'view_reservations',
                          child: ListTile(
                            leading: Icon(Icons.event_seat),
                            title: Text('View Reservations'),
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
                              'Delete Desk',
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
