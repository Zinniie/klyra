import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/models.dart';
import '../../../core/mock/mock_data.dart';
import 'transaction_repository.dart';

class MockTransactionRepository extends TransactionRepository {
  late final List<KlyraTransaction> _txs;

  MockTransactionRepository() {
    _txs = List.of(MockData.transactions('mock-uid-001'));
  }

  String get _realName =>
      FirebaseAuth.instance.currentUser?.displayName ?? 'You';

  // Replace the hardcoded 'Amara Osei' placeholder with the real user's name.
  KlyraTransaction _localise(KlyraTransaction tx) {
    final name = _realName;
    return KlyraTransaction(
      id:            tx.id,
      type:          tx.type,
      status:        tx.status,
      amount:        tx.amount,
      currency:      tx.currency,
      description:   tx.description.replaceAll('Amara Osei', name),
      timestamp:     tx.timestamp,
      senderId:      tx.senderId,
      senderName:    tx.senderName == 'Amara Osei' ? name : tx.senderName,
      recipientId:   tx.recipientId,
      recipientName: tx.recipientName == 'Amara Osei' ? name : tx.recipientName,
      recipientPhone: tx.recipientPhone,
      note:          tx.note,
      reference:     tx.reference,
      category:      tx.category,
    );
  }

  @override
  Future<List<KlyraTransaction>> getRecentTransactions(
    String userId, {
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // All dummy transactions belong to the current user regardless of uid.
    final sorted = List.of(_txs)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(limit).map(_localise).toList();
  }

  @override
  Future<List<KlyraUser>> searchRecipients(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return MockData.recipients
        .where((u) =>
            u.displayName.toLowerCase().contains(q) || u.phone.contains(q))
        .toList();
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
    await Future.delayed(const Duration(milliseconds: 800));
    final tx = KlyraTransaction(
      id:             'tx-${DateTime.now().millisecondsSinceEpoch}',
      type:           TransactionType.send,
      status:         TransactionStatus.completed,
      amount:         amount,
      currency:       'CAD',
      description:    'Sent to $recipientName',
      timestamp:      DateTime.now(),
      senderId:       senderId,
      senderName:     senderName,
      recipientId:    recipientId,
      recipientName:  recipientName,
      recipientPhone: recipientPhone,
      note:           note,
    );
    _txs.insert(0, tx);
    return tx;
  }
}
