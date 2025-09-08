import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared/shared.dart';
import 'dart:developer' as developer;

import '../../core/providers.dart';
import '../../core/router.dart';

/// Screen for confirming a desk reservation
class ReservationConfirmationScreen extends ConsumerStatefulWidget {
  const ReservationConfirmationScreen({
    super.key,
    required this.deskId,
    required this.date,
  });

  final String deskId;
  final String date;

  @override
  ConsumerState<ReservationConfirmationScreen> createState() => _ReservationConfirmationScreenState();
}

class _ReservationConfirmationScreenState extends ConsumerState<ReservationConfirmationScreen> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  Desk? _desk;

  @override
  void initState() {
    super.initState();
    _loadDesk();
  }

  Future<void> _loadDesk() async {
    try {
      final desksProvider = ref.read(desksDataProvider);
      final desk = await desksProvider.getDesk(widget.deskId);
      if (mounted) {
        setState(() {
          _desk = desk;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load desk: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        context.go(AppRoutes.home);
      }
    }
  }

  String _formatDateForDisplay(String dateString) {
    try {
      final DateTime date = parseDateYmd(dateString);
      const List<String> months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      const List<String> weekdays = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
      ];

      final String weekday = weekdays[date.weekday - 1];
      final String month = months[date.month - 1];
      
      return '$weekday, $month ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  bool _isToday(String dateString) {
    try {
      final DateTime date = parseDateYmd(dateString);
      final DateTime now = DateTime.now();
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } catch (e) {
      return false;
    }
  }

  Future<void> _confirmReservation() async {
    if (_desk == null) return;

    developer.log('🎯 Starting reservation confirmation', name: 'ReservationConfirmationScreen');

    final AsyncValue<AppUser?> currentUserAsync = ref.read(currentUserProvider);
    developer.log('📋 CurrentUser async state: ${currentUserAsync.toString()}', name: 'ReservationConfirmationScreen');
    
    final AppUser? currentUser = currentUserAsync.valueOrNull;
    developer.log('👤 Current user: ${currentUser != null ? '${currentUser.email} (${currentUser.uid})' : 'null'}', name: 'ReservationConfirmationScreen');
    
    if (currentUser == null) {
      developer.log('❌ Current user is null, showing error message', name: 'ReservationConfirmationScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User not found. Please sign in again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    _formKey.currentState?.save();
    final Map<String, dynamic>? formData = _formKey.currentState?.value;
    final String? notes = formData?['notes'] as String?;

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('📝 Creating reservation with userId: ${currentUser.uid}, deskId: ${widget.deskId}, date: ${widget.date}', name: 'ReservationConfirmationScreen');
      final reservationsProvider = ref.read(reservationsDataProvider);
      await reservationsProvider.createReservation(
        userId: currentUser.uid,
        deskId: widget.deskId,
        date: widget.date,
        notes: notes,
      );
      developer.log('✅ Reservation created successfully', name: 'ReservationConfirmationScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reservation confirmed successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            action: SnackBarAction(
              label: 'View',
              onPressed: () => context.go(AppRoutes.myReservations),
            ),
          ),
        );
        context.go(AppRoutes.home);
      }
    } catch (e) {
      developer.log('💥 Error creating reservation: ${e.toString()}', name: 'ReservationConfirmationScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AsyncValue<AppUser?> currentUserAsync = ref.watch(currentUserProvider);

    if (_desk == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Confirm Reservation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.home),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Reservation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('${AppRoutes.deskList}?date=${widget.date}'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Reservation summary card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.event_seat,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Reservation Summary',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Desk info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  _desk!.code,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _desk!.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_desk!.hasNotes) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _desk!.notes!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Date info
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today,
                            color: colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Date:',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isToday(widget.date) 
                                ? 'Today, ${_formatDateForDisplay(widget.date)}'
                                : _formatDateForDisplay(widget.date),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // User info
                      currentUserAsync.when(
                        data: (AppUser? user) {
                          if (user == null) return const SizedBox.shrink();
                          
                          return Row(
                            children: <Widget>[
                              Icon(
                                Icons.person,
                                color: colorScheme.tertiary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Reserved by:',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.fullName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Notes form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Additional Notes (Optional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FormBuilderTextField(
                          name: 'notes',
                          decoration: const InputDecoration(
                            hintText: 'Any special requirements or notes...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          maxLength: 200,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.go('${AppRoutes.deskList}?date=${widget.date}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Back to Desks'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _confirmReservation,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm Reservation'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
