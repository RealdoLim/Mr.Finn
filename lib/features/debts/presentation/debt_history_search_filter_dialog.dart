import 'package:flutter/material.dart';

import 'debt_history_search_filter.dart';

class DebtHistorySearchFilterDialog extends StatefulWidget {
  final DebtHistorySearchFilter initialFilter;

  const DebtHistorySearchFilterDialog({
    super.key,
    required this.initialFilter,
  });

  @override
  State<DebtHistorySearchFilterDialog> createState() =>
      _DebtHistorySearchFilterDialogState();
}

class _DebtHistorySearchFilterDialogState
    extends State<DebtHistorySearchFilterDialog> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primarySoft = Color(0xFFCCFBF1);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  late final TextEditingController _searchController;

  late String _debtType;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.initialFilter.searchText,
    );
    _debtType = widget.initialFilter.debtType;
    _fromDate = widget.initialFilter.fromDate;
    _toDate = widget.initialFilter.toDate;
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
      _debtType = 'all';
      _fromDate = null;
      _toDate = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      DebtHistorySearchFilter(
        searchText: _searchController.text.trim(),
        debtType: _debtType,
        fromDate: _fromDate,
        toDate: _toDate,
      ),
    );
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
              'Search Debt History',
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
                'Search settled debt records by person, description, type, or date range.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: _fieldDecoration('Search person or description')
                    .copyWith(
                  hintText: 'e.g. gilbert',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _debtType,
                decoration: _fieldDecoration('Debt Type'),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'owed', child: Text('Debt Owed')),
                  DropdownMenuItem(value: 'given', child: Text('Debt Given')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _debtType = value;
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