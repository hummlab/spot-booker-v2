import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/pending_approval_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/desks/desk_list_screen.dart';
import '../screens/reservations/reservation_confirmation_screen.dart';
import '../screens/reservations/my_reservations_screen.dart';
import '../screens/splash_screen.dart';
import 'providers.dart';

/// Route paths
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String pendingApproval = '/pending-approval';
  static const String home = '/home';
  static const String deskList = '/desks';
  static const String reservationConfirmation = '/reservation-confirmation';
  static const String myReservations = '/my-reservations';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ProviderRef<GoRouter> ref) {
  final AsyncValue<User?> authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = authState.valueOrNull != null;
      final bool isLoggingIn = state.matchedLocation == AppRoutes.login ||
                               state.matchedLocation == AppRoutes.register ||
                               state.matchedLocation == AppRoutes.forgotPassword ||
                               state.matchedLocation == AppRoutes.pendingApproval;

      // If not logged in and not on auth screens, redirect to login
      if (!isLoggedIn && !isLoggingIn && state.matchedLocation != AppRoutes.splash) {
        return AppRoutes.login;
      }

      // If logged in and on login/register/forgot password screens, let splash screen handle routing
      if (isLoggedIn && (state.matchedLocation == AppRoutes.login ||
                         state.matchedLocation == AppRoutes.register ||
                         state.matchedLocation == AppRoutes.forgotPassword)) {
        return AppRoutes.splash;
      }

      return null; // No redirect needed
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.pendingApproval,
        name: 'pending-approval',
        builder: (BuildContext context, GoRouterState state) {
          return const PendingApprovalScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.deskList,
        name: 'desk-list',
        builder: (BuildContext context, GoRouterState state) {
          final String? date = state.uri.queryParameters['date'];
          return DeskListScreen(selectedDate: date ?? '');
        },
      ),
      GoRoute(
        path: AppRoutes.reservationConfirmation,
        name: 'reservation-confirmation',
        builder: (BuildContext context, GoRouterState state) {
          final String? deskId = state.uri.queryParameters['deskId'];
          final String? date = state.uri.queryParameters['date'];
          
          if (deskId == null || date == null) {
            // Redirect to home if required parameters are missing
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRoutes.home);
            });
            return const SizedBox.shrink();
          }
          
          return ReservationConfirmationScreen(
            deskId: deskId,
            date: date,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.myReservations,
        name: 'my-reservations',
        builder: (BuildContext context, GoRouterState state) {
          return const MyReservationsScreen();
        },
      ),
    ],
  );
});
