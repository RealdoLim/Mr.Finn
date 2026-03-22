import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';
import '../../../data/notification_listener/native_notification_service.dart';
import '../application/queue_providers.dart';
import 'accept_queue_item_dialog.dart';

class QueuePage extends ConsumerStatefulWidget {
  const QueuePage({super.key});

  @override
  ConsumerState<QueuePage> createState() => _QueuePageState();
}

class _QueuePageState extends ConsumerState<QueuePage>
    with WidgetsBindingObserver {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primarySoft = Color(0xFFCCFBF1);
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  static const Color _queue = Color(0xFF4F46E5);
  static const Color _queueSoft = Color(0xFFE0E7FF);

  static const Color _income = Color(0xFF16A34A);
  static const Color _incomeSoft = Color(0xFFDCFCE7);

  static const Color _expense = Color(0xFFDC2626);
  static const Color _expenseSoft = Color(0xFFFEE2E2);

  static const Color _warning = Color(0xFFD97706);
  static const Color _warningSoft = Color(0xFFFEF3C7);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationAccessProvider);
    }
  }

  Future<void> _showAcceptDialog(
    BuildContext context,
    NotificationQueueData item,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => AcceptQueueItemDialog(queueItem: item),
    );
  }

  Future<void> _rejectQueueItem(
    BuildContext context,
    WidgetRef ref,
    NotificationQueueData item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Queue Item'),
        content: const Text(
          'Rejecting this item will remove it from the queue and not create any transaction. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(notificationQueueDaoProvider).deleteQueueItem(item.id);
    }
  }

  String _formatMoney(double? amount) {
    if (amount == null) return '-';
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';

    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return '${dateTime.year}-$month-$day $hour:$minute:$second';
  }

  Future<void> _openAccessSettings() async {
    await NativeNotificationService.openAccessSettings();
  }

  Color _directionColor(String? direction) {
    switch (direction) {
      case 'income':
        return _income;
      case 'expense':
        return _expense;
      default:
        return _warning;
    }
  }

  Color _directionBackground(String? direction) {
    switch (direction) {
      case 'income':
        return _incomeSoft;
      case 'expense':
        return _expenseSoft;
      default:
        return _warningSoft;
    }
  }

  String _directionLabel(String? direction) {
    switch (direction) {
      case 'income':
        return 'Income';
      case 'expense':
        return 'Expense';
      default:
        return 'Unknown';
    }
  }

  IconData _directionIcon(String? direction) {
    switch (direction) {
      case 'income':
        return Icons.south_west_rounded;
      case 'expense':
        return Icons.north_east_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueAsync = ref.watch(queueItemsStreamProvider);
    final accessAsync = ref.watch(notificationAccessProvider);

    return ColoredBox(
      color: _background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _PageHeader(
                title: 'Queue',
                subtitle:
                    'Review detected Maybank notifications before turning them into transactions.',
              ),
              const SizedBox(height: 16),
              accessAsync.when(
                data: (granted) => _AccessStatusCard(
                  granted: granted,
                  onOpenSettings: _openAccessSettings,
                  surface: _surface,
                  border: _border,
                  textPrimary: _textPrimary,
                  textSecondary: _textSecondary,
                  grantedColor: _income,
                  grantedSoft: _incomeSoft,
                  warningColor: _warning,
                  warningSoft: _warningSoft,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: queueAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return _EmptyStateCard(
                        icon: Icons.notifications_active_outlined,
                        title: 'No queued notifications yet',
                        subtitle:
                            'New Maybank notifications will appear here for review before they become transactions.',
                        surface: _surface,
                        border: _border,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                      );
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return _QueueItemCard(
                          item: item,
                          amountText: _formatMoney(item.detectedAmount),
                          dateTimeText: _formatDateTime(item.detectedTime),
                          directionLabel:
                              _directionLabel(item.detectedDirection),
                          directionColor:
                              _directionColor(item.detectedDirection),
                          directionBackground:
                              _directionBackground(item.detectedDirection),
                          directionIcon: _directionIcon(item.detectedDirection),
                          queueColor: _queue,
                          queueSoft: _queueSoft,
                          textPrimary: _textPrimary,
                          textSecondary: _textSecondary,
                          surface: _surface,
                          border: _border,
                          onAccept: () => _showAcceptDialog(context, item),
                          onReject: () => _rejectQueueItem(context, ref, item),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
        ),
      ],
    );
  }
}

class _AccessStatusCard extends StatelessWidget {
  final bool granted;
  final VoidCallback onOpenSettings;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color grantedColor;
  final Color grantedSoft;
  final Color warningColor;
  final Color warningSoft;

  const _AccessStatusCard({
    required this.granted,
    required this.onOpenSettings,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.grantedColor,
    required this.grantedSoft,
    required this.warningColor,
    required this.warningSoft,
  });

  @override
  Widget build(BuildContext context) {
    final accent = granted ? grantedColor : warningColor;
    final soft = granted ? grantedSoft : warningSoft;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _TintedIcon(
              icon: granted ? Icons.check_circle : Icons.warning_amber_rounded,
              color: accent,
              background: soft,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    granted
                        ? 'Notification access enabled'
                        : 'Notification access not enabled',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    granted
                        ? 'Mr.Finn can currently receive Maybank notifications.'
                        : 'Open Android settings and enable Mr.Finn as a notification listener.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: onOpenSettings,
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QueueItemCard extends StatelessWidget {
  final NotificationQueueData item;
  final String amountText;
  final String dateTimeText;
  final String directionLabel;
  final Color directionColor;
  final Color directionBackground;
  final IconData directionIcon;
  final Color queueColor;
  final Color queueSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _QueueItemCard({
    required this.item,
    required this.amountText,
    required this.dateTimeText,
    required this.directionLabel,
    required this.directionColor,
    required this.directionBackground,
    required this.directionIcon,
    required this.queueColor,
    required this.queueSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final title = item.sourceOrDestination ?? 'Unknown source';

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TintedIcon(
              icon: directionIcon,
              color: directionColor,
              background: directionBackground,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        label: directionLabel,
                        color: directionColor,
                        background: directionBackground,
                      ),
                      _InfoChip(
                        label: 'Queued',
                        color: queueColor,
                        background: queueSoft,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Amount: $amountText',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detected Time: $dateTimeText',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Raw Text:',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.rawText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check),
                        label: const Text('Accept'),
                      ),
                      OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TintedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _TintedIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _InfoChip({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 42, color: textSecondary),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}