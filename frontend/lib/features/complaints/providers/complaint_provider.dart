import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/complaint_model.dart';
import '../services/complaint_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum ComplaintLoadStatus { initial, loading, loaded, error }

class ComplaintState {
  final ComplaintLoadStatus status;
  final List<ComplaintModel> complaints;
  final String? errorMessage;
  final bool isSubmitting;

  const ComplaintState({
    this.status = ComplaintLoadStatus.initial,
    this.complaints = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  ComplaintState copyWith({
    ComplaintLoadStatus? status,
    List<ComplaintModel>? complaints,
    String? errorMessage,
    bool? isSubmitting,
  }) =>
      ComplaintState(
        status: status ?? this.status,
        complaints: complaints ?? this.complaints,
        errorMessage: errorMessage ?? this.errorMessage,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ComplaintNotifier extends StateNotifier<ComplaintState> {
  final ComplaintService _service;

  ComplaintNotifier(this._service) : super(const ComplaintState());

  Future<void> loadComplaints() async {
    state = state.copyWith(status: ComplaintLoadStatus.loading);
    try {
      final complaints = await _service.getComplaints();
      state = state.copyWith(
        status: ComplaintLoadStatus.loaded,
        complaints: complaints,
      );
    } catch (e) {
      state = state.copyWith(
        status: ComplaintLoadStatus.error,
        errorMessage: 'Failed to load complaints. Please try again.',
      );
    }
  }

  Future<bool> createComplaint({
    required String title,
    required String description,
    required String category,
    String? imageUrl,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final complaint = await _service.createComplaint(
        title: title,
        description: description,
        category: category,
        imageUrl: imageUrl,
      );
      state = state.copyWith(
        isSubmitting: false,
        complaints: [complaint, ...state.complaints],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit complaint. Please try again.',
      );
      return false;
    }
  }

  Future<void> updateStatus(String complaintId, String newStatus) async {
    try {
      final updated = await _service.updateStatus(complaintId, newStatus);
      state = state.copyWith(
        complaints: state.complaints
            .map((c) => c.id == complaintId ? updated : c)
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Failed to update status.',
      );
    }
  }

  Future<void> deleteComplaint(String complaintId) async {
    try {
      await _service.deleteComplaint(complaintId);
      state = state.copyWith(
        complaints: state.complaints.where((c) => c.id != complaintId).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Failed to delete complaint.',
      );
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final complaintServiceProvider =
    Provider<ComplaintService>((ref) => ComplaintService());

final complaintProvider =
    StateNotifierProvider<ComplaintNotifier, ComplaintState>(
  (ref) => ComplaintNotifier(ref.read(complaintServiceProvider)),
);
