import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/models.dart';
import '../repository/auth_repository.dart';

// ── Events ─────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override List<Object?> get props => [];
}

class AuthStarted               extends AuthEvent { const AuthStarted(); }
class AuthSignInWithEmail       extends AuthEvent {
  const AuthSignInWithEmail({required this.email, required this.password});
  final String email;
  final String password;
  @override List<Object?> get props => [email];
}
class AuthSignInWithBiometric   extends AuthEvent { const AuthSignInWithBiometric(); }
class AuthSignInWithPin         extends AuthEvent {
  const AuthSignInWithPin({required this.pin});
  final String pin;
  @override List<Object?> get props => [pin];
}
class AuthRegister              extends AuthEvent {
  const AuthRegister({required this.email, required this.password, required this.displayName, required this.phone});
  final String email, password, displayName, phone;
  @override List<Object?> get props => [email];
}
class AuthSignOut               extends AuthEvent { const AuthSignOut(); }
class AuthSetupPin              extends AuthEvent {
  const AuthSetupPin({required this.pin});
  final String pin;
  @override List<Object?> get props => [pin];
}
class AuthEnableBiometric       extends AuthEvent { const AuthEnableBiometric(); }
class AuthUserUpdated           extends AuthEvent {
  const AuthUserUpdated({required this.user});
  final KlyraUser? user;
  @override List<Object?> get props => [user];
}

// ── States ─────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  const AuthState();
  @override List<Object?> get props => [];
}

class AuthInitial         extends AuthState { const AuthInitial(); }
class AuthLoading         extends AuthState { const AuthLoading(); }
class AuthAuthenticated   extends AuthState {
  const AuthAuthenticated({required this.user});
  final KlyraUser user;
  @override List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthError           extends AuthState {
  const AuthError({required this.message});
  final String message;
  @override List<Object?> get props => [message];
}
class AuthNeedsPin        extends AuthState { const AuthNeedsPin(); }
class AuthPinSetupDone    extends AuthState { const AuthPinSetupDone(); }
class AuthBiometricSetupDone extends AuthState { const AuthBiometricSetupDone(); }

// ── BLoC ───────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepository authRepository,
    required LocalAuthentication localAuth,
    required FlutterSecureStorage secureStorage,
  })  : _repo          = authRepository,
        _localAuth     = localAuth,
        _secureStorage = secureStorage,
        super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthSignInWithBiometric>(_onSignInWithBiometric);
    on<AuthSignInWithPin>(_onSignInWithPin);
    on<AuthRegister>(_onRegister);
    on<AuthSignOut>(_onSignOut);
    on<AuthSetupPin>(_onSetupPin);
    on<AuthEnableBiometric>(_onEnableBiometric);
    on<AuthUserUpdated>(_onUserUpdated);
  }

  final AuthRepository       _repo;
  final LocalAuthentication  _localAuth;
  final FlutterSecureStorage _secureStorage;
  StreamSubscription<KlyraUser?>? _userSub;

  // ── Handlers ────────────────────────────────────────────────

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final uid = _repo.currentUid;
      if (uid == null) {
        emit(const AuthUnauthenticated());
        return;
      }
      _userSub = _repo.userStream(uid).listen(
        (user) => add(AuthUserUpdated(user: user)),
      );
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithEmail(AuthSignInWithEmail event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signInWithEmail(email: event.email, password: event.password);
      if (user != null) {
        _userSub?.cancel();
        _userSub = _repo.userStream(user.uid).listen(
          (u) => add(AuthUserUpdated(user: u)),
        );
      } else {
        emit(const AuthError(message: 'Invalid credentials. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _mapFirebaseError(e.code)));
    } catch (e) {
      emit(const AuthError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onSignInWithBiometric(AuthSignInWithBiometric event, Emitter<AuthState> emit) async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canAuth) {
        emit(const AuthError(message: 'Biometric authentication not available.'));
        return;
      }
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Klyra',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (!authenticated) {
        emit(const AuthError(message: 'Biometric authentication failed.'));
        return;
      }
      // Retrieve stored credentials and re-auth
      final email    = await _secureStorage.read(key: 'klyra_email');
      final password = await _secureStorage.read(key: 'klyra_password');
      if (email == null || password == null) {
        emit(const AuthError(message: 'Session expired. Please sign in with email.'));
        return;
      }
      add(AuthSignInWithEmail(email: email, password: password));
    } catch (e) {
      emit(const AuthError(message: 'Biometric authentication failed.'));
    }
  }

  Future<void> _onSignInWithPin(AuthSignInWithPin event, Emitter<AuthState> emit) async {
    try {
      final storedPin = await _secureStorage.read(key: 'klyra_pin');
      if (storedPin == null) {
        emit(const AuthError(message: 'No PIN set. Please use email to sign in.'));
        return;
      }
      if (storedPin != event.pin) {
        emit(const AuthError(message: 'Incorrect PIN. Please try again.'));
        return;
      }
      final email    = await _secureStorage.read(key: 'klyra_email');
      final password = await _secureStorage.read(key: 'klyra_password');
      if (email == null || password == null) {
        emit(const AuthError(message: 'Session expired. Please sign in with email.'));
        return;
      }
      add(AuthSignInWithEmail(email: email, password: password));
    } catch (e) {
      emit(const AuthError(message: 'Authentication failed. Please try again.'));
    }
  }

  Future<void> _onRegister(AuthRegister event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _repo.register(
        email:       event.email,
        password:    event.password,
        displayName: event.displayName,
        phone:       event.phone,
      );
      await _secureStorage.write(key: 'klyra_email',    value: event.email);
      await _secureStorage.write(key: 'klyra_password', value: event.password);

      // Subscribe to user stream so AuthAuthenticated is emitted and app navigates
      final uid = _repo.currentUid;
      if (uid != null) {
        _userSub?.cancel();
        _userSub = _repo.userStream(uid).listen(
          (user) => add(AuthUserUpdated(user: user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _mapFirebaseError(e.code)));
    } catch (e) {
      emit(const AuthError(message: 'Registration failed. Please try again.'));
    }
  }

  Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    await _userSub?.cancel();
    _userSub = null;
    await _repo.signOut();
    await _secureStorage.delete(key: 'klyra_pin');
    await _secureStorage.delete(key: 'klyra_email');
    await _secureStorage.delete(key: 'klyra_password');
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSetupPin(AuthSetupPin event, Emitter<AuthState> emit) async {
    try {
      await _secureStorage.write(key: 'klyra_pin', value: event.pin);
      emit(const AuthPinSetupDone());
    } catch (e) {
      emit(const AuthError(message: 'Failed to set PIN. Please try again.'));
    }
  }

  Future<void> _onEnableBiometric(AuthEnableBiometric event, Emitter<AuthState> emit) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Confirm your identity to enable biometric login',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (authenticated) {
        final currentState = state;
        if (currentState is AuthAuthenticated) {
          await _repo.updateBiometricEnabled(uid: currentState.user.uid, enabled: true);
          emit(const AuthBiometricSetupDone());
        }
      }
    } catch (e) {
      emit(const AuthError(message: 'Failed to enable biometric login.'));
    }
  }

  void _onUserUpdated(AuthUserUpdated event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':           return 'No account found with that email.';
      case 'wrong-password':           return 'Incorrect password. Please try again.';
      case 'invalid-credential':       return 'Incorrect email or password.';
      case 'invalid-login-credentials':return 'Incorrect email or password.';
      case 'email-already-in-use':     return 'An account with this email already exists.';
      case 'weak-password':            return 'Password is too weak.';
      case 'invalid-email':            return 'Please enter a valid email address.';
      case 'user-disabled':            return 'This account has been disabled.';
      case 'too-many-requests':        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':   return 'Network error. Check your connection.';
      default:                         return 'Sign in failed ($code). Please try again.';
    }
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
