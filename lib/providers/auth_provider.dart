import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';

/// Auth state notifier
class AuthNotifier extends AsyncNotifier<User?> {
  late final AuthService _authService;

  @override
  Future<User?> build() async {
    _authService = AuthService();
    return _authService.currentUser;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      return credential.user;
    });
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      return _authService.currentUser;
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authService.signInWithGoogle();
      return _authService.currentUser;
    });
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncData(null);
  }

  Future<void> sendPasswordReset(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

/// Auth state stream provider
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService().authStateChanges;
});

/// Current user profile provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return await AuthService().getUserFromFirestore(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Theme mode provider (persisted)
class ThemeModeNotifier extends Notifier<ThemeModeState> {
  @override
  ThemeModeState build() {
    _loadTheme();
    return ThemeModeState.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme_mode') ?? 'system';
    state = ThemeModeState.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeModeState.system,
    );
  }

  Future<void> setTheme(ThemeModeState mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }

  Future<void> toggle() async {
    if (state == ThemeModeState.light) {
      await setTheme(ThemeModeState.dark);
    } else {
      await setTheme(ThemeModeState.light);
    }
  }
}

enum ThemeModeState { light, dark, system }

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeModeState>(() {
  return ThemeModeNotifier();
});
