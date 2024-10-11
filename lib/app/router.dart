import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/home/home_screen.dart';
import '../features/transactions/transaction_form_screen.dart';
import '../features/transactions/transactions_screen.dart';
import 'app_shell.dart';
import 'splash_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const home = '/';
  static const signIn = '/sign-in';
  static const transactions = '/transactions';
  static const newTransaction = '/transactions/new';
  static String editTransaction(String clientId) => '/transactions/$clientId';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever auth state changes, without rebuilding the router.
  final authChanges = ValueNotifier<AsyncValue<Object?>>(const AsyncLoading());
  ref
    ..onDispose(authChanges.dispose)
    ..listen(
      authControllerProvider,
      (_, next) => authChanges.value = next,
      fireImmediately: true,
    );

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: authChanges,
    redirect: (context, state) {
      final auth = authChanges.value;
      final location = state.matchedLocation;
      if (auth.isLoading && !auth.hasValue) return Routes.splash;

      final signedIn = auth.valueOrNull != null;
      if (!signedIn) return location == Routes.signIn ? null : Routes.signIn;
      if (location == Routes.signIn || location == Routes.splash) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.transactions,
                builder: (_, __) => const TransactionsScreen(),
                routes: [
                  // Forms open full screen, above the bottom navigation.
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, __) => const TransactionFormScreen(),
                  ),
                  GoRoute(
                    path: ':clientId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, state) => TransactionFormScreen(
                      clientId: state.pathParameters['clientId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: Routes.signIn, builder: (_, __) => const SignInScreen()),
    ],
  );
});
