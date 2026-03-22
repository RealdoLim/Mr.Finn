enum ParseConfidence {
  high,
  medium,
  low,
}

class ParsedMaybankNotification {
  final String rawText;
  final String? sourceOrDestination;
  final double? detectedAmount;
  final String? detectedDirection;
  final DateTime? detectedTime;
  final ParseConfidence confidence;

  const ParsedMaybankNotification({
    required this.rawText,
    required this.sourceOrDestination,
    required this.detectedAmount,
    required this.detectedDirection,
    required this.detectedTime,
    required this.confidence,
  });

  String get detectionStatus {
    switch (confidence) {
      case ParseConfidence.high:
        return 'parsed_high';
      case ParseConfidence.medium:
        return 'parsed_medium';
      case ParseConfidence.low:
        return 'parsed_low';
    }
  }
}

class _MatchedNotification {
  final String direction;
  final String? description;
  final double? amount;
  final ParseConfidence confidence;

  const _MatchedNotification({
    required this.direction,
    required this.description,
    required this.amount,
    required this.confidence,
  });
}

class MaybankParser {
  static ParsedMaybankNotification? parse(Map<String, dynamic> payload) {
    final packageName = (payload['packageName'] ?? '').toString();
    final title = (payload['title'] ?? '').toString();
    final text = (payload['text'] ?? '').toString();
    final subText = (payload['subText'] ?? '').toString();

    final lowerPackage = packageName.toLowerCase();
    final lowerTitle = title.toLowerCase();
    final lowerText = text.toLowerCase();
    final lowerSubText = subText.toLowerCase();

    final isMaybank = lowerPackage.contains('maybank') ||
        lowerTitle.contains('maybank') ||
        lowerText.contains('maybank') ||
        lowerSubText.contains('maybank') ||
        (lowerPackage.contains('mae') &&
            (lowerTitle.contains('transaction') ||
                lowerText.contains('rm') ||
                lowerSubText.contains('rm')));

    if (!isMaybank) return null;

    final normalizedTitle = _normalizeText(title);
    final normalizedText = _normalizeText(text);
    final normalizedSubText = _normalizeText(subText);

    final combinedRaw = [
      if (normalizedTitle.isNotEmpty) normalizedTitle,
      if (normalizedText.isNotEmpty) normalizedText,
      if (normalizedSubText.isNotEmpty) normalizedSubText,
    ].join(' | ');

    final searchableText = [
      normalizedTitle,
      normalizedText,
      normalizedSubText,
    ].where((part) => part.isNotEmpty).join(' ');

    if (_looksLikeNonTransactionNotification(searchableText)) {
      return null;
    }

    final matched = _matchKnownPatterns(searchableText);
    if (matched != null) {
      return ParsedMaybankNotification(
        rawText: combinedRaw,
        sourceOrDestination: matched.description,
        detectedAmount: matched.amount,
        detectedDirection: matched.direction,
        detectedTime: _parsePostTime(payload['postTime']),
        confidence: matched.confidence,
      );
    }

    final amount = _extractFirstAmount(searchableText);
    final direction = _inferDirection(normalizedTitle, searchableText);
    final description = _inferDescription(searchableText, direction);
    final confidence = _inferConfidence(
      amount: amount,
      direction: direction,
      description: description,
    );

    if (confidence == null) return null;

    return ParsedMaybankNotification(
      rawText: combinedRaw,
      sourceOrDestination: description,
      detectedAmount: amount,
      detectedDirection: direction,
      detectedTime: _parsePostTime(payload['postTime']),
      confidence: confidence,
    );
  }

  static bool _looksLikeNonTransactionNotification(String text) {
    final lower = text.toLowerCase();

    if (lower.contains('to be approved')) return true;
    if (lower.contains('secure2u') && !lower.contains('rm')) return true;
    if (lower.contains('approve') && !lower.contains('rm')) return true;
    if (lower.contains('approval') && !lower.contains('rm')) return true;

    return false;
  }

  static _MatchedNotification? _matchKnownPatterns(String text) {
    final patterns = <_MatchedNotification? Function(String)>[
      _matchReceivedFrom,
      _matchTransferredTo,
      _matchPaymentTo,
      _matchSpentAtMerchant,
    ];

    for (final matcher in patterns) {
      final result = matcher(text);
      if (result != null) return result;
    }

    return null;
  }

  static _MatchedNotification? _matchReceivedFrom(String text) {
    final regexes = [
      RegExp(
        r"""(?:you(?:'|’)ve|you have)?\s*(?:just\s*)?received\s*rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+from\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ),
      RegExp(
        r"""received\s*rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+from\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ),
    ];

    for (final regex in regexes) {
      final match = regex.firstMatch(text);
      if (match != null) {
        return _MatchedNotification(
          direction: 'income',
          amount: _parseAmount(match.group(1)),
          description: _cleanPersonName(match.group(2)),
          confidence: ParseConfidence.high,
        );
      }
    }

    return null;
  }

  static _MatchedNotification? _matchTransferredTo(String text) {
    final regexes = [
      RegExp(
        r"""(?:you(?:'|’)ve|you have)?\s*transferred\s*rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+to\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ),
      RegExp(
        r"""transferred\s*rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+to\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ),
    ];

    for (final regex in regexes) {
      final match = regex.firstMatch(text);
      if (match != null) {
        return _MatchedNotification(
          direction: 'expense',
          amount: _parseAmount(match.group(1)),
          description: _cleanPersonName(match.group(2)),
          confidence: ParseConfidence.high,
        );
      }
    }

    return null;
  }

  static _MatchedNotification? _matchPaymentTo(String text) {
    final regexes = [
      RegExp(
        r"""(?:successful\s+payment(?:\s+of)?|payment(?:\s+of)?|paid)\s*rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+to\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ),
      RegExp(
        r"""rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+(?:paid|payment)\s+to\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ),
    ];

    for (final regex in regexes) {
      final match = regex.firstMatch(text);
      if (match != null) {
        return _MatchedNotification(
          direction: 'expense',
          amount: _parseAmount(match.group(1)),
          description: _cleanMerchantName(match.group(2)),
          confidence: ParseConfidence.high,
        );
      }
    }

    return null;
  }

  static _MatchedNotification? _matchSpentAtMerchant(String text) {
    final regexes = [
      RegExp(
        r"""(?:you(?:'|’)ve|you have)?(?:\s+just)?\s*spent\s*rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+(?:at|on)\s+(.+?)(?:\s+with|\s+using|\.{3}|$)""",
        caseSensitive: false,
      ),
      RegExp(
        r"""spent\s*rm\s*([0-9,]+(?:\.[0-9]{1,2})?)\s+(?:at|on)\s+(.+?)(?:\s+with|\s+using|\.{3}|$)""",
        caseSensitive: false,
      ),
    ];

    for (final regex in regexes) {
      final match = regex.firstMatch(text);
      if (match != null) {
        return _MatchedNotification(
          direction: 'expense',
          amount: _parseAmount(match.group(1)),
          description: _cleanMerchantName(match.group(2)),
          confidence: ParseConfidence.high,
        );
      }
    }

    return null;
  }

  static ParseConfidence? _inferConfidence({
    required double? amount,
    required String? direction,
    required String? description,
  }) {
    if (amount == null) return null;

    if (direction != null && description != null) {
      return ParseConfidence.medium;
    }

    return ParseConfidence.low;
  }

  static String? _inferDirection(String title, String text) {
    final lowerTitle = title.toLowerCase();
    final lowerText = text.toLowerCase();

    var incomeScore = 0;
    var expenseScore = 0;

    if (lowerText.contains('received')) incomeScore += 3;
    if (lowerText.contains('from')) incomeScore += 1;

    if (lowerText.contains('transferred')) expenseScore += 3;
    if (lowerText.contains('successful payment')) expenseScore += 3;
    if (lowerText.contains('payment')) expenseScore += 2;
    if (lowerText.contains('spent')) expenseScore += 3;
    if (lowerText.contains('paid')) expenseScore += 2;
    if (lowerText.contains('to')) expenseScore += 1;
    if (lowerText.contains('at ')) expenseScore += 2;
    if (lowerText.contains('on ')) expenseScore += 1;

    if (lowerTitle.contains('card transaction')) expenseScore += 3;
    if (lowerTitle.contains('transfer')) expenseScore += 2;

    if (incomeScore == 0 && expenseScore == 0) return null;
    return incomeScore > expenseScore ? 'income' : 'expense';
  }

  static String? _inferDescription(String text, String? direction) {
    if (direction == 'income') {
      final fromMatch = RegExp(
        r"""from\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ).firstMatch(text);

      if (fromMatch != null) {
        return _cleanPersonName(fromMatch.group(1));
      }
    }

    if (direction == 'expense') {
      final toMatch = RegExp(
        r"""to\s+(.+?)(?:\s+ref:|\s+with|\.{3}|$)""",
        caseSensitive: false,
      ).firstMatch(text);

      if (toMatch != null) {
        return _cleanMerchantName(toMatch.group(1));
      }

      final atMatch = RegExp(
        r"""(?:at|on)\s+(.+?)(?:\s+with|\s+using|\.{3}|$)""",
        caseSensitive: false,
      ).firstMatch(text);

      if (atMatch != null) {
        return _cleanMerchantName(atMatch.group(1));
      }
    }

    return null;
  }

  static String? _cleanPersonName(String? raw) {
    final cleaned = _cleanBase(raw);
    if (cleaned == null) return null;
    return _firstTwoWords(cleaned);
  }

  static String? _cleanMerchantName(String? raw) {
    final cleaned = _cleanBase(raw);
    if (cleaned == null) return null;

    final beforeDash = cleaned.split('-').first.trim();
    final rawWords = beforeDash
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();

    final filtered = rawWords.where((word) {
      if (_isLikelyReferenceToken(word)) return false;
      return true;
    }).toList();

    while (filtered.isNotEmpty &&
        _merchantLeadingStopwords.contains(filtered.first.toLowerCase())) {
      filtered.removeAt(0);
    }

    if (filtered.isEmpty) return _firstTwoWords(beforeDash);
    return _firstTwoWords(filtered.join(' '));
  }

  static String? _cleanBase(String? raw) {
    if (raw == null) return null;

    var cleaned = raw
        .replaceAll(RegExp(r'\s+ref:.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+with.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+using.*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\.{3,}$'), '')
        .replaceAll(RegExp(r'[.]$'), '')
        .replaceAll(RegExp(r'[^A-Za-z0-9&/\- ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) return null;
    return cleaned;
  }

  static String? _firstTwoWords(String? raw) {
    if (raw == null) return null;

    final words = raw
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return null;

    final selected = words.take(2).map(_toTitleCaseWord).join(' ');
    return selected.isEmpty ? null : selected;
  }

  static bool _isLikelyReferenceToken(String word) {
    final normalized = word.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (normalized.length < 5) return false;
    final hasDigit = RegExp(r'\d').hasMatch(normalized);
    return hasDigit;
  }

  static const Set<String> _merchantLeadingStopwords = {'the'};

  static String _normalizeText(String value) {
    return value.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String _toTitleCaseWord(String word) {
    if (word.isEmpty) return word;
    final lower = word.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  static double? _parseAmount(String? raw) {
    if (raw == null) return null;
    return double.tryParse(raw.replaceAll(',', ''));
  }

  static double? _extractFirstAmount(String text) {
    final match = RegExp(
      r'RM\s*([0-9,]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);

    return _parseAmount(match?.group(1));
  }

  static DateTime? _parsePostTime(dynamic value) {
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }

    return null;
  }
}