import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/notice_model.dart';
import '../services/notice_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum NoticeLoadStatus { initial, loading, loaded, error }

class NoticeState {
  final NoticeLoadStatus status;
  final List<NoticeModel> notices;
  final String? errorMessage;

  const NoticeState({
    this.status = NoticeLoadStatus.initial,
    this.notices = const [],
    this.errorMessage,
  });

  NoticeState copyWith({
    NoticeLoadStatus? status,
    List<NoticeModel>? notices,
    String? errorMessage,
  }) =>
      NoticeState(
        status: status ?? this.status,
        notices: notices ?? this.notices,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class NoticeNotifier extends StateNotifier<NoticeState> {
  final NoticeService _service;

  NoticeNotifier(this._service) : super(const NoticeState());

  Future<void> loadNotices() async {
    state = state.copyWith(status: NoticeLoadStatus.loading);
    try {
      final notices = await _service.getNotices();
      state = state.copyWith(
        status: NoticeLoadStatus.loaded,
        notices: notices,
      );
    } catch (e) {
      state = state.copyWith(
        status: NoticeLoadStatus.error,
        errorMessage: 'Failed to load notices. Please try again.',
      );
    }
  }

  Future<void> createNotice({
    required String title,
    required String body,
    String priority = 'normal',
    bool isPinned = false,
    String? imagePath,
  }) async {
    String? imageUrl;
    if (imagePath != null) {
      imageUrl = await _service.uploadImage(imagePath);
    }
    final notice = await _service.createNotice(
      title: title,
      body: body,
      priority: priority,
      isPinned: isPinned,
      imageUrl: imageUrl,
    );
    state = state.copyWith(
      notices: [notice, ...state.notices],
    );
  }

  Future<void> updateNotice(
    String noticeId, {
    String? title,
    String? body,
    String? priority,
    bool? isPinned,
    String? imagePath,
  }) async {
    String? imageUrl;
    if (imagePath != null) {
      imageUrl = await _service.uploadImage(imagePath);
    }
    final updated = await _service.updateNotice(
      noticeId,
      title: title,
      body: body,
      priority: priority,
      isPinned: isPinned,
      imageUrl: imageUrl,
    );
    state = state.copyWith(
      notices: state.notices.map((n) => n.id == noticeId ? updated : n).toList(),
    );
  }

  Future<void> deleteNotice(String noticeId) async {
    try {
      await _service.deleteNotice(noticeId);
      state = state.copyWith(
        notices: state.notices.where((n) => n.id != noticeId).toList(),
      );
    } catch (_) {
      state = state.copyWith(
        errorMessage: 'Failed to delete notice.',
      );
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final noticeServiceProvider =
    Provider<NoticeService>((ref) => NoticeService());

final noticeProvider =
    StateNotifierProvider<NoticeNotifier, NoticeState>(
  (ref) => NoticeNotifier(ref.read(noticeServiceProvider)),
);
