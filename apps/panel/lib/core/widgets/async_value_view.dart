import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// A widget that handles AsyncValue states with loading, error, and data views
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.emptyMessage,
  });

  /// The AsyncValue to display
  final AsyncValue<T> value;
  
  /// Widget to display when data is available
  final Widget Function(T data) data;
  
  /// Optional custom loading widget
  final Widget? loading;
  
  /// Optional custom error widget
  final Widget Function(Object error, StackTrace stackTrace)? error;
  
  /// Message to show when data is empty (for lists)
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (T data) {
        // Handle empty data for lists
        if (data is List && (data as List<dynamic>).isEmpty && emptyMessage != null) {
          return _EmptyView(message: emptyMessage!);
        }
        return this.data(data);
      },
      loading: () => loading ?? const _LoadingView(),
      error: (Object error, StackTrace stackTrace) {
        if (this.error != null) {
          return this.error!(error, stackTrace);
        }
        return _ErrorView(error: error, stackTrace: stackTrace);
      },
    );
  }
}

/// Default loading view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Default error view
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // You might want to add a refresh callback here
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Default empty view
class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No data found',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension to make AsyncValue easier to use with widgets
extension AsyncValueX on AsyncValue<dynamic> {
  /// Returns true if this AsyncValue has data and is not loading
  bool get hasData => when(
    data: (dynamic _) => true,
    loading: () => false,
    error: (Object _, StackTrace __) => false,
  );

  /// Returns true if this AsyncValue is in error state
  bool get hasError => when(
    data: (dynamic _) => false,
    loading: () => false,
    error: (Object _, StackTrace __) => true,
  );

  /// Returns true if this AsyncValue is loading
  bool get isLoading => when(
    data: (dynamic _) => false,
    loading: () => true,
    error: (Object _, StackTrace __) => false,
  );
}
