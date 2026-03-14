import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'shared/screens/dashboard_placeholder_screen.dart';

void main() {
  runApp(const ProviderScope(child: SocietyApp()));
}

class SocietyApp extends ConsumerWidget {
  const SocietyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isAuth = authState.status == AuthStatus.authenticated;
        final isInitial = authState.status == AuthStatus.initial;
        final onAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/';

        if (isInitial) return null; // still loading session
        if (!isAuth && !onAuthRoute) return '/login';
        if (isAuth && onAuthRoute) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/login'),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardPlaceholderScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
