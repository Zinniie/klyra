import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/models.dart';
import '../../../core/mock/mock_data.dart';
import 'card_repository.dart';

class MockCardRepository extends CardRepository {
  late final List<KlyraCard> _cards;

  MockCardRepository() {
    _cards = List.of(MockData.cards);
  }

  @override
  Future<List<KlyraCard>> getCards(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final name = FirebaseAuth.instance.currentUser?.displayName ?? '';
    if (name.isEmpty) return List.of(_cards);
    return _cards.map((c) => KlyraCard(
      id: c.id, brand: c.brand, type: c.type,
      last4: c.last4, expiryMonth: c.expiryMonth, expiryYear: c.expiryYear,
      cardholderName: name, isDefault: c.isDefault,
      stripePaymentMethodId: c.stripePaymentMethodId, nickname: c.nickname,
    )).toList();
  }

  @override
  Future<void> addCard({required String userId, required KlyraCard card}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // If this is the first card, make it default
    final makeDefault = _cards.isEmpty;
    _cards.add(makeDefault
        ? KlyraCard(
            id: card.id, brand: card.brand, type: card.type,
            last4: card.last4, expiryMonth: card.expiryMonth,
            expiryYear: card.expiryYear, cardholderName: card.cardholderName,
            isDefault: true, stripePaymentMethodId: card.stripePaymentMethodId,
            nickname: card.nickname,
          )
        : card);
  }

  @override
  Future<void> removeCard({required String userId, required String cardId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _cards.removeWhere((c) => c.id == cardId);
    // Promote the first remaining card to default if the removed one was default
    if (_cards.isNotEmpty && !_cards.any((c) => c.isDefault)) {
      final first = _cards[0];
      _cards[0] = KlyraCard(
        id: first.id, brand: first.brand, type: first.type,
        last4: first.last4, expiryMonth: first.expiryMonth,
        expiryYear: first.expiryYear, cardholderName: first.cardholderName,
        isDefault: true, stripePaymentMethodId: first.stripePaymentMethodId,
        nickname: first.nickname,
      );
    }
  }

  @override
  Future<void> setDefaultCard({required String userId, required String cardId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    for (var i = 0; i < _cards.length; i++) {
      final c = _cards[i];
      if (c.isDefault != (c.id == cardId)) {
        _cards[i] = KlyraCard(
          id: c.id, brand: c.brand, type: c.type,
          last4: c.last4, expiryMonth: c.expiryMonth,
          expiryYear: c.expiryYear, cardholderName: c.cardholderName,
          isDefault: c.id == cardId,
          stripePaymentMethodId: c.stripePaymentMethodId,
          nickname: c.nickname,
        );
      }
    }
  }
}
