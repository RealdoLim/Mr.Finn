class TransactionSearchFilter {
  final String searchText;
  final String direction; // all, income, expense
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? category;
  final String? spendingType;

  const TransactionSearchFilter({
    this.searchText = '',
    this.direction = 'all',
    this.fromDate,
    this.toDate,
    this.category,
    this.spendingType,
  });

  bool get hasCompleteDateRange => fromDate != null && toDate != null;

  bool get isActive {
    return searchText.trim().isNotEmpty ||
        direction != 'all' ||
        hasCompleteDateRange ||
        category != null ||
        spendingType != null;
  }

  TransactionSearchFilter copyWith({
    String? searchText,
    String? direction,
    DateTime? fromDate,
    DateTime? toDate,
    String? category,
    String? spendingType,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearCategory = false,
    bool clearSpendingType = false,
  }) {
    return TransactionSearchFilter(
      searchText: searchText ?? this.searchText,
      direction: direction ?? this.direction,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
      category: clearCategory ? null : (category ?? this.category),
      spendingType: clearSpendingType
          ? null
          : (spendingType ?? this.spendingType),
    );
  }

  static const empty = TransactionSearchFilter();
}