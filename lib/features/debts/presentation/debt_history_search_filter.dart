class DebtHistorySearchFilter {
  final String searchText;
  final String debtType; // all, owed, given
  final DateTime? fromDate;
  final DateTime? toDate;

  const DebtHistorySearchFilter({
    this.searchText = '',
    this.debtType = 'all',
    this.fromDate,
    this.toDate,
  });

  bool get hasCompleteDateRange => fromDate != null && toDate != null;

  bool get isActive {
    return searchText.trim().isNotEmpty ||
        debtType != 'all' ||
        hasCompleteDateRange;
  }

  DebtHistorySearchFilter copyWith({
    String? searchText,
    String? debtType,
    DateTime? fromDate,
    DateTime? toDate,
    bool clearFromDate = false,
    bool clearToDate = false,
  }) {
    return DebtHistorySearchFilter(
      searchText: searchText ?? this.searchText,
      debtType: debtType ?? this.debtType,
      fromDate: clearFromDate ? null : (fromDate ?? this.fromDate),
      toDate: clearToDate ? null : (toDate ?? this.toDate),
    );
  }

  static const empty = DebtHistorySearchFilter();
}