import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/shared.dart';

import '../../core/providers.dart';
import '../../core/router.dart';

/// Screen showing available desks for a selected date
class DeskListScreen extends ConsumerStatefulWidget {
  const DeskListScreen({
    super.key,
    required this.selectedDate,
  });

  final String selectedDate;

  @override
  ConsumerState<DeskListScreen> createState() => _DeskListScreenState();
}

class _DeskListScreenState extends ConsumerState<DeskListScreen> {
  String _searchQuery = '';

  String _formatDateForDisplay(String dateString) {
    try {
      final DateTime date = parseDateYmd(dateString);
      const List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      const List<String> weekdays = [
        'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
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

  List<Desk> _filterDesks(List<Desk> desks) {
    if (_searchQuery.isEmpty) {
      return desks;
    }

    final String query = _searchQuery.toLowerCase();
    return desks.where((Desk desk) {
      return desk.name.toLowerCase().contains(query) ||
             desk.code.toLowerCase().contains(query) ||
             (desk.notes?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _selectDesk(Desk desk) {
    context.go('${AppRoutes.reservationConfirmation}?deskId=${desk.id}&date=${widget.selectedDate}');
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Desk>> availableDesksAsync = ref.watch(availableDesksProvider(widget.selectedDate));
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Available Desks'),
            Text(
              _isToday(widget.selectedDate) 
                  ? 'Today, ${_formatDateForDisplay(widget.selectedDate)}'
                  : _formatDateForDisplay(widget.selectedDate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Column(
        children: <Widget>[
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search desks...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              onChanged: (String value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Desk list
          Expanded(
            child: availableDesksAsync.when(
              data: (List<Desk> desks) {
                final List<Desk> filteredDesks = _filterDesks(desks);
                
                if (filteredDesks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          _searchQuery.isEmpty ? Icons.event_busy : Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'No desks available for this date'
                              : 'No desks match your search',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Try selecting a different date'
                              : 'Try adjusting your search terms',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Text('Clear search'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDesks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Desk desk = filteredDesks[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectDesk(desk),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                    desk.code,
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
                                      desk.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (desk.hasNotes) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        desk.notes!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading available desks...'),
                  ],
                ),
              ),
              error: (Object error, StackTrace stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load desks',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.refresh(availableDesksProvider(widget.selectedDate)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
