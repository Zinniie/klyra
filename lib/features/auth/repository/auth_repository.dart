import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

// ── Abstract interface ─────────────────────────────────────────
abstract class AuthRepository {
  String? get currentUid;
  Stream<KlyraUser?> userStream(String uid);
  Future<KlyraUser?> signInWithEmail({required String email, required String password});
  Future<void> register({required String email, required String password, required String displayName, required String phone});
  Future<void> signOut();
  Future<void> updateBiometricEnabled({required String uid, required bool enabled});
}

// ── Firebase implementation ────────────────────────────────────
class FirebaseAuthRepository extends AuthRepository {
  final _auth      = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Stream<KlyraUser?> userStream(String uid) {
    return _firestore
        .collection(KlyraConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((snap) => snap.exists ? KlyraUser.fromFirestore(snap) : null);
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
    final uid  = cred.user!.uid;
    final snap = await _firestore
        .collection(KlyraConstants.usersCollection)
        .doc(uid)
        .get();

    if (!snap.exists) {
      await _firestore.collection(KlyraConstants.usersCollection).doc(uid).set({
        'email':            cred.user!.email ?? '',
        'displayName':      cred.user!.displayName ?? cred.user!.email ?? '',
        'phone':            '',
        'balance':          0.0,
        'currency':         'CAD',
        'accountNumber':    _generateAccountNumber(uid),
        'kycVerified':      false,
        'biometricEnabled': false,
        'createdAt':        FieldValue.serverTimestamp(),
      });
      final created = await _firestore
          .collection(KlyraConstants.usersCollection)
          .doc(uid)
          .get();
      return KlyraUser.fromFirestore(created);
    }
    return KlyraUser.fromFirestore(snap);
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
    final uid = cred.user!.uid;
    await _firestore.collection(KlyraConstants.usersCollection).doc(uid).set({
      'email': email,
      'displayName': displayName,
      'phone': phone,
      'balance': 0.0,
      'currency': 'CAD',
      'accountNumber': _generateAccountNumber(uid),
      'kycVerified': false,
      'biometricEnabled': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> updateBiometricEnabled({
    required String uid,
    required bool enabled,
  }) async {
    await _firestore
        .collection(KlyraConstants.usersCollection)
        .doc(uid)
        .update({'biometricEnabled': enabled});
  }

  String _generateAccountNumber(String uid) {
    final digits = uid.replaceAll(RegExp(r'[^0-9]'), '').padLeft(12, '0');
    return digits.length >= 12 ? digits.substring(0, 12) : digits.padRight(12, '0');
  }
}
