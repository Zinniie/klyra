import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ── User Model ─────────────────────────────────────────────────
class KlyraUser extends Equatable {
  const KlyraUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phone,
    required this.balance,
    required this.currency,
    required this.kycVerified,
    required this.biometricEnabled,
    required this.createdAt,
    this.avatarUrl,
    this.accountNumber,
  });

  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final double balance;
  final String currency;
  final bool kycVerified;
  final bool biometricEnabled;
  final DateTime createdAt;
  final String? avatarUrl;
  final String? accountNumber;

  factory KlyraUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KlyraUser(
      uid:              doc.id,
      email:            data['email'] as String,
      displayName:      data['displayName'] as String,
      phone:            data['phone'] as String? ?? '',
      balance:          (data['balance'] as num?)?.toDouble() ?? 0.0,
      currency:         data['currency'] as String? ?? 'CAD',
      kycVerified:      data['kycVerified'] as bool? ?? false,
      biometricEnabled: data['biometricEnabled'] as bool? ?? false,
      createdAt:        data['createdAt'] != null
                          ? (data['createdAt'] as Timestamp).toDate()
                          : DateTime.now(),
      avatarUrl:        data['avatarUrl'] as String?,
      accountNumber:    data['accountNumber'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email':            email,
    'displayName':      displayName,
    'phone':            phone,
    'balance':          balance,
    'currency':         currency,
    'kycVerified':      kycVerified,
    'biometricEnabled': biometricEnabled,
    'createdAt':        Timestamp.fromDate(createdAt),
    'avatarUrl':        avatarUrl,
    'accountNumber':    accountNumber,
  };

  KlyraUser copyWith({
    String? displayName,
    String? phone,
    double? balance,
    bool? kycVerified,
    bool? biometricEnabled,
    String? avatarUrl,
    String? accountNumber,
  }) => KlyraUser(
    uid:              uid,
    email:            email,
    displayName:      displayName ?? this.displayName,
    phone:            phone ?? this.phone,
    balance:          balance ?? this.balance,
    currency:         currency,
    kycVerified:      kycVerified ?? this.kycVerified,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    createdAt:        createdAt,
    avatarUrl:        avatarUrl ?? this.avatarUrl,
    accountNumber:    accountNumber ?? this.accountNumber,
  );

  String get firstName => displayName.split(' ').first;

  @override
  List<Object?> get props => [uid, email, balance, kycVerified, biometricEnabled];
}

// ── Transaction Model ──────────────────────────────────────────
enum TransactionType { send, receive, topUp, withdrawal, billPayment }
enum TransactionStatus { pending, completed, failed, cancelled }

class KlyraTransaction extends Equatable {
  const KlyraTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    required this.description,
    required this.timestamp,
    this.recipientId,
    this.recipientName,
    this.recipientPhone,
    this.senderId,
    this.senderName,
    this.reference,
    this.category,
    this.note,
    this.stripePaymentIntentId,
  });

  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final String description;
  final DateTime timestamp;
  final String? recipientId;
  final String? recipientName;
  final String? recipientPhone;
  final String? senderId;
  final String? senderName;
  final String? reference;
  final String? category;
  final String? note;
  final String? stripePaymentIntentId;

  factory KlyraTransaction.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return KlyraTransaction(
      id:                    doc.id,
      type:                  TransactionType.values.byName(d['type'] as String),
      status:                TransactionStatus.values.byName(d['status'] as String),
      amount:                (d['amount'] as num).toDouble(),
      currency:              d['currency'] as String? ?? 'CAD',
      description:           d['description'] as String,
      timestamp:             d['timestamp'] != null
                               ? (d['timestamp'] as Timestamp).toDate()
                               : DateTime.now(),
      recipientId:           d['recipientId'] as String?,
      recipientName:         d['recipientName'] as String?,
      recipientPhone:        d['recipientPhone'] as String?,
      senderId:              d['senderId'] as String?,
      senderName:            d['senderName'] as String?,
      reference:             d['reference'] as String?,
      category:              d['category'] as String?,
      note:                  d['note'] as String?,
      stripePaymentIntentId: d['stripePaymentIntentId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'type':                  type.name,
    'status':                status.name,
    'amount':                amount,
    'currency':              currency,
    'description':           description,
    'timestamp':             Timestamp.fromDate(timestamp),
    'recipientId':           recipientId,
    'recipientName':         recipientName,
    'recipientPhone':        recipientPhone,
    'senderId':              senderId,
    'senderName':            senderName,
    'reference':             reference,
    'category':              category,
    'note':                  note,
    'stripePaymentIntentId': stripePaymentIntentId,
  };

  bool get isCredit => type == TransactionType.receive || type == TransactionType.topUp;
  bool get isDebit  => !isCredit;

  String get typeLabel {
    switch (type) {
      case TransactionType.send:        return 'Sent';
      case TransactionType.receive:     return 'Received';
      case TransactionType.topUp:       return 'Top Up';
      case TransactionType.withdrawal:  return 'Withdrawal';
      case TransactionType.billPayment: return 'Bill Payment';
    }
  }

  @override
  List<Object?> get props => [id, type, status, amount, timestamp];
}

// ── Card Model ─────────────────────────────────────────────────
enum CardBrand { visa, mastercard, amex, discover, other }
enum CardType  { debit, credit, prepaid }

class KlyraCard extends Equatable {
  const KlyraCard({
    required this.id,
    required this.brand,
    required this.type,
    required this.last4,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cardholderName,
    required this.isDefault,
    required this.stripePaymentMethodId,
    this.nickname,
  });

  final String id;
  final CardBrand brand;
  final CardType type;
  final String last4;
  final int expiryMonth;
  final int expiryYear;
  final String cardholderName;
  final bool isDefault;
  final String stripePaymentMethodId;
  final String? nickname;

  factory KlyraCard.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return KlyraCard(
      id:                    doc.id,
      brand:                 CardBrand.values.byName(d['brand'] as String? ?? 'other'),
      type:                  CardType.values.byName(d['type'] as String? ?? 'debit'),
      last4:                 d['last4'] as String,
      expiryMonth:           d['expiryMonth'] as int,
      expiryYear:            d['expiryYear'] as int,
      cardholderName:        d['cardholderName'] as String,
      isDefault:             d['isDefault'] as bool? ?? false,
      stripePaymentMethodId: d['stripePaymentMethodId'] as String,
      nickname:              d['nickname'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'brand':                 brand.name,
    'type':                  type.name,
    'last4':                 last4,
    'expiryMonth':           expiryMonth,
    'expiryYear':            expiryYear,
    'cardholderName':        cardholderName,
    'isDefault':             isDefault,
    'stripePaymentMethodId': stripePaymentMethodId,
    'nickname':              nickname,
  };

  String get displayLabel => nickname ?? '•••• $last4';
  String get expiryLabel  => '${expiryMonth.toString().padLeft(2, '0')}/$expiryYear';

  @override
  List<Object?> get props => [id, last4, stripePaymentMethodId];
}
