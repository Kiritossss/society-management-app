import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/complaint_comment_model.dart';
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

// ── Comment State & Notifier ─────────────────────────────────────────────────

class CommentState {
  final List<ComplaintCommentModel> comments;
  final bool isLoading;
  final String? errorMessage;

  const CommentState({
    this.comments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CommentState copyWith({
    List<ComplaintCommentModel>? comments,
    bool? isLoading,
    String? errorMessage,
  }) =>
      CommentState(
        comments: comments ?? this.comments,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class CommentNotifier extends StateNotifier<CommentState> {
  final ComplaintService _service;
  final String complaintId;

  CommentNotifier(this._service, this.complaintId) : super(const CommentState());

  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true);
    try {
      final comments = await _service.getComments(complaintId);
      state = state.copyWith(isLoading: false, comments: comments);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load comments.',
      );
    }
  }

  Future<bool> addComment(String body) async {
    try {
      final comment = await _service.addComment(complaintId, body);
      state = state.copyWith(comments: [...state.comments, comment]);
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to add comment.');
      return false;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _service.deleteComment(complaintId, commentId);
      state = state.copyWith(
        comments: state.comments.where((c) => c.id != commentId).toList(),
      );
    } catch (_) {
      state = state.copyWith(errorMessage: 'Failed to delete comment.');
    }
  }
}

final commentProvider =
    StateNotifierProvider.family<CommentNotifier, CommentState, String>(
  (ref, complaintId) =>
      CommentNotifier(ref.read(complaintServiceProvider), complaintId),
);
