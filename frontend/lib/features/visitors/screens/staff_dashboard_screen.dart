import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/visitor_provider.dart';
import '../../../shared/models/visitor_model.dart';

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});

  @override
  ConsumerState<StaffDashboardScreen> createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(visitorProvider.notifier).loadVisitors();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitorProvider);
    final checkedIn = state.visitors.where((v) => v.isCheckedIn).toList();
    final preApproved = state.visitors.where((v) => v.isPreApproved).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Dashboard'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Inside (${checkedIn.length})'),
            Tab(text: 'Pre-approved (${preApproved.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/visitors/log-entry'),
        icon: const Icon(Icons.person_add),
        label: const Text('Log Entry'),
      ),
      body: state.status == VisitorLoadStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(visitorProvider.notifier).loadVisitors(),
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildList(checkedIn, isCheckedIn: true),
                  _buildList(preApproved, isCheckedIn: false),
                ],
              ),
            ),
    );
  }

  Widget _buildList(List<VisitorModel> visitors, {required bool isCheckedIn}) {
    if (visitors.isEmpty) {
      return Center(
        child: Text(
          isCheckedIn ? 'No visitors currently inside' : 'No pre-approved visitors',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) => _StaffVisitorCard(
        visitor: visitors[index],
        isCheckedIn: isCheckedIn,
      ),
    );
  }
}

class _StaffVisitorCard extends ConsumerWidget {
  final VisitorModel visitor;
  final bool isCheckedIn;

  const _StaffVisitorCard({required this.visitor, required this.isCheckedIn});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isCheckedIn ? AppColors.primary : AppColors.info)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCheckedIn ? Icons.login : Icons.schedule,
                    color: isCheckedIn ? AppColors.primary : AppColors.info,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.visitorName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '${visitor.purpose} · ${visitor.visitorCount} person${visitor.visitorCount > 1 ? 's' : ''}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (visitor.vehicleNumber != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      visitor.vehicleNumber!,
                      style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: isCheckedIn
                  ? OutlinedButton.icon(
                      onPressed: () => ref.read(visitorProvider.notifier).checkOut(visitor.id),
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Check Out'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => ref.read(visitorProvider.notifier).checkIn(visitor.id),
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Check In'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
