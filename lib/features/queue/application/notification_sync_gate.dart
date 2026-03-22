import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';
import '../../../data/local/notification_listener/maybank_parser.dart';
import '../../../data/notification_listener/native_notification_service.dart';

class NotificationSyncGate extends ConsumerStatefulWidget {
  final Widget child;

  const NotificationSyncGate({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<NotificationSyncGate> createState() =>
      _NotificationSyncGateState();
}

class _NotificationSyncGateState extends ConsumerState<NotificationSyncGate> {
  StreamSubscription<Map<String, dynamic>>? _subscription;

  static const int _maxSeenTokens = 500;
  final Set<String> _seenTokens = <String>{};
  final ListQueue<String> _seenOrder = ListQueue<String>();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final buffered =
        await NativeNotificationService.consumeBufferedNotifications();

    for (final payload in buffered) {
      await _ingest(payload);
    }

    _subscription = NativeNotificationService.events.listen((payload) async {
      await _ingest(payload);
    });
  }

  Future<void> _ingest(Map<String, dynamic> payload) async {
    final eventToken = _buildEventToken(payload);

    if (_hasSeen(eventToken)) {
      return;
    }

    final parsed = MaybankParser.parse(payload);
    if (parsed == null) return;

    final queueToken = _buildQueueToken(
      rawText: parsed.rawText,
      sourceOrDestination: parsed.sourceOrDestination,
      detectedAmount: parsed.detectedAmount,
      detectedDirection: parsed.detectedDirection,
      detectedTime: parsed.detectedTime,
    );

    if (_hasSeen(queueToken)) {
      _rememberSeen(eventToken);
      return;
    }

    final queueDao = ref.read(notificationQueueDaoProvider);
    final existingItems = await queueDao.getAllQueueItems();

    final alreadyInQueue = existingItems.any(
      (item) => _buildQueueTokenFromItem(item) == queueToken,
    );

    if (alreadyInQueue) {
      _rememberSeen(eventToken);
      _rememberSeen(queueToken);
      return;
    }

    await queueDao.insertQueueItem(
      rawText: parsed.rawText,
      sourceOrDestination: parsed.sourceOrDestination,
      detectedAmount: parsed.detectedAmount,
      detectedDirection: parsed.detectedDirection,
      detectedTime: parsed.detectedTime,
      detectionStatus: parsed.detectionStatus,
    );

    _rememberSeen(eventToken);
    _rememberSeen(queueToken);
  }

  bool _hasSeen(String token) {
    if (token.isEmpty) return false;
    return _seenTokens.contains(token);
  }

  void _rememberSeen(String token) {
    if (token.isEmpty || _seenTokens.contains(token)) return;

    _seenTokens.add(token);
    _seenOrder.addLast(token);

    while (_seenOrder.length > _maxSeenTokens) {
      final oldest = _seenOrder.removeFirst();
      _seenTokens.remove(oldest);
    }
  }

  String _buildEventToken(Map<String, dynamic> payload) {
    final notificationKey = (payload['notificationKey'] ?? '').toString().trim();
    final postTime = (payload['postTime'] ?? '').toString().trim();

    if (notificationKey.isNotEmpty && postTime.isNotEmpty) {
      return 'event:$notificationKey:$postTime';
    }

    final packageName = (payload['packageName'] ?? '').toString();
    final title = (payload['title'] ?? '').toString();
    final text = (payload['text'] ?? '').toString();
    final subText = (payload['subText'] ?? '').toString();

    final fallback = [
      _normalizeForToken(packageName),
      _normalizeForToken(title),
      _normalizeForToken(text),
      _normalizeForToken(subText),
      postTime,
    ].join('|');

    if (fallback.replaceAll('|', '').isEmpty) {
      return '';
    }

    return 'event_fallback:$fallback';
  }

  String _buildQueueToken({
    required String rawText,
    required String? sourceOrDestination,
    required double? detectedAmount,
    required String? detectedDirection,
    required DateTime? detectedTime,
  }) {
    final amountText = detectedAmount?.toStringAsFixed(2) ?? 'null';
    final directionText = detectedDirection ?? 'null';
    final sourceText = sourceOrDestination ?? 'null';
    final timeText = detectedTime?.millisecondsSinceEpoch.toString() ?? 'null';

    return [
      'queue',
      _normalizeForToken(rawText),
      _normalizeForToken(sourceText),
      amountText,
      directionText,
      timeText,
    ].join('|');
  }

  String _buildQueueTokenFromItem(NotificationQueueData item) {
    return _buildQueueToken(
      rawText: item.rawText,
      sourceOrDestination: item.sourceOrDestination,
      detectedAmount: item.detectedAmount,
      detectedDirection: item.detectedDirection,
      detectedTime: item.detectedTime,
    );
  }

  String _normalizeForToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}