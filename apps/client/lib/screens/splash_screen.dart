import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../core/providers.dart';
import '../core/router.dart';

/// Splash screen that determines where to navigate based on auth state
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait a bit for the splash screen to be visible
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    developer.log('🔍 Checking auth state in splash screen', name: 'SplashScreen');

    final authState = ref.read(authStateProvider);
    
    authState.when(
      data: (user) async {
        if (user != null) {
          developer.log('👤 User is authenticated, checking system status', name: 'SplashScreen');
          
          try {
            // Check if user is approved and active in the system
            final authService = ref.read(authServiceProvider);
            final bool isApproved = await authService.isUserApprovedAndActive();
            
            developer.log('✅ User approval status: $isApproved', name: 'SplashScreen');
            
            if (mounted) {
              if (isApproved) {
                developer.log('🏠 Navigating to home - user is approved', name: 'SplashScreen');
                context.go(AppRoutes.home);
              } else {
                developer.log('⏳ Navigating to pending approval - user not approved yet', name: 'SplashScreen');
                context.go(AppRoutes.pendingApproval);
              }
            }
          } catch (e) {
            developer.log('💥 Error checking user status: ${e.toString()}', name: 'SplashScreen');
            if (mounted) {
              context.go(AppRoutes.pendingApproval);
            }
          }
        } else {
          developer.log('🚪 No authenticated user, navigating to login', name: 'SplashScreen');
          context.go(AppRoutes.login);
        }
      },
      loading: () {
        developer.log('⏳ Auth state still loading, retrying...', name: 'SplashScreen');
        // Wait for auth state to load
        Future<void>.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _checkAuthState();
          }
        });
      },
      error: (error, stackTrace) {
        developer.log('💥 Auth state error: ${error.toString()}', name: 'SplashScreen');
        context.go(AppRoutes.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.chair_outlined,
              size: 80,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'Spot Booker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book your perfect workspace',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
