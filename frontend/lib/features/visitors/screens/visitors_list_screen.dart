import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/visitor_provider.dart';
import '../../../shared/models/visitor_model.dart';

const _statusColors = {
  'pre_approved': AppColors.info,
  'pending': AppColors.warning,
  'approved': AppColors.success,
  'denied': AppColors.error,
  'checked_in': AppColors.primary,
  'checked_out': AppColors.textSecondary,
};

const _purposeLabels = {
  'guest': 'Guest',
  'delivery': 'Delivery',
  'cab': 'Cab',
  'service': 'Service',
  'other': 'Other',
};

class VisitorsListScreen extends ConsumerStatefulWidget {
  const VisitorsListScreen({super.key});

  @override
  ConsumerState<VisitorsListScreen> createState() => _VisitorsListScreenState();
}

class _VisitorsListScreenState extends ConsumerState<VisitorsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(visitorProvider.notifier).loadVisitors();
      ref.read(visitorProvider.notifier).loadPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitorProvider);
    final pendingCount = state.pendingVisitors.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitors'),
        actions: [
          if (pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Badge(
                label: Text('$pendingCount'),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  tooltip: 'Pending approvals',
                  onPressed: () => context.push('/visitors/pending'),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/visitors/pre-approve'),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Pre-approve'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(VisitorState state) {
    if (state.status == VisitorLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == VisitorLoadStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(visitorProvider.notifier).loadVisitors(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state.visitors.isEmpty) {
      return const Center(
        child: Text('No visitors yet', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(visitorProvider.notifier).loadVisitors();
        await ref.read(visitorProvider.notifier).loadPending();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.visitors.length,
        itemBuilder: (context, index) => _VisitorCard(visitor: state.visitors[index]),
      ),
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final VisitorModel visitor;
  const _VisitorCard({required this.visitor});

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[visitor.status] ?? AppColors.textSecondary;

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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person_outline, color: color, size: 22),
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
                  const SizedBox(height: 2),
                  Text(
                    '${_purposeLabels[visitor.purpose] ?? visitor.purpose} · ${visitor.visitorCount} person${visitor.visitorCount > 1 ? 's' : ''}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  if (visitor.vehicleNumber != null)
                    Text(
                      visitor.vehicleNumber!,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                visitor.statusLabel,
                style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
