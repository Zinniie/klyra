import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

// ── Abstract interface ─────────────────────────────────────────
abstract class CardRepository {
  Future<List<KlyraCard>> getCards(String userId);
  Future<void> addCard({required String userId, required KlyraCard card});
  Future<void> removeCard({required String userId, required String cardId});
  Future<void> setDefaultCard({required String userId, required String cardId});
}

// ── Firebase implementation ────────────────────────────────────
class FirebaseCardRepository extends CardRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference _cardsRef(String userId) => _firestore
      .collection(KlyraConstants.usersCollection)
      .doc(userId)
      .collection(KlyraConstants.cardsCollection);

  @override
  Future<List<KlyraCard>> getCards(String userId) async {
    final snap = await _cardsRef(userId).get();
    return snap.docs.map((d) => KlyraCard.fromFirestore(d)).toList();
  }

  @override
  Future<void> addCard({required String userId, required KlyraCard card}) =>
      _cardsRef(userId).doc(card.id).set(card.toFirestore());

  @override
  Future<void> removeCard({required String userId, required String cardId}) =>
      _cardsRef(userId).doc(cardId).delete();

  @override
  Future<void> setDefaultCard({
    required String userId,
    required String cardId,
  }) async {
    final batch = _firestore.batch();
    final snap  = await _cardsRef(userId).get();
    for (final d in snap.docs) {
      batch.update(d.reference, {'isDefault': d.id == cardId});
    }
    await batch.commit();
  }
}
