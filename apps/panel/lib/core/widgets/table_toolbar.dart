import 'package:flutter/material.dart';

/// A toolbar widget for data tables with search, filters, and actions
class TableToolbar extends StatelessWidget {
  const TableToolbar({
    super.key,
    this.title,
    this.searchHint = 'Search...',
    this.onSearchChanged,
    this.actions = const <Widget>[],
    this.filters = const <Widget>[],
    this.showSearch = true,
  });

  /// Optional title for the toolbar
  final String? title;
  
  /// Hint text for the search field
  final String searchHint;
  
  /// Callback when search text changes
  final ValueChanged<String>? onSearchChanged;
  
  /// Action buttons to display on the right
  final List<Widget> actions;
  
  /// Filter widgets to display below the main toolbar
  final List<Widget> filters;
  
  /// Whether to show the search field
  final bool showSearch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Main toolbar row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              // Title
              if (title != null) ...<Widget>[
                Text(
                  title!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 16),
              ],
              
              // Search field
              if (showSearch) ...<Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                const SizedBox(width: 16),
              ],
              
              // Actions
              ...actions.map((Widget action) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: action,
              )),
            ],
          ),
        ),
        
        // Filters row
        if (filters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters,
            ),
          ),
        
        // Divider
        const Divider(height: 1),
      ],
    );
  }
}

/// A filter chip widget for use in TableToolbar
class FilterChip extends StatelessWidget {
  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.avatar,
  });

  /// The label text for the chip
  final String label;
  
  /// Whether this chip is selected
  final bool selected;
  
  /// Callback when the chip selection changes
  final ValueChanged<bool> onSelected;
  
  /// Optional avatar/icon for the chip
  final Widget? avatar;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      avatar: avatar,
    );
  }
}

/// A date filter widget
class DateFilter extends StatefulWidget {
  const DateFilter({
    super.key,
    required this.label,
    this.initialDate,
    this.onDateChanged,
    this.firstDate,
    this.lastDate,
  });

  /// Label for the date filter
  final String label;
  
  /// Initial date value
  final DateTime? initialDate;
  
  /// Callback when date changes
  final ValueChanged<DateTime?>? onDateChanged;
  
  /// Earliest selectable date
  final DateTime? firstDate;
  
  /// Latest selectable date
  final DateTime? lastDate;

  @override
  State<DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: widget.firstDate ?? DateTime(now.year - 1),
      lastDate: widget.lastDate ?? DateTime(now.year + 1),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateChanged?.call(picked);
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
    widget.onDateChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(
        _selectedDate != null
            ? '${widget.label}: ${_formatDate(_selectedDate!)}'
            : widget.label,
      ),
      avatar: const Icon(Icons.calendar_today, size: 18),
      onPressed: _selectDate,
      onDeleted: _selectedDate != null ? _clearDate : null,
      deleteIcon: const Icon(Icons.clear, size: 18),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
