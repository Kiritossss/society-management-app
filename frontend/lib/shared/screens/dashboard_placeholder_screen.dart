import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';

class DashboardPlaceholderScreen extends ConsumerWidget {
  const DashboardPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).token?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.apartment, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user?.fullName ?? 'Resident'}!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (user?.role ?? 'member').toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Modules',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Complaints tile — Phase 4 ✅
          _ModuleTile(
            icon: Icons.report_problem_outlined,
            label: 'Complaints',
            subtitle: 'Raise or track issues',
            color: AppColors.error,
            onTap: () => context.push('/complaints'),
          ),

          // Coming soon tiles
          _ModuleTile(
            icon: Icons.security_outlined,
            label: 'Visitor Management',
            subtitle: 'Coming in Phase 5',
            color: AppColors.info,
            onTap: null,
          ),
          _ModuleTile(
            icon: Icons.receipt_long_outlined,
            label: 'Payments & Bills',
            subtitle: 'Coming in Phase 6',
            color: AppColors.success,
            onTap: null,
          ),
          _ModuleTile(
            icon: Icons.meeting_room_outlined,
            label: 'Facility Booking',
            subtitle: 'Coming in Phase 6',
            color: AppColors.accent,
            onTap: null,
          ),
          _ModuleTile(
            icon: Icons.how_to_vote_outlined,
            label: 'Polling & Voting',
            subtitle: 'Coming in Phase 6',
            color: AppColors.primaryLight,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _ModuleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitle,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          trailing: isEnabled
              ? const Icon(Icons.chevron_right, color: AppColors.textDisabled)
              : const Icon(Icons.lock_outline,
                  color: AppColors.textDisabled, size: 16),
        ),
      ),
    );
  }
}
