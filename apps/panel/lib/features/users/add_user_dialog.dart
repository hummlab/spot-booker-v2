import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/validators.dart';
import 'users_repository.dart';

/// Dialog for adding a new user
class AddUserDialog extends HookConsumerWidget {
  const AddUserDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = useMemoized(() => GlobalKey<FormState>());
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController firstNameController = useTextEditingController();
    final TextEditingController lastNameController = useTextEditingController();
    final ValueNotifier<bool> activeController = useState(true);
    final ValueNotifier<bool> isLoading = useState(false);
    final ValueNotifier<String?> errorMessage = useState(null);

    final UsersRepository repository = ref.read(usersRepositoryProvider);

    // Clear error message when user types
    useEffect(() {
      void clearError() {
        if (errorMessage.value != null) {
          errorMessage.value = null;
        }
      }
      
      emailController.addListener(clearError);
      firstNameController.addListener(clearError);
      lastNameController.addListener(clearError);
      
      return () {
        emailController.removeListener(clearError);
        firstNameController.removeListener(clearError);
        lastNameController.removeListener(clearError);
      };
    }, <Object?>[emailController, firstNameController, lastNameController]);

    Future<void> handleSubmit() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      errorMessage.value = null;

      try {
        final String email = emailController.text.trim();
        
        // Check if user already exists
        final bool userExists = await repository.userExistsByEmail(email);
        if (userExists) {
          errorMessage.value = 'User with this email already exists';
          return;
        }
        
        // Generate a simple UID for the user (in production, you might want a better approach)
        final String uid = 'user_${DateTime.now().millisecondsSinceEpoch}';
        
        await repository.createUser(
          uid: uid,
          email: email,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          active: activeController.value,
        );

        if (context.mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        errorMessage.value = e.toString();
      } finally {
        isLoading.value = false;
      }
    }

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Header
              Row(
                children: <Widget>[
                  const Icon(Icons.person_add, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Add New User',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: isLoading.value 
                        ? null 
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              // Error message
              if (errorMessage.value != null) ...<Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage.value!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'user@example.com',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.validateEmail,
                enabled: !isLoading.value,
              ),
              
              const SizedBox(height: 16),

              // First name and last name row
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (String? value) => 
                          Validators.validateName(value, fieldName: 'First name'),
                      enabled: !isLoading.value,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      validator: (String? value) => 
                          Validators.validateName(value, fieldName: 'Last name'),
                      enabled: !isLoading.value,
                      onFieldSubmitted: (_) => handleSubmit(),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Active status switch
              SwitchListTile(
                title: const Text('Active'),
                subtitle: Text(
                  activeController.value 
                      ? 'User can access the system'
                      : 'User account is disabled',
                ),
                value: activeController.value,
                onChanged: isLoading.value 
                    ? null 
                    : (bool value) => activeController.value = value,
              ),
              
              const SizedBox(height: 24),

              // Help text
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'User will be created in the system. They will need to be set up with authentication separately.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: isLoading.value 
                        ? null 
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading.value ? null : handleSubmit,
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create User'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the add user dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const AddUserDialog(),
    );
  }
}
