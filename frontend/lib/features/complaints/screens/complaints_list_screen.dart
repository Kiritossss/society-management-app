import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/complaint_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/complaint_provider.dart';

class ComplaintsListScreen extends ConsumerStatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  ConsumerState<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends ConsumerState<ComplaintsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(complaintProvider.notifier).loadComplaints());
  }

  bool _isCommittee(WidgetRef ref) {
    final role = ref.watch(authProvider).token?.user.role;
    return role == 'admin' || role == 'committee';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(complaintProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/complaints/new'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
      body: switch (state.status) {
        ComplaintLoadStatus.loading || ComplaintLoadStatus.initial => const Center(
            child: CircularProgressIndicator(),
          ),
        ComplaintLoadStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 12),
                Text(state.errorMessage ?? 'Something went wrong'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(complaintProvider.notifier).loadComplaints(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ComplaintLoadStatus.loaded => state.complaints.isEmpty
            ? _EmptyState(onTap: () => context.push('/complaints/new'))
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(complaintProvider.notifier).loadComplaints(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.complaints.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) =>
                      _ComplaintCard(
                        complaint: state.complaints[i],
                        isCommittee: _isCommittee(ref),
                      ),
                ),
              ),
      },
    );
  }
}

class _ComplaintCard extends ConsumerWidget {
  final ComplaintModel complaint;
  final bool isCommittee;
  const _ComplaintCard({required this.complaint, required this.isCommittee});

  static const _statusOptions = [
    (ComplaintStatus.open, 'Open'),
    (ComplaintStatus.inProgress, 'In Progress'),
    (ComplaintStatus.resolved, 'Resolved'),
    (ComplaintStatus.closed, 'Closed'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
                _StatusBadge(status: complaint.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              complaint.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _CategoryChip(category: complaint.category),
                const Spacer(),
                Text(
                  _formatDate(complaint.createdAt),
                  style: const TextStyle(
                      color: AppColors.textDisabled, fontSize: 11),
                ),
              ],
            ),
            if (isCommittee) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Text('Status:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 32,
                      child: DropdownButtonFormField<String>(
                        value: complaint.status,
                        isDense: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        items: _statusOptions.map((s) => DropdownMenuItem(
                          value: s.$1,
                          child: Text(s.$2),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null && value != complaint.status) {
                            ref.read(complaintProvider.notifier).updateStatus(complaint.id, value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (complaint.status == ComplaintStatus.resolved ||
                      complaint.status == ComplaintStatus.closed)
                    SizedBox(
                      height: 32,
                      child: TextButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Complaint'),
                              content: const Text('Are you sure you want to delete this complaint?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            ref.read(complaintProvider.notifier).deleteComplaint(complaint.id);
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                        label: const Text('Delete', style: TextStyle(fontSize: 12, color: AppColors.error)),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ComplaintStatus.open => (AppColors.error, 'Open'),
      ComplaintStatus.inProgress => (AppColors.warning, 'In Progress'),
      ComplaintStatus.resolved => (AppColors.success, 'Resolved'),
      ComplaintStatus.closed => (AppColors.textDisabled, 'Closed'),
      _ => (AppColors.textDisabled, status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category[0].toUpperCase() + category.substring(1),
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 11),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined,
              size: 64, color: AppColors.textDisabled),
          const SizedBox(height: 16),
          const Text('No complaints yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Tap the button below to raise one.',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add),
            label: const Text('Raise a Complaint'),
          ),
        ],
      ),
    );
  }
}
