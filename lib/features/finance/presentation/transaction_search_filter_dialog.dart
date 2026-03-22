import 'package:flutter/material.dart';

import 'transaction_search_filter.dart';

class TransactionSearchFilterDialog extends StatefulWidget {
  final TransactionSearchFilter initialFilter;

  const TransactionSearchFilterDialog({
    super.key,
    required this.initialFilter,
  });

  @override
  State<TransactionSearchFilterDialog> createState() =>
      _TransactionSearchFilterDialogState();
}

class _TransactionSearchFilterDialogState
    extends State<TransactionSearchFilterDialog> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primarySoft = Color(0xFFCCFBF1);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  late final TextEditingController _searchController;

  late String _direction;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _category;
  String? _spendingType;

  final List<String> _categories = const [
    'Food',
    'Entertainment',
    'Transportation',
    'Shopping',
    'Education',
    'Health',
    'Gifts and Donations',
    'Electricity and Water Bills',
  ];

  final List<String> _spendingTypes = const ['Essential', 'Enjoyment'];

  bool get _isExpenseDirection => _direction == 'expense';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.initialFilter.searchText,
    );
    _direction = widget.initialFilter.direction;
    _fromDate = widget.initialFilter.fromDate;
    _toDate = widget.initialFilter.toDate;
    _category = widget.initialFilter.category;
    _spendingType = widget.initialFilter.spendingType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _border),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _primary, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select date';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _searchController.clear();
      _direction = 'all';
      _fromDate = null;
      _toDate = null;
      _category = null;
      _spendingType = null;
    });
  }

  void _apply() {
    final filter = TransactionSearchFilter(
      searchText: _searchController.text.trim(),
      direction: _direction,
      fromDate: _fromDate,
      toDate: _toDate,
      category: _isExpenseDirection ? _category : null,
      spendingType: _isExpenseDirection ? _spendingType : null,
    );

    Navigator.of(context).pop(filter);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              color: _primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width < 500 ? 320 : 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Search by description and optionally narrow results with filters.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: _fieldDecoration('Search description').copyWith(
                  hintText: 'e.g. salary',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _direction,
                decoration: _fieldDecoration('Direction'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'income', child: Text('Income')),
                  DropdownMenuItem(value: 'expense', child: Text('Expense')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _direction = value;
                    if (_direction != 'expense') {
                      _category = null;
                      _spendingType = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickFromDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text('From: ${_formatDate(_fromDate)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickToDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text('To: ${_formatDate(_toDate)}'),
                    ),
                  ),
                ],
              ),
              if (_fromDate != null || _toDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _fromDate = null;
                          _toDate = null;
                        });
                      },
                      child: const Text('Clear dates'),
                    ),
                  ],
                ),
              ],
              if (_isExpenseDirection) ...[
                const SizedBox(height: 4),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  value: _category,
                  decoration: _fieldDecoration('Category'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ..._categories.map(
                      (category) => DropdownMenuItem<String?>(
                        value: category,
                        child: Text(category),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  isExpanded: true,
                  value: _spendingType,
                  decoration: _fieldDecoration('Spending Type'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All'),
                    ),
                    ..._spendingTypes.map(
                      (type) => DropdownMenuItem<String?>(
                        value: type,
                        child: Text(type),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _spendingType = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _clearAll,
          child: const Text('Clear'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _apply,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}