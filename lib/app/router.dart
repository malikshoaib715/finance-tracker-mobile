import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/home/home_screen.dart';
import 'splash_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const home = '/';
  static const signIn = '/sign-in';
}

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
      GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: Routes.signIn, builder: (_, __) => const SignInScreen()),
    ],
  );
});
