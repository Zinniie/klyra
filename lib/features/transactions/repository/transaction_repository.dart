import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/models.dart';
import '../../../core/theme/app_theme.dart';

// ── Abstract interface ─────────────────────────────────────────
abstract class TransactionRepository {
  Future<List<KlyraTransaction>> getRecentTransactions(String userId, {int limit});
  Future<List<KlyraUser>> searchRecipients(String query);
  Future<KlyraTransaction> sendMoney({
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String recipientPhone,
    required double amount,
    String? note,
  });
}

// ── Firebase implementation ────────────────────────────────────
class FirebaseTransactionRepository extends TransactionRepository {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<List<KlyraTransaction>> getRecentTransactions(
    String userId, {
    int limit = 20,
  }) async {
    final sentSnap = await _firestore
        .collection(KlyraConstants.transactionsCollection)
        .where('senderId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    final receivedSnap = await _firestore
        .collection(KlyraConstants.transactionsCollection)
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    final seen = <String>{};
    final all  = <KlyraTransaction>[];
    for (final d in [...sentSnap.docs, ...receivedSnap.docs]) {
      if (seen.add(d.id)) all.add(KlyraTransaction.fromFirestore(d));
    }
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all.take(limit).toList();
  }

  @override
  Future<List<KlyraUser>> searchRecipients(String query) async {
    if (query.isEmpty) return [];

    final byPhone = await _firestore
        .collection(KlyraConstants.usersCollection)
        .where('phone', isEqualTo: query)
        .limit(5)
        .get();

    final byName = await _firestore
        .collection(KlyraConstants.usersCollection)
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: '${query}z')
        .limit(5)
        .get();

    final seen    = <String>{};
    final results = <KlyraUser>[];
    for (final d in [...byPhone.docs, ...byName.docs]) {
      if (seen.add(d.id)) results.add(KlyraUser.fromFirestore(d));
    }
    return results;
  }

  @override
  Future<KlyraTransaction> sendMoney({
    required String senderId,
    required String senderName,
    required String recipientId,
    required String recipientName,
    required String recipientPhone,
    required double amount,
    String? note,
  }) async {
    final batch        = _firestore.batch();
    final txRef        = _firestore.collection(KlyraConstants.transactionsCollection).doc();
    final senderRef    = _firestore.collection(KlyraConstants.usersCollection).doc(senderId);
    final recipientRef = _firestore.collection(KlyraConstants.usersCollection).doc(recipientId);

    final now    = DateTime.now();
    final txData = {
      'type':           TransactionType.send.name,
      'status':         TransactionStatus.completed.name,
      'amount':         amount,
      'currency':       'CAD',
      'description':    'Sent to $recipientName',
      'timestamp':      Timestamp.fromDate(now),
      'senderId':       senderId,
      'senderName':     senderName,
      'recipientId':    recipientId,
      'recipientName':  recipientName,
      'recipientPhone': recipientPhone,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    batch.set(txRef, txData);
    batch.update(senderRef,    {'balance': FieldValue.increment(-amount)});
    batch.update(recipientRef, {'balance': FieldValue.increment(amount)});

    await batch.commit();

    return KlyraTransaction(
      id:            txRef.id,
      type:          TransactionType.send,
      status:        TransactionStatus.completed,
      amount:        amount,
      currency:      'CAD',
      description:   'Sent to $recipientName',
      timestamp:     now,
      senderId:      senderId,
      senderName:    senderName,
      recipientId:   recipientId,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      note:          note,
    );
  }
}
