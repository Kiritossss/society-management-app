import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/user_model.dart';
import '../services/member_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum MemberLoadStatus { initial, loading, loaded, error }

class MemberState {
  final MemberLoadStatus status;
  final List<UserModel> members;
  final String? errorMessage;
  final bool isSubmitting;

  const MemberState({
    this.status = MemberLoadStatus.initial,
    this.members = const [],
    this.errorMessage,
    this.isSubmitting = false,
  });

  MemberState copyWith({
    MemberLoadStatus? status,
    List<UserModel>? members,
    String? errorMessage,
    bool? isSubmitting,
  }) =>
      MemberState(
        status: status ?? this.status,
        members: members ?? this.members,
        errorMessage: errorMessage ?? this.errorMessage,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class MemberNotifier extends StateNotifier<MemberState> {
  final MemberService _service;

  MemberNotifier(this._service) : super(const MemberState());

  Future<void> loadMembers() async {
    state = state.copyWith(status: MemberLoadStatus.loading);
    try {
      final members = await _service.getMembers();
      state = state.copyWith(
        status: MemberLoadStatus.loaded,
        members: members,
      );
    } catch (e) {
      state = state.copyWith(
        status: MemberLoadStatus.error,
        errorMessage: 'Failed to load members. Please try again.',
      );
    }
  }

  Future<bool> addMember({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? unitId,
  }) async {
    state = state.copyWith(isSubmitting: true);
    try {
      final member = await _service.addMember(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        unitId: unitId,
      );
      state = state.copyWith(
        isSubmitting: false,
        members: [...state.members, member],
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to add member. Please try again.',
      );
      return false;
    }
  }

  Future<bool> deactivateMember(String userId) async {
    try {
      final updated = await _service.deactivateMember(userId);
      state = state.copyWith(
        members: state.members
            .map((m) => m.id == userId ? updated : m)
            .toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to deactivate member.',
      );
      return false;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final memberServiceProvider =
    Provider<MemberService>((ref) => MemberService());

final memberProvider =
    StateNotifierProvider<MemberNotifier, MemberState>(
  (ref) => MemberNotifier(ref.read(memberServiceProvider)),
);
