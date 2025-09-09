import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';
import '../../core/widgets/async_value_view.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/table_toolbar.dart';
import '../desks/desks_repository.dart';
import '../users/users_repository.dart';
import 'add_reservation_dialog.dart';
import 'reservations_repository.dart';

/// Reservations management page
class ReservationsPage extends HookConsumerWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ValueNotifier<String> searchQuery = useState('');
    final ValueNotifier<ReservationStatus?> statusFilter = useState(null);
    final ValueNotifier<DateTime?> dateFilter = useState(null);
    final ReservationsRepository repository = ref.read(reservationsRepositoryProvider);

    // Build filters
    ReservationFilters? filters;
    if (searchQuery.value.isNotEmpty || statusFilter.value != null || dateFilter.value != null) {
      final String? dateStr = dateFilter.value != null
          ? '${dateFilter.value!.year}-${dateFilter.value!.month.toString().padLeft(2, '0')}-${dateFilter.value!.day.toString().padLeft(2, '0')}'
          : null;
      
      filters = ReservationFilters(
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
        status: statusFilter.value,
        date: dateStr,
      );
    }

    // Watch reservations stream with current filters
    final AsyncValue<List<Reservation>> reservationsAsync = ref.watch(
      reservationsStreamProvider(filters),
    );

    // Watch reservation counts
    final AsyncValue<int> totalCountAsync = ref.watch(reservationsCountProvider);
    final AsyncValue<int> activeCountAsync = ref.watch(activeReservationsCountProvider);

    Future<void> handleAddReservation() async {
      final bool? result = await AddReservationDialog.show(context);
      if (result == true) {
        // Refresh providers
        ref.invalidate(reservationsStreamProvider);
        ref.invalidate(reservationsCountProvider);
        ref.invalidate(activeReservationsCountProvider);
      }
    }

    Future<void> handleCancelReservation(Reservation reservation) async {
      if (reservation.status == ReservationStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This reservation is already cancelled'),
          ),
        );
        return;
      }

      final bool confirmed = await ConfirmDialog.showAction(
        context: context,
        action: 'cancel',
        itemName: 'reservation ${reservation.id}',
        customMessage: 'This will cancel the reservation and free up the desk for other users.',
      );

      if (confirmed) {
        try {
          await repository.cancelReservation(reservation.id);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reservation cancelled successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to cancel reservation: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }

    Future<void> handleDeleteReservation(Reservation reservation) async {
      final bool confirmed = await ConfirmDialog.showAction(
        context: context,
        action: 'permanently delete',
        itemName: 'reservation ${reservation.id}',
        customMessage: 'This action cannot be undone. The reservation will be permanently removed from the system.',
        isDestructive: true,
      );

      if (confirmed) {
        try {
          await repository.deleteReservation(reservation.id);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reservation deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Refresh providers after deletion
            ref.invalidate(reservationsStreamProvider);
            ref.invalidate(reservationsCountProvider);
            ref.invalidate(activeReservationsCountProvider);
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete reservation: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    }

    Future<void> selectDateFilter() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateFilter.value ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        dateFilter.value = picked;
      }
    }

    void clearDateFilter() {
      dateFilter.value = null;
    }

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Toolbar with search and actions
          TableToolbar(
            title: 'Reservations',
            onSearchChanged: (String value) => searchQuery.value = value,
            actions: <Widget>[
              // Date filter
              if (dateFilter.value != null) ...<Widget>[
                Chip(
                  label: Text('Date: ${DateFormat('MMM dd, yyyy').format(dateFilter.value!)}'),
                  onDeleted: clearDateFilter,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                const SizedBox(width: 8),
              ],
              
              // Status filter
              DropdownButton<ReservationStatus?>(
                value: statusFilter.value,
                hint: const Text('All Status'),
                items: <DropdownMenuItem<ReservationStatus?>>[
                  const DropdownMenuItem<ReservationStatus?>(
                    value: null,
                    child: Text('All Status'),
                  ),
                  ...ReservationStatus.values.map((ReservationStatus status) {
                    return DropdownMenuItem<ReservationStatus?>(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    );
                  }),
                ],
                onChanged: (ReservationStatus? value) => statusFilter.value = value,
              ),
              
              const SizedBox(width: 8),
              
              // Date filter button
              IconButton(
                onPressed: selectDateFilter,
                icon: const Icon(Icons.date_range),
                tooltip: 'Filter by date',
              ),
              
              const SizedBox(width: 8),

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
              
              // Add reservation button
              ElevatedButton.icon(
                onPressed: handleAddReservation,
                icon: const Icon(Icons.add),
                label: const Text('Add Reservation'),
              ),
            ],
          ),

          // Reservations table
          Expanded(
            child: AsyncValueView<List<Reservation>>(
              value: reservationsAsync,
              emptyMessage: searchQuery.value.isEmpty && statusFilter.value == null && dateFilter.value == null
                  ? 'No reservations found. Create your first reservation to get started.'
                  : 'No reservations match your search criteria.',
              data: (List<Reservation> reservations) => _ReservationsTable(
                reservations: reservations,
                onCancelReservation: handleCancelReservation,
                onDeleteReservation: handleDeleteReservation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data table for displaying reservations
class _ReservationsTable extends ConsumerWidget {
  const _ReservationsTable({
    required this.reservations,
    required this.onCancelReservation,
    required this.onDeleteReservation,
  });

  final List<Reservation> reservations;
  final void Function(Reservation reservation) onCancelReservation;
  final void Function(Reservation reservation) onDeleteReservation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    final DateFormat timeFormat = DateFormat('HH:mm');

    // Watch users and desks for display names
    final AsyncValue<List<AppUser>> usersAsync = ref.watch(usersStreamProvider(null));
    final AsyncValue<List<Desk>> desksAsync = ref.watch(desksStreamProvider(null));

    // Create maps for quick lookup
    final Map<String, AppUser> usersMap = <String, AppUser>{};
    final Map<String, Desk> desksMap = <String, Desk>{};

    usersAsync.whenData((List<AppUser> users) {
      for (final AppUser user in users) {
        usersMap[user.uid] = user;
      }
    });

    desksAsync.whenData((List<Desk> desks) {
      for (final Desk desk in desks) {
        desksMap[desk.id] = desk;
      }
    });

    return SingleChildScrollView(
      child: DataTable(
        columns: const <DataColumn>[
          DataColumn(
            label: Text('User'),
            tooltip: 'User who made the reservation',
          ),
          DataColumn(
            label: Text('Desk'),
            tooltip: 'Reserved desk',
          ),
          DataColumn(
            label: Text('Date'),
            tooltip: 'Reservation date',
          ),
          DataColumn(
            label: Text('Time'),
            tooltip: 'Reservation time range',
          ),
          DataColumn(
            label: Text('Status'),
            tooltip: 'Reservation status',
          ),
          DataColumn(
            label: Text('Created'),
            tooltip: 'When the reservation was created',
          ),
          DataColumn(
            label: Text('Actions'),
            tooltip: 'Available actions',
          ),
        ],
        rows: reservations.map((Reservation reservation) {
          final AppUser? user = usersMap[reservation.userId];
          final Desk? desk = desksMap[reservation.deskId];

          return DataRow(
            cells: <DataCell>[
              // User
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      user?.fullName ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (user != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Desk
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      desk?.name ?? 'Unknown Desk',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    if (desk != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          desk.code,
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Date
              DataCell(
                Text(
                  DateFormat('MMM dd, yyyy').format(
                    DateTime.parse('${reservation.date}T00:00:00Z'),
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              // Time
              DataCell(
                reservation.start != null && reservation.end != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '${timeFormat.format(reservation.start!)} - ${timeFormat.format(reservation.end!)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDuration(reservation.end!.difference(reservation.start!)),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'All day',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),

              // Status
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      reservation.status == ReservationStatus.active
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: reservation.status == ReservationStatus.active
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reservation.status.name.toUpperCase(),
                      style: TextStyle(
                        color: reservation.status == ReservationStatus.active
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Created date
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      reservation.createdAt != null
                          ? dateFormat.format(reservation.createdAt!)
                          : 'Unknown',
                    ),
                    if (reservation.createdAt != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        timeFormat.format(reservation.createdAt!),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    // Cancel button (only for active reservations)
                    if (reservation.status == ReservationStatus.active)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.orange),
                        tooltip: 'Cancel reservation',
                        onPressed: () => onCancelReservation(reservation),
                      ),
                    
                    // More actions menu
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'More actions',
                      onSelected: (String action) {
                        switch (action) {
                          case 'cancel':
                            onCancelReservation(reservation);
                            break;
                          case 'delete':
                            onDeleteReservation(reservation);
                            break;
                          case 'view_user':
                            // TODO: Implement view user details
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('View user details coming soon'),
                              ),
                            );
                            break;
                          case 'view_desk':
                            // TODO: Implement view desk details
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('View desk details coming soon'),
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        if (reservation.status == ReservationStatus.active)
                          const PopupMenuItem<String>(
                            value: 'cancel',
                            child: ListTile(
                              leading: Icon(Icons.cancel, color: Colors.orange),
                              title: Text('Cancel'),
                              dense: true,
                            ),
                          ),
                        const PopupMenuItem<String>(
                          value: 'view_user',
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text('View User'),
                            dense: true,
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'view_desk',
                          child: ListTile(
                            leading: Icon(Icons.desk),
                            title: Text('View Desk'),
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
                              'Delete',
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

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
