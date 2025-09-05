import 'package:flutter/material.dart';

/// A reusable confirmation dialog for destructive actions
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  /// Dialog title
  final String title;
  
  /// Dialog content/message
  final String content;
  
  /// Text for confirm button
  final String confirmText;
  
  /// Text for cancel button
  final String cancelText;
  
  /// Whether this is a destructive action (affects button styling)
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Show a confirmation dialog and return the result
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => ConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    
    return result ?? false;
  }

  /// Show a delete confirmation dialog
  static Future<bool> showDelete({
    required BuildContext context,
    required String itemName,
    String? customMessage,
  }) async {
    return show(
      context: context,
      title: 'Delete $itemName',
      content: customMessage ?? 
          'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );
  }

  /// Show a cancel confirmation dialog
  static Future<bool> showCancel({
    required BuildContext context,
    required String itemName,
    String? customMessage,
  }) async {
    return show(
      context: context,
      title: 'Cancel $itemName',
      content: customMessage ?? 
          'Are you sure you want to cancel this $itemName?',
      confirmText: 'Cancel $itemName',
      cancelText: 'Keep $itemName',
      isDestructive: true,
    );
  }

  /// Show a generic action confirmation dialog
  static Future<bool> showAction({
    required BuildContext context,
    required String action,
    required String itemName,
    String? customMessage,
    bool isDestructive = false,
  }) async {
    return show(
      context: context,
      title: '$action $itemName',
      content: customMessage ?? 
          'Are you sure you want to $action this $itemName?',
      confirmText: action,
      cancelText: 'Cancel',
      isDestructive: isDestructive,
    );
  }
}
