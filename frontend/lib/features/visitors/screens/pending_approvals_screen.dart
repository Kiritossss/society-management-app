import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/visitor_provider.dart';
import '../../../shared/models/visitor_model.dart';

class PendingApprovalsScreen extends ConsumerStatefulWidget {
  const PendingApprovalsScreen({super.key});

  @override
  ConsumerState<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends ConsumerState<PendingApprovalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(visitorProvider.notifier).loadPending());
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(visitorProvider).pendingVisitors;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Approvals')),
      body: pending.isEmpty
          ? const Center(
              child: Text('No pending visitors', style: TextStyle(color: AppColors.textSecondary)),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(visitorProvider.notifier).loadPending(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pending.length,
                itemBuilder: (context, index) => _PendingCard(visitor: pending[index]),
              ),
            ),
    );
  }
}

class _PendingCard extends ConsumerWidget {
  final VisitorModel visitor;
  const _PendingCard({required this.visitor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_outline, color: AppColors.warning, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visitor.visitorName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      Text(
                        '${visitor.purpose} · ${visitor.visitorCount} person${visitor.visitorCount > 1 ? 's' : ''}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (visitor.visitorPhone != null) ...[
              const SizedBox(height: 8),
              Text('Phone: ${visitor.visitorPhone}', style: const TextStyle(fontSize: 13)),
            ],
            if (visitor.vehicleNumber != null) ...[
              const SizedBox(height: 4),
              Text('Vehicle: ${visitor.vehicleNumber}', style: const TextStyle(fontSize: 13)),
            ],
            if (visitor.notes != null) ...[
              const SizedBox(height: 4),
              Text('Notes: ${visitor.notes}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ref.read(visitorProvider.notifier).denyVisitor(visitor.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Deny'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(visitorProvider.notifier).approveVisitor(visitor.id),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
