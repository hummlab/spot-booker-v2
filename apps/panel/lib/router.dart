import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_gate.dart';
import 'features/auth/login_page.dart';
import 'features/desks/desks_page.dart';
import 'features/reservations/reservations_page.dart';
import 'features/users/users_page.dart';

/// Application router configuration
final GoRouter router = GoRouter(
  initialLocation: '/users',
  routes: <RouteBase>[
    // Login route (unprotected)
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    
    // Protected routes wrapped in AuthGate
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) => 
          AuthGate(child: child),
      routes: <RouteBase>[
        // Users management
        GoRoute(
          path: '/users',
          builder: (BuildContext context, GoRouterState state) => 
              const UsersPage(),
        ),
        
        // Desks management
        GoRoute(
          path: '/desks',
          builder: (BuildContext context, GoRouterState state) => 
              const DesksPage(),
        ),
        
        // Reservations management
        GoRoute(
          path: '/reservations',
          builder: (BuildContext context, GoRouterState state) => 
              const ReservationsPage(),
        ),
      ],
    ),
  ],
  
  // Global redirect logic
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = AuthGate.isLoggedIn();
    final bool loggingIn = state.uri.path == '/login';
    
    // If not logged in and not on login page, redirect to login
    if (!loggedIn && !loggingIn) {
      return '/login';
    }
    
    // If logged in and on login page, redirect to users
    if (loggedIn && loggingIn) {
      return '/users';
    }
    
    // No redirect needed
    return null;
  },
  
  // Error handling
  errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
    appBar: AppBar(
      title: const Text('Page Not Found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '404 - Page Not Found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The page "${state.uri.path}" does not exist.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/users'),
            child: const Text('Go to Users'),
          ),
        ],
      ),
    ),
  ),
  
  // Debug logging in development
  debugLogDiagnostics: true,
);
