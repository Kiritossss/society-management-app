import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/auth_token_model.dart';
import '../services/auth_service.dart';

// ── Auth state ────────────────────────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final AuthTokenModel? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthTokenModel? token,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        token: token ?? this.token,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;

  AuthNotifier(this._service) : super(const AuthState()) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    final loggedIn = await _service.isLoggedIn();
    state = state.copyWith(
      status: loggedIn ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
  }

  /// Look up societies for an email (returns list).
  Future<List<SocietyLookupItem>> lookupSocieties(String email) async {
    return _service.lookupSocieties(email: email);
  }

  /// Login with society code + email + password.
  Future<void> login({
    required String societyId,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = await _service.login(
        societyId: societyId,
        email: email,
        password: password,
      );
      state = state.copyWith(status: AuthStatus.authenticated, token: token);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseError(e),
      );
    }
  }

  /// Activate account with invite token + set password.
  Future<void> activate({
    required String email,
    required String inviteToken,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final token = await _service.activate(
        email: email,
        inviteToken: inviteToken,
        password: password,
      );
      state = state.copyWith(status: AuthStatus.authenticated, token: token);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _parseError(e),
      );
    }
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  String _parseError(Object e) {
    if (e is Exception) {
      final msg = e.toString();
      if (msg.contains('401')) return 'Invalid email or password';
      if (msg.contains('404')) return 'Invalid invite token';
      if (msg.contains('409')) return 'Account is already activated';
      if (msg.contains('410')) return 'Invite token has expired — ask your admin to resend';
      if (msg.contains('SocketException') || msg.contains('connection')) {
        return 'No connection — check your network';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authServiceProvider)),
);
