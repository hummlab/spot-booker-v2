import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/validators.dart';
import '../desks/desks_repository.dart';
import '../users/users_repository.dart';
import 'reservations_repository.dart';

/// Dialog for adding a new reservation (admin only)
class AddReservationDialog extends HookConsumerWidget {
  const AddReservationDialog({super.key});

  /// Show the add reservation dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => const AddReservationDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController notesController = useTextEditingController();
    final ValueNotifier<String?> selectedUserId = useState(null);
    final ValueNotifier<String?> selectedDeskId = useState(null);
    final ValueNotifier<DateTime?> selectedDate = useState(null);
    final ValueNotifier<TimeOfDay?> startTime = useState(null);
    final ValueNotifier<TimeOfDay?> endTime = useState(null);
    final ValueNotifier<bool> isLoading = useState(false);

    final ReservationsRepository reservationsRepository = ref.read(reservationsRepositoryProvider);

    // Watch users and desks for dropdowns
    final AsyncValue<List<AppUser>> usersAsync = ref.watch(usersStreamProvider(null));
    final AsyncValue<List<Desk>> desksAsync = ref.watch(desksStreamProvider(null));

    Future<void> handleSubmit() async {
      if (!formKey.currentState!.validate()) return;

      if (selectedUserId.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a user'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (selectedDeskId.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a desk'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (selectedDate.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a date'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      isLoading.value = true;

      try {
        final String dateStr = '${selectedDate.value!.year}-${selectedDate.value!.month.toString().padLeft(2, '0')}-${selectedDate.value!.day.toString().padLeft(2, '0')}';

        // Check if desk is available
        final bool isDeskAvailable = await reservationsRepository.isDeskAvailable(
          selectedDeskId.value!,
          dateStr,
        );

        if (!isDeskAvailable) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('This desk is already booked for the selected date'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          isLoading.value = false;
          return;
        }

        // Check if user can reserve for this date
        final bool canUserReserve = await reservationsRepository.canUserReserve(
          selectedUserId.value!,
          dateStr,
        );

        if (!canUserReserve) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('This user already has a reservation for the selected date'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          isLoading.value = false;
          return;
        }

        // Build start and end DateTime objects if times are selected
        DateTime? startDateTime;
        DateTime? endDateTime;

        if (startTime.value != null) {
          startDateTime = DateTime(
            selectedDate.value!.year,
            selectedDate.value!.month,
            selectedDate.value!.day,
            startTime.value!.hour,
            startTime.value!.minute,
          );
        }

        if (endTime.value != null) {
          endDateTime = DateTime(
            selectedDate.value!.year,
            selectedDate.value!.month,
            selectedDate.value!.day,
            endTime.value!.hour,
            endTime.value!.minute,
          );
        }

        // Validate time range if both are provided
        if (startDateTime != null && endDateTime != null && startDateTime.isAfter(endDateTime)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Start time must be before end time'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          isLoading.value = false;
          return;
        }

        await reservationsRepository.createReservation(
          userId: selectedUserId.value!,
          deskId: selectedDeskId.value!,
          date: dateStr,
          start: startDateTime,
          end: endDateTime,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        );

        if (context.mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservation created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create reservation: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        selectedDate.value = picked;
      }
    }

    Future<void> selectStartTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: startTime.value ?? const TimeOfDay(hour: 9, minute: 0),
      );
      if (picked != null) {
        startTime.value = picked;
      }
    }

    Future<void> selectEndTime() async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: endTime.value ?? const TimeOfDay(hour: 17, minute: 0),
      );
      if (picked != null) {
        endTime.value = picked;
      }
    }

    return AlertDialog(
      title: const Text('Create New Reservation'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // User selection
                usersAsync.when(
                  data: (List<AppUser> users) {
                    final List<AppUser> activeUsers = users.where((AppUser user) => user.active).toList();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'User *',
                        prefixIcon: Icon(Icons.person),
                        helperText: 'Select the user for this reservation',
                      ),
                      value: selectedUserId.value,
                      items: activeUsers.map((AppUser user) {
                        return DropdownMenuItem<String>(
                          value: user.uid,
                          child: Text('${user.fullName} (${user.email})'),
                        );
                      }).toList(),
                      onChanged: isLoading.value 
                          ? null 
                          : (String? value) => selectedUserId.value = value,
                      validator: (String? value) {
                        if (value == null) return 'Please select a user';
                        return null;
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (Object error, StackTrace _) => Text('Error loading users: $error'),
                ),

                const SizedBox(height: 16),

                // Desk selection
                desksAsync.when(
                  data: (List<Desk> desks) {
                    final List<Desk> availableDesks = desks.where((Desk desk) => desk.enabled).toList();
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Desk *',
                        prefixIcon: Icon(Icons.desk),
                        helperText: 'Select the desk to reserve',
                      ),
                      value: selectedDeskId.value,
                      items: availableDesks.map((Desk desk) {
                        return DropdownMenuItem<String>(
                          value: desk.id,
                          child: Text(desk.displayName),
                        );
                      }).toList(),
                      onChanged: isLoading.value 
                          ? null 
                          : (String? value) => selectedDeskId.value = value,
                      validator: (String? value) {
                        if (value == null) return 'Please select a desk';
                        return null;
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (Object error, StackTrace _) => Text('Error loading desks: $error'),
                ),

                const SizedBox(height: 16),

                // Date selection
                InkWell(
                  onTap: isLoading.value ? null : selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date *',
                      prefixIcon: Icon(Icons.calendar_today),
                      helperText: 'Select the reservation date',
                    ),
                    child: Text(
                      selectedDate.value != null
                          ? '${selectedDate.value!.day}/${selectedDate.value!.month}/${selectedDate.value!.year}'
                          : 'Select date',
                      style: TextStyle(
                        color: selectedDate.value != null 
                            ? null 
                            : Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Time range section
                Text(
                  'Time Range (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                Row(
                  children: <Widget>[
                    // Start time
                    Expanded(
                      child: InkWell(
                        onTap: isLoading.value ? null : selectStartTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Time',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            startTime.value != null
                                ? startTime.value!.format(context)
                                : 'Select time',
                            style: TextStyle(
                              color: startTime.value != null 
                                  ? null 
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // End time
                    Expanded(
                      child: InkWell(
                        onTap: isLoading.value ? null : selectEndTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'End Time',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Text(
                            endTime.value != null
                                ? endTime.value!.format(context)
                                : 'Select time',
                            style: TextStyle(
                              color: endTime.value != null 
                                  ? null 
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notes field
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Additional information about the reservation',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                  enabled: !isLoading.value,
                  validator: Validators.validateNotes,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        // Cancel button
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),

        // Create button
        ElevatedButton(
          onPressed: isLoading.value ? null : handleSubmit,
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Reservation'),
        ),
      ],
    );
  }
}
