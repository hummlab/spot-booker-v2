import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/validators.dart';

/// Login page for admin panel authentication
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> formKey = useMemoized(() => GlobalKey<FormState>());
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
    final ValueNotifier<bool> isLoading = useState(false);
    final ValueNotifier<bool> obscurePassword = useState(true);
    final ValueNotifier<String?> errorMessage = useState(null);

    // Clear error message when user types
    useEffect(() {
      void clearError() {
        if (errorMessage.value != null) {
          errorMessage.value = null;
        }
      }
      
      emailController.addListener(clearError);
      passwordController.addListener(clearError);
      
      return () {
        emailController.removeListener(clearError);
        passwordController.removeListener(clearError);
      };
    }, <Object?>[emailController, passwordController]);

    Future<void> handleLogin() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;
      errorMessage.value = null;

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (context.mounted) {
          context.go('/users');
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Login failed';
        
        switch (e.code) {
          case 'user-not-found':
            message = 'No user found with this email address';
            break;
          case 'wrong-password':
            message = 'Incorrect password';
            break;
          case 'invalid-email':
            message = 'Invalid email address';
            break;
          case 'user-disabled':
            message = 'This account has been disabled';
            break;
          case 'too-many-requests':
            message = 'Too many failed attempts. Please try again later';
            break;
          case 'invalid-credential':
            message = 'Invalid email or password';
            break;
          default:
            message = e.message ?? 'Login failed';
        }
        
        errorMessage.value = message;
      } catch (e) {
        errorMessage.value = 'An unexpected error occurred: $e';
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo/Title
                Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                
                Text(
                  'Spot Booker Admin',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Sign in to access the admin panel',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),

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
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.validateEmail,
                  enabled: !isLoading.value,
                ),
                
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        obscurePassword.value = !obscurePassword.value;
                      },
                    ),
                  ),
                  obscureText: obscurePassword.value,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validatePassword,
                  enabled: !isLoading.value,
                  onFieldSubmitted: (_) => handleLogin(),
                ),
                
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: isLoading.value ? null : handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
                
                const SizedBox(height: 24),

                // Help text
                Text(
                  'Contact your administrator if you need access to this panel.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
