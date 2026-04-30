import 'package:flutter/material.dart';
import '../models/models.dart';

// ── Notification model (mock-only) ────────────────────────────
class MockNotification {
  const MockNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });

  final String   id;
  final String   title;
  final String   body;
  final DateTime time;
  final IconData icon;
  final Color    iconColor;
  final bool     isRead;

  MockNotification copyWith({bool? isRead}) => MockNotification(
    id: id, title: title, body: body, time: time,
    icon: icon, iconColor: iconColor,
    isRead: isRead ?? this.isRead,
  );
}

// ── All static demo content ─────────────────────────────────
class MockData {
  MockData._();

  // The signed-in user (email is set dynamically at login)
  static KlyraUser buildUser(String email) => KlyraUser(
    uid:              'mock-uid-001',
    email:            email,
    displayName:      'Amara Osei',
    phone:            '+1 416 555 0192',
    balance:          4250.75,
    currency:         'CAD',
    kycVerified:      true,
    biometricEnabled: false,
    createdAt:        DateTime(2024, 3, 10),
    accountNumber:    '483920174856',
  );

  // ── Recipients for Send Money search ──────────────────────
  static final List<KlyraUser> recipients = [
    KlyraUser(
      uid: 'mock-uid-002', email: 'marcus.j@example.com',
      displayName: 'Marcus Johnson', phone: '+1 647 555 0201',
      balance: 0, currency: 'CAD', kycVerified: true,
      biometricEnabled: false, createdAt: DateTime(2024, 1, 5),
      accountNumber: '291038475610',
    ),
    KlyraUser(
      uid: 'mock-uid-003', email: 'priya.s@example.com',
      displayName: 'Priya Sharma', phone: '+1 416 555 0348',
      balance: 0, currency: 'CAD', kycVerified: true,
      biometricEnabled: false, createdAt: DateTime(2024, 2, 14),
      accountNumber: '374829105637',
    ),
    KlyraUser(
      uid: 'mock-uid-004', email: 'david.c@example.com',
      displayName: 'David Chen', phone: '+1 905 555 0129',
      balance: 0, currency: 'CAD', kycVerified: true,
      biometricEnabled: false, createdAt: DateTime(2024, 1, 22),
      accountNumber: '109283746521',
    ),
    KlyraUser(
      uid: 'mock-uid-005', email: 'olivia.m@example.com',
      displayName: 'Olivia Mensah', phone: '+1 416 555 0472',
      balance: 0, currency: 'CAD', kycVerified: true,
      biometricEnabled: false, createdAt: DateTime(2023, 12, 8),
      accountNumber: '827364019283',
    ),
    KlyraUser(
      uid: 'mock-uid-006', email: 'kofi.a@example.com',
      displayName: 'Kofi Asante', phone: '+1 647 555 0583',
      balance: 0, currency: 'CAD', kycVerified: false,
      biometricEnabled: false, createdAt: DateTime(2024, 4, 1),
      accountNumber: '564738291046',
    ),
    KlyraUser(
      uid: 'mock-uid-007', email: 'sofia.r@example.com',
      displayName: 'Sofia Rodriguez', phone: '+1 416 555 0694',
      balance: 0, currency: 'CAD', kycVerified: true,
      biometricEnabled: false, createdAt: DateTime(2024, 3, 17),
      accountNumber: '193847562038',
    ),
    KlyraUser(
      uid: 'mock-uid-008', email: 'james.o@example.com',
      displayName: 'James Okafor', phone: '+1 905 555 0715',
      balance: 0, currency: 'CAD', kycVerified: true,
      biometricEnabled: false, createdAt: DateTime(2024, 2, 28),
      accountNumber: '647392018574',
    ),
    KlyraUser(
      uid: 'mock-uid-009', email: 'emma.t@example.com',
      displayName: 'Emma Thompson', phone: '+1 416 555 0826',
      balance: 0, currency: 'CAD', kycVerified: true,
      biometricEnabled: false, createdAt: DateTime(2023, 11, 19),
      accountNumber: '038274619582',
    ),
  ];

  // ── Transactions ──────────────────────────────────────────
  static List<KlyraTransaction> transactions(String userId) => [
    KlyraTransaction(
      id: 'tx-001', type: TransactionType.receive,
      status: TransactionStatus.completed, amount: 450.00,
      currency: 'CAD', description: 'Received from Marcus Johnson',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      senderId: 'mock-uid-002', senderName: 'Marcus Johnson',
      recipientId: userId, recipientName: 'Amara Osei',
    ),
    KlyraTransaction(
      id: 'tx-002', type: TransactionType.send,
      status: TransactionStatus.completed, amount: 125.50,
      currency: 'CAD', description: 'Sent to Priya Sharma',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      senderId: userId, senderName: 'Amara Osei',
      recipientId: 'mock-uid-003', recipientName: 'Priya Sharma',
      recipientPhone: '+1 416 555 0348', note: 'Dinner last night 🍜',
    ),
    KlyraTransaction(
      id: 'tx-003', type: TransactionType.topUp,
      status: TransactionStatus.completed, amount: 500.00,
      currency: 'CAD', description: 'Wallet top-up',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      recipientId: userId,
    ),
    KlyraTransaction(
      id: 'tx-004', type: TransactionType.send,
      status: TransactionStatus.completed, amount: 75.00,
      currency: 'CAD', description: 'Sent to David Chen',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      senderId: userId, senderName: 'Amara Osei',
      recipientId: 'mock-uid-004', recipientName: 'David Chen',
      recipientPhone: '+1 905 555 0129',
    ),
    KlyraTransaction(
      id: 'tx-005', type: TransactionType.receive,
      status: TransactionStatus.completed, amount: 300.00,
      currency: 'CAD', description: 'Received from Olivia Mensah',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      senderId: 'mock-uid-005', senderName: 'Olivia Mensah',
      recipientId: userId, recipientName: 'Amara Osei',
      note: 'Rent split 🏠',
    ),
    KlyraTransaction(
      id: 'tx-006', type: TransactionType.send,
      status: TransactionStatus.pending, amount: 200.00,
      currency: 'CAD', description: 'Sent to Kofi Asante',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      senderId: userId, senderName: 'Amara Osei',
      recipientId: 'mock-uid-006', recipientName: 'Kofi Asante',
      recipientPhone: '+1 647 555 0583',
    ),
    KlyraTransaction(
      id: 'tx-007', type: TransactionType.topUp,
      status: TransactionStatus.completed, amount: 1000.00,
      currency: 'CAD', description: 'Wallet top-up',
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
      recipientId: userId,
    ),
    KlyraTransaction(
      id: 'tx-008', type: TransactionType.send,
      status: TransactionStatus.completed, amount: 45.99,
      currency: 'CAD', description: 'Sent to Sofia Rodriguez',
      timestamp: DateTime.now().subtract(const Duration(days: 8)),
      senderId: userId, senderName: 'Amara Osei',
      recipientId: 'mock-uid-007', recipientName: 'Sofia Rodriguez',
      recipientPhone: '+1 416 555 0694', note: 'Coffee ☕',
    ),
    KlyraTransaction(
      id: 'tx-009', type: TransactionType.receive,
      status: TransactionStatus.completed, amount: 150.00,
      currency: 'CAD', description: 'Received from James Okafor',
      timestamp: DateTime.now().subtract(const Duration(days: 10)),
      senderId: 'mock-uid-008', senderName: 'James Okafor',
      recipientId: userId, recipientName: 'Amara Osei',
    ),
    KlyraTransaction(
      id: 'tx-010', type: TransactionType.send,
      status: TransactionStatus.failed, amount: 89.00,
      currency: 'CAD', description: 'Sent to Emma Thompson',
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
      senderId: userId, senderName: 'Amara Osei',
      recipientId: 'mock-uid-009', recipientName: 'Emma Thompson',
      recipientPhone: '+1 416 555 0826',
    ),
  ];

  // ── Cards ─────────────────────────────────────────────────
  static final List<KlyraCard> cards = [
    const KlyraCard(
      id: 'card-001', brand: CardBrand.visa, type: CardType.debit,
      last4: '4242', expiryMonth: 12, expiryYear: 27,
      cardholderName: 'Amara Osei', isDefault: true,
      stripePaymentMethodId: 'pm_mock_visa_4242',
    ),
    const KlyraCard(
      id: 'card-002', brand: CardBrand.mastercard, type: CardType.credit,
      last4: '5353', expiryMonth: 8, expiryYear: 26,
      cardholderName: 'Amara Osei', isDefault: false,
      stripePaymentMethodId: 'pm_mock_mc_5353',
      nickname: 'Travel Card',
    ),
  ];

  // ── Notifications ─────────────────────────────────────────
  static final List<MockNotification> notifications = [
    MockNotification(
      id: 'notif-001',
      title: 'Transfer received',
      body: 'Marcus Johnson sent you \$450.00',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      icon: Icons.south_west_rounded,
      iconColor: const Color(0xFF1D9E75),
    ),
    MockNotification(
      id: 'notif-002',
      title: 'Payment sent',
      body: 'You sent \$125.50 to Priya Sharma',
      time: DateTime.now().subtract(const Duration(hours: 18)),
      icon: Icons.north_east_rounded,
      iconColor: const Color(0xFF0D1B2A),
    ),
    MockNotification(
      id: 'notif-003',
      title: 'Top-up successful',
      body: '\$500.00 has been added to your wallet',
      time: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFF1D9E75),
    ),
    MockNotification(
      id: 'notif-004',
      title: 'Transfer received',
      body: 'Olivia Mensah sent you \$300.00',
      time: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.south_west_rounded,
      iconColor: const Color(0xFF1D9E75),
    ),
    MockNotification(
      id: 'notif-005',
      title: 'Transfer pending',
      body: 'Your transfer of \$200.00 to Kofi Asante is processing',
      time: DateTime.now().subtract(const Duration(days: 4)),
      icon: Icons.schedule_rounded,
      iconColor: const Color(0xFFF59E0B),
      isRead: true,
    ),
    MockNotification(
      id: 'notif-006',
      title: 'Security alert',
      body: 'New sign-in detected from iPhone · Toronto, ON',
      time: DateTime.now().subtract(const Duration(days: 6)),
      icon: Icons.security_rounded,
      iconColor: const Color(0xFF0D1B2A),
      isRead: true,
    ),
    MockNotification(
      id: 'notif-007',
      title: 'Top-up successful',
      body: '\$1,000.00 has been added to your wallet',
      time: DateTime.now().subtract(const Duration(days: 6)),
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFF1D9E75),
      isRead: true,
    ),
  ];
}
