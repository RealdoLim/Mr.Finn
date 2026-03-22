import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';
import '../application/finance_providers.dart';
import 'add_transaction_dialog.dart';
import 'transaction_search_filter.dart';
import 'transaction_search_filter_dialog.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primarySoft = Color(0xFFCCFBF1);
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  static const Color _income = Color(0xFF16A34A);
  static const Color _incomeSoft = Color(0xFFDCFCE7);

  static const Color _expense = Color(0xFFDC2626);
  static const Color _expenseSoft = Color(0xFFFEE2E2);

  static const Color _debtGiven = Color(0xFF2563EB);
  static const Color _debtGivenSoft = Color(0xFFDBEAFE);

  static const Color _debtOwed = Color(0xFFD97706);
  static const Color _debtOwedSoft = Color(0xFFFEF3C7);

  static const Color _sourceManual = Color(0xFF475569);
  static const Color _sourceManualSoft = Color(0xFFF1F5F9);

  static const Color _sourceNotification = Color(0xFF4F46E5);
  static const Color _sourceNotificationSoft = Color(0xFFE0E7FF);

  TransactionSearchFilter _filter = TransactionSearchFilter.empty;

  Future<void> _showAddDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const AddTransactionDialog(),
    );
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    final result = await showDialog<TransactionSearchFilter>(
      context: context,
      builder: (_) => TransactionSearchFilterDialog(initialFilter: _filter),
    );

    if (result != null) {
      setState(() {
        _filter = result;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _filter = TransactionSearchFilter.empty;
    });
  }

  Future<void> _deleteDebtCascade(AppDatabase db, int debtId) async {
    await db.transactionsDao.deleteTransactionsForDebt(debtId);
    await db.debtsDao.deleteDebt(debtId);
  }

  Future<void> _recalculateDebtAfterRepaymentDeletion(
    AppDatabase db,
    Debt debt,
  ) async {
    final linkedTransactions = await db.transactionsDao.getTransactionsForDebt(
      debt.id,
    );

    double totalRepayments = 0;
    for (final tx in linkedTransactions) {
      if (tx.transactionKind == 'debt_given_repayment' ||
          tx.transactionKind == 'debt_owed_repayment') {
        totalRepayments += tx.amount;
      }
    }

    final rawRemaining = debt.originalAmount - totalRepayments;
    final isSettled = rawRemaining.abs() < 0.0001 || rawRemaining < 0;
    final newRemaining = isSettled ? 0.0 : rawRemaining;

    final String newStatus;
    if (isSettled) {
      newStatus = 'settled';
    } else if (totalRepayments > 0) {
      newStatus = 'partially_paid';
    } else {
      newStatus = 'active';
    }

    await db.debtsDao.updateDebtBalanceAndStatus(
      id: debt.id,
      remainingBalance: newRemaining,
      status: newStatus,
    );
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction tx,
  ) async {
    final linkedDebtId = tx.linkedDebtId;
    final isDebtLinked = linkedDebtId != null;

    String title = 'Delete Transaction';
    String content = 'Are you sure you want to delete this transaction?';

    if (isDebtLinked) {
      if (tx.transactionKind == 'debt_given_outflow') {
        title = 'Delete Debt Given';
        content =
            'This is the original Debt Given outflow. Deleting it will also delete the debt record and all linked debt transactions for this debt. Continue?';
      } else if (tx.transactionKind == 'debt_given_repayment' ||
          tx.transactionKind == 'debt_owed_repayment') {
        title = 'Delete Debt Repayment';
        content =
            'Deleting this repayment will restore the linked debt balance and status accordingly. Continue?';
      } else {
        title = 'Delete Debt-Linked Transaction';
        content =
            'This transaction is linked to a debt. Deleting it will update the linked debt accordingly. Continue?';
      }
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final db = ref.read(appDatabaseProvider);

    await db.transaction(() async {
      if (!isDebtLinked) {
        await db.transactionsDao.deleteTransaction(tx.id);
        return;
      }

      final debtId = linkedDebtId!;

      if (tx.transactionKind == 'debt_given_outflow') {
        final existingDebt = await db.debtsDao.getDebtById(debtId);
        if (existingDebt != null) {
          await _deleteDebtCascade(db, debtId);
        } else {
          await db.transactionsDao.deleteTransaction(tx.id);
        }
        return;
      }

      final existingDebt = await db.debtsDao.getDebtById(debtId);

      await db.transactionsDao.deleteTransaction(tx.id);

      if (existingDebt != null) {
        await _recalculateDebtAfterRepaymentDeletion(db, existingDebt);
      }
    });
  }

  List<Transaction> _applyFilter(List<Transaction> transactions) {
    final searchText = _filter.searchText.trim().toLowerCase();

    final hasDateRange = _filter.fromDate != null && _filter.toDate != null;

    final fromDate = hasDateRange
        ? DateTime(
            _filter.fromDate!.year,
            _filter.fromDate!.month,
            _filter.fromDate!.day,
          )
        : null;

    final toDate = hasDateRange
        ? DateTime(
            _filter.toDate!.year,
            _filter.toDate!.month,
            _filter.toDate!.day,
            23,
            59,
            59,
            999,
          )
        : null;

    return transactions.where((tx) {
      if (searchText.isNotEmpty &&
          !tx.description.toLowerCase().contains(searchText)) {
        return false;
      }

      if (_filter.direction != 'all' && tx.direction != _filter.direction) {
        return false;
      }

      if (hasDateRange) {
        if (tx.date.isBefore(fromDate!) || tx.date.isAfter(toDate!)) {
          return false;
        }
      }

      if (_filter.direction == 'expense') {
        if (_filter.category != null && tx.category != _filter.category) {
          return false;
        }

        if (_filter.spendingType != null &&
            tx.spendingType != _filter.spendingType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatMoney(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _labelForTransactionKind(String kind) {
    switch (kind) {
      case 'normal_income':
        return 'Income';
      case 'normal_expense':
        return 'Expense';
      case 'debt_given_outflow':
        return 'Debt Given';
      case 'debt_given_repayment':
        return 'Debt Repayment';
      case 'debt_owed_repayment':
        return 'Debt Payment';
      default:
        return kind;
    }
  }

  Color _chipColorForTransactionKind(String kind) {
    switch (kind) {
      case 'normal_income':
        return _income;
      case 'normal_expense':
        return _expense;
      case 'debt_given_outflow':
      case 'debt_given_repayment':
        return _debtGiven;
      case 'debt_owed_repayment':
        return _debtOwed;
      default:
        return _primary;
    }
  }

  Color _chipBackgroundForTransactionKind(String kind) {
    switch (kind) {
      case 'normal_income':
        return _incomeSoft;
      case 'normal_expense':
        return _expenseSoft;
      case 'debt_given_outflow':
      case 'debt_given_repayment':
        return _debtGivenSoft;
      case 'debt_owed_repayment':
        return _debtOwedSoft;
      default:
        return _primarySoft;
    }
  }

  Color _amountColor(Transaction tx) {
    return tx.direction == 'income' ? _income : _expense;
  }

  IconData _directionIcon(Transaction tx) {
    return tx.direction == 'income'
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;
  }

  Color _sourceChipColor(String source) {
    return source == 'bank_notification' ? _sourceNotification : _sourceManual;
  }

  Color _sourceChipBackground(String source) {
    return source == 'bank_notification'
        ? _sourceNotificationSoft
        : _sourceManualSoft;
  }

  String _sourceLabel(String source) {
    return source == 'bank_notification' ? 'Bank Notification' : 'Manual';
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);

    return ColoredBox(
      color: _background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _PageHeader(
                title: 'Finance',
                subtitle:
                    'Track all transactions, search history, and manage deletions safely.',
                actions: [
                  Container(
                    decoration: BoxDecoration(
                      color: _primarySoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      tooltip: 'Search / Filter',
                      onPressed: () => _showSearchDialog(context),
                      icon: const Icon(Icons.search),
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add transaction'),
                  ),
                ],
              ),
              if (_filter.isActive) ...[
                const SizedBox(height: 12),
                _FilterBanner(
                  title: 'Filters applied',
                  onClear: _clearFilter,
                  textPrimary: _textPrimary,
                  textSecondary: _textSecondary,
                  border: _border,
                  background: _surface,
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: transactionsAsync.when(
                  data: (transactions) {
                    final filteredTransactions = _applyFilter(transactions);

                    if (transactions.isEmpty) {
                      return _EmptyStateCard(
                        icon: Icons.receipt_long_outlined,
                        title: 'No transactions yet',
                        subtitle:
                            'Add a transaction to start building your finance history.',
                        surface: _surface,
                        border: _border,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                      );
                    }

                    if (filteredTransactions.isEmpty) {
                      return Column(
                        children: [
                          if (_filter.isActive)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Showing 0 of ${transactions.length} transactions',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: _EmptyStateCard(
                              icon: Icons.search_off_rounded,
                              title: 'No matching transactions',
                              subtitle:
                                  'Try adjusting your search keyword or filters.',
                              surface: _surface,
                              border: _border,
                              textPrimary: _textPrimary,
                              textSecondary: _textSecondary,
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        if (_filter.isActive)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Showing ${filteredTransactions.length} of ${transactions.length} transactions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: _textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: filteredTransactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final tx = filteredTransactions[index];

                              return _TransactionCard(
                                transaction: tx,
                                amountText: _formatMoney(tx.amount),
                                dateText: _formatDate(tx.date),
                                kindLabel:
                                    _labelForTransactionKind(tx.transactionKind),
                                chipColor:
                                    _chipColorForTransactionKind(
                                      tx.transactionKind,
                                    ),
                                chipBackground:
                                    _chipBackgroundForTransactionKind(
                                      tx.transactionKind,
                                    ),
                                amountColor: _amountColor(tx),
                                sourceChipColor: _sourceChipColor(tx.source),
                                sourceChipBackground: _sourceChipBackground(
                                  tx.source,
                                ),
                                sourceLabel: _sourceLabel(tx.source),
                                directionIcon: _directionIcon(tx),
                                textPrimary: _textPrimary,
                                textSecondary: _textSecondary,
                                surface: _surface,
                                border: _border,
                                onDelete: () => _handleDelete(context, ref, tx),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) =>
                      Center(child: Text('Error: $error')),
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
  final List<Widget> actions;

  const _PageHeader({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Column(
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
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterBanner extends StatelessWidget {
  final String title;
  final VoidCallback onClear;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color background;

  const _FilterBanner({
    required this.title,
    required this.onClear,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.filter_alt_outlined,
              size: 18,
              color: Color(0xFF0F766E),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClear,
              child: Text(
                'Clear Search',
                style: TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String amountText;
  final String dateText;
  final String kindLabel;
  final Color chipColor;
  final Color chipBackground;
  final Color amountColor;
  final Color sourceChipColor;
  final Color sourceChipBackground;
  final String sourceLabel;
  final IconData directionIcon;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;
  final VoidCallback onDelete;

  const _TransactionCard({
    required this.transaction,
    required this.amountText,
    required this.dateText,
    required this.kindLabel,
    required this.chipColor,
    required this.chipBackground,
    required this.amountColor,
    required this.sourceChipColor,
    required this.sourceChipBackground,
    required this.sourceLabel,
    required this.directionIcon,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
    required this.onDelete,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TintedIcon(
              icon: directionIcon,
              color: amountColor,
              background: transaction.direction == 'income'
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEE2E2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
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
                        label: kindLabel,
                        color: chipColor,
                        background: chipBackground,
                      ),
                      _InfoChip(
                        label: sourceLabel,
                        color: sourceChipColor,
                        background: sourceChipBackground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                  ),
                  if (transaction.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Category: ${transaction.category}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                    ),
                  ],
                  if (transaction.spendingType != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Type: ${transaction.spendingType}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: 'Delete transaction',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
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