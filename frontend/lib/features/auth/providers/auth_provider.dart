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

  Future<void> register({
    required String societyId,
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _service.register(
        societyId: societyId,
        fullName: fullName,
        email: email,
        password: password,
      );
      // Auto-login after registration
      await login(societyId: societyId, email: email, password: password);
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
      if (msg.contains('409')) return 'Email already registered in this society';
      if (msg.contains('404')) return 'Society not found';
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
