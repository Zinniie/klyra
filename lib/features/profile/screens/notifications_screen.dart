import 'package:flutter/material.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<MockNotification> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(MockData.notifications);
  }

  void _markRead(String id) {
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx != -1 && !_items[idx].isRead) {
      setState(() => _items[idx] = _items[idx].copyWith(isRead: true));
    }
  }

  void _markAllRead() {
    setState(() {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    });
  }

  String _timeLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: KlyraColors.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: KlyraTextStyles.labelMedium.copyWith(color: KlyraColors.teal),
              ),
            ),
        ],
      ),
      body: _items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: KlyraSpacing.sm),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: 72,
                endIndent: KlyraSpacing.pageHorizontal,
              ),
              itemBuilder: (context, i) {
                final n = _items[i];
                return _NotificationTile(
                  notification: n,
                  timeLabel: _timeLabel(n.time),
                  onTap: () => _markRead(n.id),
                );
              },
            ),
    );
  }
}

// ── Tile ───────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.timeLabel,
    required this.onTap,
  });

  final MockNotification notification;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: n.isRead ? null : KlyraColors.teal.withOpacity(0.04),
        padding: const EdgeInsets.symmetric(
          horizontal: KlyraSpacing.pageHorizontal,
          vertical: KlyraSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: n.iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(n.icon, color: n.iconColor, size: 20),
            ),
            const SizedBox(width: KlyraSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: KlyraTextStyles.labelLarge.copyWith(
                            fontWeight:
                                n.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: KlyraSpacing.sm),
                      Text(timeLabel, style: KlyraTextStyles.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(n.body, style: KlyraTextStyles.bodySmall),
                ],
              ),
            ),
            if (!n.isRead) ...[
              const SizedBox(width: KlyraSpacing.sm),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: KlyraColors.teal,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none_outlined,
              size: 56, color: KlyraColors.muted),
          const SizedBox(height: KlyraSpacing.md),
          Text("You're all caught up", style: KlyraTextStyles.headlineSmall),
          const SizedBox(height: KlyraSpacing.sm),
          Text('No notifications yet', style: KlyraTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
