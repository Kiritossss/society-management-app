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
    _tabCtrl = TabController(length: 3, vsync: this);
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
    final checkedOut = state.visitors.where((v) => v.isCheckedOut).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Dashboard'),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: [
            Tab(text: 'Inside (${checkedIn.length})'),
            Tab(text: 'Pre-approved (${preApproved.length})'),
            Tab(text: 'Checked Out (${checkedOut.length})'),
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
                  _buildCheckedOutList(checkedOut),
                ],
              ),
            ),
    );
  }

  Widget _buildCheckedOutList(List<VisitorModel> visitors) {
    if (visitors.isEmpty) {
      return const Center(
        child: Text(
          'No checked-out visitors today',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visitors.length,
      itemBuilder: (context, index) {
        final visitor = visitors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.logout, color: AppColors.success, size: 22),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (visitor.checkedOutAt != null)
                      Text(
                        'Left ${_formatTime(visitor.checkedOutAt!)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    const SizedBox(height: 4),
                    Consumer(
                      builder: (context, ref, _) => SizedBox(
                        height: 28,
                        child: TextButton.icon(
                          onPressed: () => ref.read(visitorProvider.notifier).deleteVisitor(visitor.id),
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                          label: const Text('Delete', style: TextStyle(fontSize: 11, color: AppColors.error)),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '';
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final m = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
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
