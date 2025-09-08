import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../../core/providers.dart';
import '../../core/router.dart';

/// Screen shown to users who are registered but waiting for admin approval
class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  bool _isChecking = false;

  Future<void> _checkApprovalStatus() async {
    if (_isChecking) return;
    
    setState(() {
      _isChecking = true;
    });

    developer.log('🔄 Checking approval status', name: 'PendingApprovalScreen');

    try {
      final authService = ref.read(authServiceProvider);
      final bool isApproved = await authService.isUserApprovedAndActive();
      
      developer.log('✅ Approval check result: $isApproved', name: 'PendingApprovalScreen');
      
      if (mounted) {
        if (isApproved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Great! You have been added to the system. Welcome!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          context.go(AppRoutes.home);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('You have not been added to the system yet. Please contact administrator.'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('💥 Error checking approval status: ${e.toString()}', name: 'PendingApprovalScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking status: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      developer.log('🚪 Signing out user', name: 'PendingApprovalScreen');
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      
      if (mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      developer.log('💥 Error signing out: ${e.toString()}', name: 'PendingApprovalScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Icon(
                    Icons.hourglass_empty,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Not Added to System',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your account exists, but an administrator needs to add you to the system to access the application.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'What you need to do:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Contact your administrator\n'
                          '2. Ask them to add you to the system\n'
                          '3. Once added, you can access all features',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _isChecking ? null : _checkApprovalStatus,
                      icon: _isChecking
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isChecking ? 'Checking...' : 'Check Status'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'If you believe this is an error, please contact your administrator.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
