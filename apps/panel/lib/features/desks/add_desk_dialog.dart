import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/validators.dart';
import 'desks_repository.dart';

/// Dialog for adding a new desk
class AddDeskDialog extends HookConsumerWidget {
  const AddDeskDialog({super.key});

  /// Show the add desk dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => const AddDeskDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController nameController = useTextEditingController();
    final TextEditingController codeController = useTextEditingController();
    final TextEditingController notesController = useTextEditingController();
    final ValueNotifier<bool> enabledNotifier = useState(true);
    final ValueNotifier<bool> isLoading = useState(false);

    final DesksRepository repository = ref.read(desksRepositoryProvider);

    Future<void> handleSubmit() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      try {
        // Check if code is available
        final bool isCodeAvailable = await repository.isDeskCodeAvailable(
          codeController.text.trim(),
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

        await repository.createDesk(
          name: nameController.text.trim(),
          code: codeController.text.trim(),
          enabled: enabledNotifier.value,
          notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        );

        if (context.mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desk created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create desk: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return AlertDialog(
      title: const Text('Add New Desk'),
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

        // Create button
        ElevatedButton(
          onPressed: isLoading.value ? null : handleSubmit,
          child: isLoading.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Desk'),
        ),
      ],
    );
  }
}
