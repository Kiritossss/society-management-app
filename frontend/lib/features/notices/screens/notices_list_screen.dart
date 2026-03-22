import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/notice_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/notice_provider.dart';

class NoticesListScreen extends ConsumerStatefulWidget {
  const NoticesListScreen({super.key});

  @override
  ConsumerState<NoticesListScreen> createState() => _NoticesListScreenState();
}

class _NoticesListScreenState extends ConsumerState<NoticesListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(noticeProvider.notifier).loadNotices());
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppColors.error;
      case 'important':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  bool get _canManage {
    final role = ref.read(authProvider).token?.user.role ?? 'member';
    return role == 'admin' || role == 'committee';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(noticeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notice Board')),
      floatingActionButton: _canManage
          ? FloatingActionButton(
              onPressed: () => context.push('/notices/new'),
              child: const Icon(Icons.add),
            )
          : null,
      body: _buildBody(state),
    );
  }

  Widget _buildBody(NoticeState state) {
    if (state.status == NoticeLoadStatus.loading ||
        state.status == NoticeLoadStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NoticeLoadStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(noticeProvider.notifier).loadNotices(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No notices yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            if (_canManage) ...[
              const SizedBox(height: 12),
              const Text(
                'Tap + to post the first notice',
                style: TextStyle(color: AppColors.textDisabled, fontSize: 13),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(noticeProvider.notifier).loadNotices(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.notices.length,
        itemBuilder: (context, index) => _buildNoticeCard(state.notices[index]),
      ),
    );
  }

  Widget _buildNoticeCard(NoticeModel notice) {
    final priorityColor = _priorityColor(notice.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notice.isPinned
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showNoticeDetail(notice),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  if (notice.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.push_pin,
                          size: 16, color: AppColors.primary),
                    ),
                  Expanded(
                    child: Text(
                      notice.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notice.priority.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Body preview
              Text(
                notice.body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              // Image thumbnail
              if (notice.imageUrl != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${ApiConstants.baseUrl}${notice.imageUrl}',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              // Date
              Text(
                _formatDate(notice.createdAt),
                style: const TextStyle(
                    color: AppColors.textDisabled, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoticeDetail(NoticeModel notice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, controller) => Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: controller,
            children: [
              Row(
                children: [
                  if (notice.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.push_pin,
                          size: 18, color: AppColors.primary),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _priorityColor(notice.priority)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      notice.priority.toUpperCase(),
                      style: TextStyle(
                        color: _priorityColor(notice.priority),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_canManage)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error, size: 22),
                      onPressed: () => _confirmDelete(notice, ctx),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notice.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                'Posted ${_formatDate(notice.createdAt)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const Divider(height: 24),
              Text(
                notice.body,
                style: const TextStyle(fontSize: 15, height: 1.6),
              ),
              if (notice.imageUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    '${ApiConstants.baseUrl}${notice.imageUrl}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(NoticeModel notice, BuildContext sheetContext) {
    showDialog(
      context: sheetContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Notice'),
        content: const Text('Are you sure you want to delete this notice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(sheetContext); // close bottom sheet
              ref.read(noticeProvider.notifier).deleteNotice(notice.id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
