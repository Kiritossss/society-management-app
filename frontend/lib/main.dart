import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/activate_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/complaints/screens/complaints_list_screen.dart';
import 'features/complaints/screens/create_complaint_screen.dart';
import 'features/members/screens/add_member_screen.dart';
import 'features/units/screens/create_unit_screen.dart';
import 'features/units/screens/units_list_screen.dart';
import 'features/visitors/screens/log_entry_screen.dart';
import 'features/visitors/screens/pending_approvals_screen.dart';
import 'features/visitors/screens/pre_approve_screen.dart';
import 'features/visitors/screens/staff_dashboard_screen.dart';
import 'features/notices/screens/create_notice_screen.dart';
import 'features/notices/screens/notices_list_screen.dart';
import 'features/visitors/screens/visitors_list_screen.dart';
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
            state.matchedLocation == '/activate' ||
            state.matchedLocation == '/';

        if (isInitial) return null; // still loading session
        if (!isAuth && !onAuthRoute) return '/login';
        if (isAuth && onAuthRoute) return '/dashboard';
        return null;
      },
      routes: [
        GoRoute(path: '/', redirect: (_, __) => '/login'),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/activate', builder: (_, __) => const ActivateScreen()),
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardPlaceholderScreen(),
        ),
        GoRoute(
          path: '/complaints',
          builder: (_, __) => const ComplaintsListScreen(),
        ),
        GoRoute(
          path: '/complaints/new',
          builder: (_, __) => const CreateComplaintScreen(),
        ),
        GoRoute(
          path: '/units',
          builder: (_, __) => const UnitsListScreen(),
        ),
        GoRoute(
          path: '/units/new',
          builder: (_, __) => const CreateUnitScreen(),
        ),
        GoRoute(
          path: '/members/new',
          builder: (_, __) => const AddMemberScreen(),
        ),
        // Notices
        GoRoute(
          path: '/notices',
          builder: (_, __) => const NoticesListScreen(),
        ),
        GoRoute(
          path: '/notices/new',
          builder: (_, __) => const CreateNoticeScreen(),
        ),
        // Visitor routes
        GoRoute(
          path: '/visitors',
          builder: (_, __) => const VisitorsListScreen(),
        ),
        GoRoute(
          path: '/visitors/pre-approve',
          builder: (_, __) => const PreApproveScreen(),
        ),
        GoRoute(
          path: '/visitors/pending',
          builder: (_, __) => const PendingApprovalsScreen(),
        ),
        GoRoute(
          path: '/visitors/gate',
          builder: (_, __) => const StaffDashboardScreen(),
        ),
        GoRoute(
          path: '/visitors/log-entry',
          builder: (_, __) => const LogEntryScreen(),
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
