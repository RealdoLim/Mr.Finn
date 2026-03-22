import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../application/dashboard_providers.dart';
import '../../finance/application/finance_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

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

  bool _isSameMonth(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month;
  }

  bool _isSameDay(DateTime date, DateTime now) {
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSpendingTransaction(Transaction tx) {
    return tx.transactionKind == 'normal_expense' ||
        tx.transactionKind == 'debt_owed_repayment';
  }

  double _calculateTotalBalance(List<Transaction> transactions) {
    double total = 0;

    for (final tx in transactions) {
      if (tx.direction == 'income') {
        total += tx.amount;
      } else if (tx.direction == 'expense') {
        total -= tx.amount;
      }
    }

    return total;
  }

  double _calculateIncomeThisMonth(
    List<Transaction> transactions,
    DateTime now,
  ) {
    double total = 0;

    for (final tx in transactions) {
      if (tx.transactionKind == 'normal_income' && _isSameMonth(tx.date, now)) {
        total += tx.amount;
      }
    }

    return total;
  }

  double _calculateSpendingThisMonth(
    List<Transaction> transactions,
    DateTime now,
  ) {
    double total = 0;

    for (final tx in transactions) {
      if (_isSpendingTransaction(tx) && _isSameMonth(tx.date, now)) {
        total += tx.amount;
      }
    }

    return total;
  }

  double _calculateSpendingToday(
    List<Transaction> transactions,
    DateTime now,
  ) {
    double total = 0;

    for (final tx in transactions) {
      if (_isSpendingTransaction(tx) && _isSameDay(tx.date, now)) {
        total += tx.amount;
      }
    }

    return total;
  }

  Map<String, double> _buildCategoryTotals(
    List<Transaction> transactions,
    DateTime now,
  ) {
    final totals = <String, double>{};

    for (final tx in transactions) {
      if (_isSpendingTransaction(tx) &&
          _isSameMonth(tx.date, now) &&
          tx.category != null) {
        totals[tx.category!] = (totals[tx.category!] ?? 0) + tx.amount;
      }
    }

    return totals;
  }

  Map<String, double> _buildSpendingTypeTotals(
    List<Transaction> transactions,
    DateTime now,
  ) {
    final totals = <String, double>{};

    for (final tx in transactions) {
      if (_isSpendingTransaction(tx) &&
          _isSameMonth(tx.date, now) &&
          tx.spendingType != null) {
        totals[tx.spendingType!] = (totals[tx.spendingType!] ?? 0) + tx.amount;
      }
    }

    return totals;
  }

  List<_MonthlySpendingHistoryEntry> _buildMonthlySpendingHistory(
    List<Transaction> transactions,
  ) {
    final grouped = <String, double>{};

    for (final tx in transactions) {
      if (_isSpendingTransaction(tx)) {
        final key =
            '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}';
        grouped[key] = (grouped[key] ?? 0) + tx.amount;
      }
    }

    final entries = grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      return _MonthlySpendingHistoryEntry(
        year: year,
        month: month,
        total: entry.value,
      );
    }).toList();

    entries.sort((a, b) {
      final yearCompare = b.year.compareTo(a.year);
      if (yearCompare != 0) return yearCompare;
      return b.month.compareTo(a.month);
    });

    return entries;
  }

  String _monthYearLabel(int month, int year) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[month - 1]} $year';
  }

  String _formatMoney(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _showSetBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    double currentBudget,
  ) async {
    String budgetText =
        currentBudget > 0 ? currentBudget.toStringAsFixed(2) : '';

    final result = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Budget'),
        content: TextFormField(
          initialValue: budgetText,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monthly Budget',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            budgetText = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = double.tryParse(budgetText.trim());
              if (value == null || value < 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid budget amount'),
                  ),
                );
                return;
              }

              FocusScope.of(dialogContext).unfocus();
              await Future<void>.delayed(const Duration(milliseconds: 80));

              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null) return;
    if (!context.mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 120));

    if (!context.mounted) return;

    await ref.read(monthlyBudgetProvider.notifier).setBudget(result);
  }

  Future<void> _showSpendingHistoryDialog(
    BuildContext context,
    List<_MonthlySpendingHistoryEntry> history,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _expenseSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: _expense,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Monthly Spending History',
                style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                      color: _textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(dialogContext).size.width < 500 ? 320 : 420,
          child: history.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'No spending history yet.',
                    style: Theme.of(dialogContext)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: _textSecondary),
                  ),
                )
              : ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _expenseSoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.bar_chart_rounded,
                                  color: _expense,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _monthYearLabel(entry.month, entry.year),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              Text(
                                _formatMoney(entry.total),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: _expense,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _balanceColor(double amount) {
    if (amount > 0) return _income;
    if (amount < 0) return _expense;
    return _textPrimary;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final currentDateAsync = ref.watch(currentDateTimeProvider);
    final monthlyBudgetAsync = ref.watch(monthlyBudgetProvider);

    final now = currentDateAsync.value ?? DateTime.now();
    final monthlyBudget = monthlyBudgetAsync.value ?? 0.0;

    return ColoredBox(
      color: _background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: transactionsAsync.when(
            data: (transactions) {
              final totalBalance = _calculateTotalBalance(transactions);
              final incomeThisMonth = _calculateIncomeThisMonth(
                transactions,
                now,
              );
              final spendingThisMonth = _calculateSpendingThisMonth(
                transactions,
                now,
              );
              final spendingToday = _calculateSpendingToday(transactions, now);
              final budgetRemaining = monthlyBudget - spendingThisMonth;
              final categoryTotals = _buildCategoryTotals(transactions, now);
              final spendingTypeTotals = _buildSpendingTypeTotals(
                transactions,
                now,
              );
              final recentTransactions = transactions.take(5).toList();
              final monthlyHistory = _buildMonthlySpendingHistory(transactions);

              return ListView(
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your money, budget, and recent activity at a glance.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _textSecondary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _HeroBalanceCard(
                    title: 'Total Balance',
                    value: _formatMoney(totalBalance),
                    valueColor: _balanceColor(totalBalance),
                    primaryColor: _primary,
                    primarySoft: _primarySoft,
                    surface: _surface,
                    textPrimary: _textPrimary,
                    textSecondary: _textSecondary,
                    border: _border,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        width: 240,
                        title: 'Income This Month',
                        value: _formatMoney(incomeThisMonth),
                        icon: Icons.arrow_downward_rounded,
                        accent: _income,
                        accentSoft: _incomeSoft,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                        surface: _surface,
                        border: _border,
                      ),
                      _MetricActionCard(
                        width: 240,
                        title: 'Spending This Month',
                        value: _formatMoney(spendingThisMonth),
                        icon: Icons.arrow_upward_rounded,
                        accent: _expense,
                        accentSoft: _expenseSoft,
                        actionIcon: Icons.history_rounded,
                        onAction: () =>
                            _showSpendingHistoryDialog(context, monthlyHistory),
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                        surface: _surface,
                        border: _border,
                      ),
                      _MetricCard(
                        width: 240,
                        title: 'Spending Today',
                        value: _formatMoney(spendingToday),
                        icon: Icons.today_rounded,
                        accent: _expense,
                        accentSoft: _expenseSoft,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                        surface: _surface,
                        border: _border,
                      ),
                      _BudgetMetricCard(
                        width: 240,
                        title: 'Budget Remaining',
                        value: _formatMoney(budgetRemaining),
                        icon: Icons.account_balance_wallet_outlined,
                        accent: budgetRemaining >= 0 ? _primary : _expense,
                        accentSoft:
                            budgetRemaining >= 0 ? _primarySoft : _expenseSoft,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                        surface: _surface,
                        border: _border,
                        onSetBudget: () =>
                            _showSetBudgetDialog(context, ref, monthlyBudget),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Spending Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ChartCard(
                        width: 520,
                        title: 'Expense Categories',
                        subtitle: 'How your spending is distributed this month',
                        totals: categoryTotals,
                        formatMoney: _formatMoney,
                        colors: const [
                          Color(0xFF0F766E),
                          Color(0xFF2563EB),
                          Color(0xFFD97706),
                          Color(0xFF7C3AED),
                          Color(0xFFDC2626),
                          Color(0xFF16A34A),
                          Color(0xFFF59E0B),
                          Color(0xFF4F46E5),
                        ],
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                        surface: _surface,
                        border: _border,
                      ),
                      _ChartCard(
                        width: 520,
                        title: 'Spending Type',
                        subtitle: 'Essential vs enjoyment spending this month',
                        totals: spendingTypeTotals,
                        formatMoney: _formatMoney,
                        colors: const [
                          Color(0xFF0F766E),
                          Color(0xFFD97706),
                        ],
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                        surface: _surface,
                        border: _border,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (recentTransactions.isEmpty)
                    _EmptyStateCard(
                      icon: Icons.receipt_long_outlined,
                      title: 'No transactions yet',
                      subtitle:
                          'Your latest transactions will appear here once you start using the app.',
                      surface: _surface,
                      border: _border,
                      textPrimary: _textPrimary,
                      textSecondary: _textSecondary,
                    )
                  else
                    ...recentTransactions.map(
                      (tx) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RecentTransactionCard(
                          transaction: tx,
                          amountText: _formatMoney(tx.amount),
                          dateText: _formatDate(tx.date),
                          kindLabel:
                              _labelForTransactionKind(tx.transactionKind),
                          chipColor:
                              _chipColorForTransactionKind(tx.transactionKind),
                          chipBackground: _chipBackgroundForTransactionKind(
                            tx.transactionKind,
                          ),
                          textPrimary: _textPrimary,
                          textSecondary: _textSecondary,
                          surface: _surface,
                          border: _border,
                          amountColor:
                              tx.direction == 'income' ? _income : _expense,
                        ),
                      ),
                    ),
                ],
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
      ),
    );
  }
}

class _MonthlySpendingHistoryEntry {
  final int year;
  final int month;
  final double total;

  const _MonthlySpendingHistoryEntry({
    required this.year,
    required this.month,
    required this.total,
  });
}

class _HeroBalanceCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final Color primaryColor;
  final Color primarySoft;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const _HeroBalanceCard({
    required this.title,
    required this.value,
    required this.valueColor,
    required this.primaryColor,
    required this.primarySoft,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: valueColor,
                              fontWeight: FontWeight.w800,
                            ),
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

class _MetricCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;

  const _MetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TintedIcon(
                icon: icon,
                color: accent,
                background: accentSoft,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricActionCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final IconData actionIcon;
  final VoidCallback onAction;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;

  const _MetricActionCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.actionIcon,
    required this.onAction,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _TintedIcon(
                    icon: icon,
                    color: accent,
                    background: accentSoft,
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: 'View spending history',
                      onPressed: onAction,
                      icon: Icon(actionIcon, color: accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
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

class _BudgetMetricCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;
  final VoidCallback onSetBudget;

  const _BudgetMetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
    required this.onSetBudget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _TintedIcon(
                    icon: icon,
                    color: accent,
                    background: accentSoft,
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: accentSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: 'Set Budget',
                      onPressed: onSetBudget,
                      icon: Icon(Icons.settings_outlined, color: accent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
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

class _ChartCard extends StatelessWidget {
  final double width;
  final String title;
  final String subtitle;
  final Map<String, double> totals;
  final String Function(double amount) formatMoney;
  final List<Color> colors;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;

  const _ChartCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.totals,
    required this.formatMoney,
    required this.colors,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalAmount = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.value,
    );

    final sections = List.generate(entries.length, (index) {
      final entry = entries[index];
      return PieChartSectionData(
        value: entry.value,
        title: '',
        radius: 58,
        color: colors[index % colors.length],
      );
    });

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: entries.isEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                    ),
                    const SizedBox(height: 26),
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.pie_chart_outline_rounded,
                            size: 42,
                            color: textSecondary,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No data available yet',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 44,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...List.generate(entries.length, (index) {
                      final entry = entries[index];
                      final color = colors[index % colors.length];
                      final percentage = totalAmount == 0
                          ? 0
                          : (entry.value / totalAmount) * 100;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Text(
                              formatMoney(entry.value),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RecentTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String amountText;
  final String dateText;
  final String kindLabel;
  final Color chipColor;
  final Color chipBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;
  final Color amountColor;

  const _RecentTransactionCard({
    required this.transaction,
    required this.amountText,
    required this.dateText,
    required this.kindLabel,
    required this.chipColor,
    required this.chipBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TintedIcon(
              icon: transaction.direction == 'income'
                  ? Icons.south_west_rounded
                  : Icons.north_east_rounded,
              color: amountColor,
              background:
                  transaction.direction == 'income'
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
                        label: transaction.source == 'bank_notification'
                            ? 'Bank Notification'
                            : 'Manual',
                        color: const Color(0xFF4F46E5),
                        background: const Color(0xFFE0E7FF),
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
            Text(
              amountText,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
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