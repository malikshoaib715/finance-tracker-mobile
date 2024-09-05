import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/sign_in_screen.dart';
import '../features/home/home_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const signIn = '/sign-in';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(path: Routes.home, builder: (_, __) => const HomeScreen()),
      GoRoute(path: Routes.signIn, builder: (_, __) => const SignInScreen()),
    ],
  );
});
