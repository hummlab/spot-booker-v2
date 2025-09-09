import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/shared.dart';

import '../../core/validators.dart';
import 'desks_repository.dart';

/// Dialog for editing an existing desk
class EditDeskDialog extends HookConsumerWidget {
  const EditDeskDialog({
    super.key,
    required this.desk,
  });

  final Desk desk;

  /// Show the edit desk dialog
  static Future<bool?> show(BuildContext context, Desk desk) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => EditDeskDialog(desk: desk),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = useTextEditingController(text: desk.name);
    final TextEditingController codeController = useTextEditingController(text: desk.code);
    final TextEditingController notesController = useTextEditingController(text: desk.notes ?? '');
    final ValueNotifier<bool> enabledNotifier = useState(desk.enabled);
    final ValueNotifier<bool> isLoading = useState(false);

    final DesksRepository repository = ref.read(desksRepositoryProvider);

    Future<void> handleSubmit() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        // Check if code is available (excluding current desk)
        if (codeController.text.trim().toUpperCase() != desk.code) {
          final bool isCodeAvailable = await repository.isDeskCodeAvailable(
            codeController.text.trim(),
            excludeDeskId: desk.id,
          );

          if (!isCodeAvailable) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Desk code "${codeController.text.trim().toUpperCase()}" is already in use'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
            isLoading.value = false;
            return;
          }
        }

        final Desk updatedDesk = desk.copyWith(
          name: nameController.text.trim(),
          code: codeController.text.trim().toUpperCase(),
          enabled: enabledNotifier.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        );

        await repository.updateDesk(updatedDesk);

        if (context.mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desk updated successfully'),
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
      } finally {
        isLoading.value = false;
      }
    }

    return AlertDialog(
      title: Text('Edit Desk - ${desk.displayName}'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Name field
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Desk Name *',
                  hintText: 'e.g., Corner Desk, Window Desk',
                  prefixIcon: Icon(Icons.desk),
                ),
                validator: Validators.validateDeskName,
                textCapitalization: TextCapitalization.words,
                enabled: !isLoading.value,
              ),

              const SizedBox(height: 16),

              // Code field
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Desk Code *',
                  hintText: 'e.g., A1, B2, C3',
                  prefixIcon: Icon(Icons.tag),
                  helperText: 'Short unique identifier for the desk',
                ),
                validator: Validators.validateDeskCode,
                textCapitalization: TextCapitalization.characters,
                enabled: !isLoading.value,
              ),

              const SizedBox(height: 16),

              // Notes field
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional information about the desk',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                enabled: !isLoading.value,
                validator: Validators.validateNotes,
              ),

              const SizedBox(height: 16),

              // Enabled switch
              SwitchListTile(
                title: const Text('Enable Desk'),
                subtitle: const Text('Allow users to book this desk'),
                value: enabledNotifier.value,
                onChanged: isLoading.value 
                    ? null 
                    : (bool value) => enabledNotifier.value = value,
                secondary: Icon(
                  enabledNotifier.value ? Icons.check_circle : Icons.cancel,
                  color: enabledNotifier.value ? Colors.green : Colors.red,
                ),
              ),

              // Show creation/update info
              if (desk.createdAt != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Created: ${_formatDate(desk.createdAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (desk.updatedAt != null && desk.updatedAt != desk.createdAt) ...<Widget>[
                Text(
                  'Last updated: ${_formatDate(desk.updatedAt!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        // Cancel button
        TextButton(
          onPressed: isLoading.value ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),

        // Update button
        ElevatedButton(
          onPressed: isLoading.value ? null : handleSubmit,
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Desk'),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
