import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/unit_model.dart';
import '../services/unit_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum UnitLoadStatus { initial, loading, loaded, error }

class UnitState {
  final UnitLoadStatus status;
  final List<UnitModel> units;
  final String? errorMessage;
  final bool isSubmitting;

  const UnitState({
    this.status = UnitLoadStatus.initial,
    this.units = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  UnitState copyWith({
    UnitLoadStatus? status,
    List<UnitModel>? units,
    String? errorMessage,
    bool? isSubmitting,
  }) =>
      UnitState(
        status: status ?? this.status,
        units: units ?? this.units,
        errorMessage: errorMessage ?? this.errorMessage,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class UnitNotifier extends StateNotifier<UnitState> {
  final UnitService _service;

  UnitNotifier(this._service) : super(const UnitState());

  Future<void> loadUnits() async {
    state = state.copyWith(status: UnitLoadStatus.loading);
    try {
      final units = await _service.getUnits();
      state = state.copyWith(
        status: UnitLoadStatus.loaded,
        units: units,
      );
    } catch (e) {
      state = state.copyWith(
        status: UnitLoadStatus.error,
        errorMessage: 'Failed to load units. Please try again.',
      );
    }
  }

  Future<bool> createUnit({
    required String unitNumber,
    String? blockName,
    String? floorNumber,
    String? unitType,
    double? areaSqft,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final unit = await _service.createUnit(
        unitNumber: unitNumber,
        blockName: blockName,
        floorNumber: floorNumber,
        unitType: unitType,
        areaSqft: areaSqft,
      );
      state = state.copyWith(
        isSubmitting: false,
        units: [...state.units, unit],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create unit. Please try again.',
      );
      return false;
    }
  }

  Future<bool> deleteUnit(String unitId) async {
    try {
      await _service.deleteUnit(unitId);
      state = state.copyWith(
        units: state.units.where((u) => u.id != unitId).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to delete unit. It may still be occupied.',
      );
      return false;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final unitServiceProvider =
    Provider<UnitService>((ref) => UnitService());

final unitProvider =
    StateNotifierProvider<UnitNotifier, UnitState>(
  (ref) => UnitNotifier(ref.read(unitServiceProvider)),
);
