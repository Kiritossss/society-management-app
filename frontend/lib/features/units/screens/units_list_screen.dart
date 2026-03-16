import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/unit_provider.dart';

class UnitsListScreen extends ConsumerStatefulWidget {
  const UnitsListScreen({super.key});

  @override
  ConsumerState<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends ConsumerState<UnitsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(unitProvider.notifier).loadUnits());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Units'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/units/new'),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(UnitState state) {
    if (state.status == UnitLoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == UnitLoadStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'Something went wrong'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.read(unitProvider.notifier).loadUnits(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.units.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_outlined, size: 64, color: AppColors.textDisabled),
            SizedBox(height: 12),
            Text('No units configured yet'),
            Text(
              'Tap + to add units to your society layout',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(unitProvider.notifier).loadUnits(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: state.units.length,
        itemBuilder: (context, index) {
          final unit = state.units[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: unit.isOccupied
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.textDisabled.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  unit.isOccupied ? Icons.home : Icons.home_outlined,
                  color: unit.isOccupied ? AppColors.success : AppColors.textDisabled,
                  size: 22,
                ),
              ),
              title: Text(
                unit.displayLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                [
                  if (unit.unitType != null) unit.unitType!,
                  unit.isOccupied ? 'Occupied' : 'Vacant',
                ].join(' · '),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: unit.isOccupied
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: AppColors.error,
                      onPressed: () => _confirmDelete(unit.id),
                    ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(String unitId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Unit'),
        content: const Text('Are you sure you want to delete this unit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(unitProvider.notifier).deleteUnit(unitId);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
