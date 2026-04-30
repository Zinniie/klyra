import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/models.dart';
import 'auth_repository.dart';

class MockAuthRepository extends AuthRepository {
  final _auth = FirebaseAuth.instance;
  KlyraUser? _currentUser;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Stream<KlyraUser?> userStream(String uid) {
    // Build from Firebase user on first call (e.g. after app restart)
    _currentUser ??= _buildUser(_auth.currentUser);
    return Stream.value(_currentUser);
  }

  @override
  Future<KlyraUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user == null) return null;
    _currentUser = _buildUser(cred.user);
    return _currentUser;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    required String phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    _currentUser = KlyraUser(
      uid:              cred.user!.uid,
      email:            email,
      displayName:      displayName,
      phone:            phone,
      balance:          0.0,
      currency:         'CAD',
      kycVerified:      false,
      biometricEnabled: false,
      createdAt:        DateTime.now(),
      accountNumber:    _accountNumber(cred.user!.uid),
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
  }

  @override
  Future<void> updateBiometricEnabled({
    required String uid,
    required bool enabled,
  }) async {
    _currentUser = _currentUser?.copyWith(biometricEnabled: enabled);
  }

  KlyraUser? _buildUser(User? user) {
    if (user == null) return null;
    return KlyraUser(
      uid:              user.uid,
      email:            user.email ?? '',
      displayName:      user.displayName ?? user.email ?? 'User',
      phone:            user.phoneNumber ?? '',
      balance:          4250.75,
      currency:         'CAD',
      kycVerified:      true,
      biometricEnabled: false,
      createdAt:        user.metadata.creationTime ?? DateTime.now(),
      accountNumber:    _accountNumber(user.uid),
    );
  }

  String _accountNumber(String uid) {
    final digits = uid.replaceAll(RegExp(r'[^0-9]'), '').padLeft(12, '0');
    return digits.length >= 12 ? digits.substring(0, 12) : digits.padRight(12, '0');
  }
}
