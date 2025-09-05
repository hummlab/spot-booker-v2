import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Authentication gate that checks if user is logged in
/// No allowlist check - any authenticated user can access the panel
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.child});
  
  final Widget child;

  /// Check if user is currently logged in
  static bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is not authenticated, redirect to login
        if (snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is authenticated, show the protected content
        return _AuthenticatedLayout(child: child);
      },
    );
  }
}

/// Layout wrapper for authenticated users with navigation
class _AuthenticatedLayout extends StatelessWidget {
  const _AuthenticatedLayout({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spot Booker Admin'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: <Widget>[
          // User info
          if (user != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  user.email ?? 'Unknown User',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ],
        ],
      ),
      
      // Navigation drawer
      drawer: const _NavigationDrawer(),
      
      // Main content
      body: child,
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Navigation drawer for switching between different sections
class _NavigationDrawer extends StatelessWidget {
  const _NavigationDrawer();

  @override
  Widget build(BuildContext context) {
    final String currentLocation = GoRouterState.of(context).uri.path;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Users section
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Users'),
            selected: currentLocation == '/users',
            onTap: () {
              Navigator.of(context).pop();
              context.go('/users');
            },
          ),
          
          // Desks section
          ListTile(
            leading: const Icon(Icons.desk),
            title: const Text('Desks'),
            selected: currentLocation == '/desks',
            onTap: () {
              Navigator.of(context).pop();
              context.go('/desks');
            },
          ),
          
          // Reservations section
          ListTile(
            leading: const Icon(Icons.event_seat),
            title: const Text('Reservations'),
            selected: currentLocation == '/reservations',
            onTap: () {
              Navigator.of(context).pop();
              context.go('/reservations');
            },
          ),
          
          const Divider(),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              Navigator.of(context).pop();
              try {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
