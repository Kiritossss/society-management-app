import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/visitor_model.dart';
import '../services/visitor_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum VisitorLoadStatus { initial, loading, loaded, error }

class VisitorState {
  final VisitorLoadStatus status;
  final List<VisitorModel> visitors;
  final List<VisitorModel> pendingVisitors;
  final String? errorMessage;
  final bool isSubmitting;

  const VisitorState({
    this.status = VisitorLoadStatus.initial,
    this.visitors = const [],
    this.pendingVisitors = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  VisitorState copyWith({
    VisitorLoadStatus? status,
    List<VisitorModel>? visitors,
    List<VisitorModel>? pendingVisitors,
    String? errorMessage,
    bool? isSubmitting,
  }) =>
      VisitorState(
        status: status ?? this.status,
        visitors: visitors ?? this.visitors,
        pendingVisitors: pendingVisitors ?? this.pendingVisitors,
        errorMessage: errorMessage ?? this.errorMessage,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class VisitorNotifier extends StateNotifier<VisitorState> {
  final VisitorService _service;

  VisitorNotifier(this._service) : super(const VisitorState());

  Future<void> loadVisitors() async {
    state = state.copyWith(status: VisitorLoadStatus.loading);
    try {
      final visitors = await _service.getVisitors();
      state = state.copyWith(
        status: VisitorLoadStatus.loaded,
        visitors: visitors,
      );
    } catch (_) {
      state = state.copyWith(
        status: VisitorLoadStatus.error,
        errorMessage: 'Failed to load visitors.',
      );
    }
  }

  Future<void> loadPending() async {
    try {
      final pending = await _service.getPendingVisitors();
      state = state.copyWith(pendingVisitors: pending);
    } catch (_) {
      // silent
    }
  }

  Future<bool> preApprove({
    required String visitorName,
    String? visitorPhone,
    int visitorCount = 1,
    String purpose = 'guest',
    String? vehicleNumber,
    String? notes,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final visitor = await _service.preApprove(
        visitorName: visitorName,
        visitorPhone: visitorPhone,
        visitorCount: visitorCount,
        purpose: purpose,
        vehicleNumber: vehicleNumber,
        notes: notes,
      );
      state = state.copyWith(
        isSubmitting: false,
        visitors: [visitor, ...state.visitors],
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to pre-approve visitor.',
      );
      return false;
    }
  }

  Future<bool> logEntry({
    required String visitorName,
    String? visitorPhone,
    int visitorCount = 1,
    String purpose = 'guest',
    String? vehicleNumber,
    String? unitId,
    String? residentId,
    String? notes,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final visitor = await _service.logEntry(
        visitorName: visitorName,
        visitorPhone: visitorPhone,
        visitorCount: visitorCount,
        purpose: purpose,
        vehicleNumber: vehicleNumber,
        unitId: unitId,
        residentId: residentId,
        notes: notes,
      );
      state = state.copyWith(
        isSubmitting: false,
        visitors: [visitor, ...state.visitors],
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to log visitor entry.',
      );
      return false;
    }
  }

  Future<void> approveVisitor(String id) async {
    try {
      final updated = await _service.approveVisitor(id);
      _replaceVisitor(updated);
      state = state.copyWith(
        pendingVisitors: state.pendingVisitors.where((v) => v.id != id).toList(),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to approve visitor.');
    }
  }

  Future<void> denyVisitor(String id) async {
    try {
      final updated = await _service.denyVisitor(id);
      _replaceVisitor(updated);
      state = state.copyWith(
        pendingVisitors: state.pendingVisitors.where((v) => v.id != id).toList(),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to deny visitor.');
    }
  }

  Future<void> checkIn(String id) async {
    try {
      final updated = await _service.checkIn(id);
      _replaceVisitor(updated);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to check in visitor.');
    }
  }

  Future<void> checkOut(String id) async {
    try {
      final updated = await _service.checkOut(id);
      _replaceVisitor(updated);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to check out visitor.');
    }
  }

  void _replaceVisitor(VisitorModel updated) {
    state = state.copyWith(
      visitors: state.visitors.map((v) => v.id == updated.id ? updated : v).toList(),
    );
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final visitorServiceProvider = Provider<VisitorService>((ref) => VisitorService());

final visitorProvider = StateNotifierProvider<VisitorNotifier, VisitorState>(
  (ref) => VisitorNotifier(ref.read(visitorServiceProvider)),
);
