import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';
import '../application/debts_providers.dart';
import 'add_edit_debt_dialog.dart';
import 'debt_history_search_filter.dart';
import 'debt_history_search_filter_dialog.dart';

class DebtsPage extends ConsumerStatefulWidget {
  const DebtsPage({super.key});

  @override
  ConsumerState<DebtsPage> createState() => _DebtsPageState();
}

class _DebtsPageState extends ConsumerState<DebtsPage> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primarySoft = Color(0xFFCCFBF1);
  static const Color _background = Color(0xFFF8FAFC);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  static const Color _given = Color(0xFF2563EB);
  static const Color _givenSoft = Color(0xFFDBEAFE);

  static const Color _owed = Color(0xFFD97706);
  static const Color _owedSoft = Color(0xFFFEF3C7);

  static const Color _active = Color(0xFF0F766E);
  static const Color _activeSoft = Color(0xFFCCFBF1);

  static const Color _partial = Color(0xFFD97706);
  static const Color _partialSoft = Color(0xFFFEF3C7);

  static const Color _settled = Color(0xFF16A34A);
  static const Color _settledSoft = Color(0xFFDCFCE7);

  bool _showHistory = false;
  DebtHistorySearchFilter _historyFilter = DebtHistorySearchFilter.empty;

  Future<void> _showAddDialog() async {
    await showDialog(
      context: context,
      builder: (_) => const AddEditDebtDialog(),
    );
  }

  Future<void> _showEditDialog(Debt debt) async {
    await showDialog(
      context: context,
      builder: (_) => AddEditDebtDialog(debt: debt),
    );
  }

  Future<void> _showHistorySearchDialog() async {
    final result = await showDialog<DebtHistorySearchFilter>(
      context: context,
      builder: (_) =>
          DebtHistorySearchFilterDialog(initialFilter: _historyFilter),
    );

    if (result != null) {
      setState(() {
        _historyFilter = result;
      });
    }
  }

  void _clearHistoryFilter() {
    setState(() {
      _historyFilter = DebtHistorySearchFilter.empty;
    });
  }

  Future<void> _confirmDelete(Debt debt) async {
    final linkedTransactions = await ref
        .read(transactionsDaoProvider)
        .getTransactionsForDebt(debt.id);

    final linkedCount = linkedTransactions.length;

    final content = linkedCount == 0
        ? 'Are you sure you want to delete the debt for ${debt.personName}?'
        : 'Are you sure you want to delete the debt for ${debt.personName}? This will also delete $linkedCount linked debt transaction(s).';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Debt'),
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

    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);

      await db.transaction(() async {
        await db.transactionsDao.deleteTransactionsForDebt(debt.id);
        await db.debtsDao.deleteDebt(debt.id);
      });
    }
  }

  List<Debt> _applyHistoryFilter(List<Debt> debts) {
    final searchText = _historyFilter.searchText.trim().toLowerCase();

    final hasDateRange =
        _historyFilter.fromDate != null && _historyFilter.toDate != null;

    final fromDate = hasDateRange
        ? DateTime(
            _historyFilter.fromDate!.year,
            _historyFilter.fromDate!.month,
            _historyFilter.fromDate!.day,
          )
        : null;

    final toDate = hasDateRange
        ? DateTime(
            _historyFilter.toDate!.year,
            _historyFilter.toDate!.month,
            _historyFilter.toDate!.day,
            23,
            59,
            59,
            999,
          )
        : null;

    return debts.where((debt) {
      if (searchText.isNotEmpty) {
        final matchesPerson = debt.personName.toLowerCase().contains(searchText);
        final matchesDescription =
            debt.description.toLowerCase().contains(searchText);

        if (!matchesPerson && !matchesDescription) {
          return false;
        }
      }

      if (_historyFilter.debtType != 'all' &&
          debt.type != _historyFilter.debtType) {
        return false;
      }

      if (hasDateRange) {
        if (debt.dateCreated.isBefore(fromDate!) ||
            debt.dateCreated.isAfter(toDate!)) {
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

  String _labelForType(String type) {
    if (type == 'owed') return 'Debt Owed';
    if (type == 'given') return 'Debt Given';
    return type;
  }

  String _labelForStatus(String status) {
    if (status == 'partially_paid') return 'Partially Paid';
    if (status == 'settled') return 'Settled';
    return 'Active';
  }

  Color _typeColor(String type) {
    return type == 'given' ? _given : _owed;
  }

  Color _typeBackground(String type) {
    return type == 'given' ? _givenSoft : _owedSoft;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'settled':
        return _settled;
      case 'partially_paid':
        return _partial;
      default:
        return _active;
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'settled':
        return _settledSoft;
      case 'partially_paid':
        return _partialSoft;
      default:
        return _activeSoft;
    }
  }

  IconData _debtIcon(String type) {
    return type == 'given'
        ? Icons.call_received_rounded
        : Icons.call_made_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(
      _showHistory ? settledDebtsStreamProvider : activeDebtsStreamProvider,
    );

    return ColoredBox(
      color: _background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _PageHeader(
                title: 'Debts',
                subtitle:
                    'Track who owes you, who you owe, and manage debt history safely.',
                actions: [
                  if (_showHistory)
                    Container(
                      decoration: BoxDecoration(
                        color: _primarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: IconButton(
                        tooltip: 'Search / Filter History',
                        onPressed: _showHistorySearchDialog,
                        icon: const Icon(Icons.search),
                        color: _primary,
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add debt'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Active'),
                    selected: !_showHistory,
                    onSelected: (_) {
                      setState(() {
                        _showHistory = false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('History'),
                    selected: _showHistory,
                    onSelected: (_) {
                      setState(() {
                        _showHistory = true;
                      });
                    },
                  ),
                ],
              ),
              if (_showHistory && _historyFilter.isActive) ...[
                const SizedBox(height: 12),
                _FilterBanner(
                  title: 'History filters applied',
                  onClear: _clearHistoryFilter,
                  textPrimary: _textPrimary,
                  textSecondary: _textSecondary,
                  border: _border,
                  background: _surface,
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: debtsAsync.when(
                  data: (debts) {
                    final displayedDebts =
                        _showHistory ? _applyHistoryFilter(debts) : debts;

                    if (debts.isEmpty) {
                      return _EmptyStateCard(
                        icon: _showHistory
                            ? Icons.history_rounded
                            : Icons.account_balance_wallet_outlined,
                        title: _showHistory
                            ? 'No settled debts yet'
                            : 'No active debts yet',
                        subtitle: _showHistory
                            ? 'Settled debt records will appear here once debts are completed.'
                            : 'Add a debt to start tracking debt balances and repayments.',
                        surface: _surface,
                        border: _border,
                        textPrimary: _textPrimary,
                        textSecondary: _textSecondary,
                      );
                    }

                    if (_showHistory && displayedDebts.isEmpty) {
                      return Column(
                        children: [
                          if (_historyFilter.isActive)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  'Showing 0 of ${debts.length} history debts',
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
                              title: 'No matching history debts',
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
                        if (_showHistory && _historyFilter.isActive)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Showing ${displayedDebts.length} of ${debts.length} history debts',
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
                            itemCount: displayedDebts.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final debt = displayedDebts[index];

                              return _DebtCard(
                                debt: debt,
                                dateText: _formatDate(debt.dateCreated),
                                remainingText:
                                    '${_formatMoney(debt.remainingBalance)} / ${_formatMoney(debt.originalAmount)}',
                                typeLabel: _labelForType(debt.type),
                                statusLabel: _labelForStatus(debt.status),
                                typeColor: _typeColor(debt.type),
                                typeBackground: _typeBackground(debt.type),
                                statusColor: _statusColor(debt.status),
                                statusBackground:
                                    _statusBackground(debt.status),
                                debtIcon: _debtIcon(debt.type),
                                iconColor: _typeColor(debt.type),
                                iconBackground: _typeBackground(debt.type),
                                textPrimary: _textPrimary,
                                textSecondary: _textSecondary,
                                surface: _surface,
                                border: _border,
                                showEdit: !_showHistory,
                                onEdit: !_showHistory
                                    ? () => _showEditDialog(debt)
                                    : null,
                                onDelete: () => _confirmDelete(debt),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
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

class _DebtCard extends StatelessWidget {
  final Debt debt;
  final String dateText;
  final String remainingText;
  final String typeLabel;
  final String statusLabel;
  final Color typeColor;
  final Color typeBackground;
  final Color statusColor;
  final Color statusBackground;
  final IconData debtIcon;
  final Color iconColor;
  final Color iconBackground;
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color border;
  final bool showEdit;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  const _DebtCard({
    required this.debt,
    required this.dateText,
    required this.remainingText,
    required this.typeLabel,
    required this.statusLabel,
    required this.typeColor,
    required this.typeBackground,
    required this.statusColor,
    required this.statusBackground,
    required this.debtIcon,
    required this.iconColor,
    required this.iconBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.border,
    required this.showEdit,
    required this.onEdit,
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
              icon: debtIcon,
              color: iconColor,
              background: iconBackground,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.personName,
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
                        label: typeLabel,
                        color: typeColor,
                        background: typeBackground,
                      ),
                      _InfoChip(
                        label: statusLabel,
                        color: statusColor,
                        background: statusBackground,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Date: $dateText',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Description: ${debt.description}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Remaining Debt: $remainingText',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                if (showEdit && onEdit != null) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: 'Edit debt',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: 'Delete debt',
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