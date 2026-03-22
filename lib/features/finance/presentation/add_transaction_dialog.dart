import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';
import '../../debts/application/debts_providers.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  const AddTransactionDialog({super.key});

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primarySoft = Color(0xFFCCFBF1);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _direction = 'income';
  String? _category;
  String? _spendingType;

  bool _isDebtRelated = false;
  Debt? _selectedDebt;
  bool _isSubmitting = false;

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

  bool get _isExpense => _direction == 'expense';

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_isExpense && _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_isExpense && _spendingType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a spending type')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    if (_isDebtRelated && _selectedDebt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a debt')),
      );
      return;
    }

    if (_isDebtRelated && amount > _selectedDebt!.remainingBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction amount cannot exceed the remaining debt balance',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final transactionKind = _isDebtRelated
        ? (_direction == 'income'
              ? 'debt_given_repayment'
              : 'debt_owed_repayment')
        : (_direction == 'income' ? 'normal_income' : 'normal_expense');

    final db = ref.read(appDatabaseProvider);

    try {
      await db.transaction(() async {
        await db.transactionsDao.insertTransaction(
          description: _descriptionController.text.trim(),
          amount: amount,
          date: _selectedDate,
          direction: _direction,
          source: 'manual',
          transactionKind: transactionKind,
          category: _isExpense ? _category : null,
          spendingType: _isExpense ? _spendingType : null,
          linkedDebtId: _isDebtRelated ? _selectedDebt!.id : null,
        );

        if (_isDebtRelated) {
          final debt = _selectedDebt!;
          final rawRemaining = debt.remainingBalance - amount;
          final isSettled = rawRemaining.abs() < 0.0001;
          final newRemaining = isSettled ? 0.0 : rawRemaining;
          final newStatus = isSettled ? 'settled' : 'partially_paid';

          await db.debtsDao.updateDebtBalanceAndStatus(
            id: debt.id,
            remainingBalance: newRemaining,
            status: newStatus,
          );
        }
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: $error')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _formatMoney(double amount) {
    return 'RM ${amount.toStringAsFixed(2)}';
  }

  Widget _buildDebtLabel(Debt debt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(debt.personName, overflow: TextOverflow.ellipsis),
        Text(
          debt.description,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectableDebtsAsync = ref.watch(
      selectableDebtsStreamProvider(_direction),
    );

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
              Icons.receipt_long_outlined,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add Transaction',
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create a manual transaction and optionally link it to a debt.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _primary, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _primary, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Amount is required';
                    }
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null) {
                      return 'Enter a valid number';
                    }
                    if (parsed <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _direction,
                  decoration: InputDecoration(
                    labelText: 'Direction',
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _primary, width: 1.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'income', child: Text('Income')),
                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _direction = value;
                            _selectedDebt = null;

                            if (!_isExpense) {
                              _category = null;
                              _spendingType = null;
                            }
                          });
                        },
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isSubmitting ? null : _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(_formatDate(_selectedDate)),
                  ),
                ),
                if (_isExpense) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _category,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _primary, width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _category = value;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _spendingType,
                    decoration: InputDecoration(
                      labelText: 'Spending Type',
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: _primary, width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: _spendingTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _spendingType = value;
                            });
                          },
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _primarySoft.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
                  ),
                  child: CheckboxListTile(
                    value: _isDebtRelated,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(
                      'This transaction is debt-related',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _isDebtRelated = value ?? false;

                              if (_direction == 'income' && _isDebtRelated) {
                                _category = null;
                                _spendingType = null;
                              }

                              if (!_isDebtRelated) {
                                _selectedDebt = null;
                              }
                            });
                          },
                  ),
                ),
                if (_isDebtRelated) ...[
                  const SizedBox(height: 10),
                  selectableDebtsAsync.when(
                    data: (debts) {
                      if (debts.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _primarySoft.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _border),
                          ),
                          child: Text(
                            _direction == 'income'
                                ? 'No Debt Given records available to collect from.'
                                : 'No Debt Owed records available to repay.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _textSecondary,
                                ),
                          ),
                        );
                      }

                      if (_selectedDebt != null &&
                          !debts.any((d) => d.id == _selectedDebt!.id)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _selectedDebt = null;
                            });
                          }
                        });
                      }

                      return Column(
                        children: [
                          DropdownButtonFormField<Debt>(
                            isExpanded: true,
                            value: _selectedDebt,
                            decoration: InputDecoration(
                              labelText: 'Select Debt',
                              border: const OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: _border),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: _primary,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            selectedItemBuilder: (context) {
                              return debts
                                  .map(
                                    (debt) => Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        debt.personName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList();
                            },
                            items: debts
                                .map(
                                  (debt) => DropdownMenuItem(
                                    value: debt,
                                    child: _buildDebtLabel(debt),
                                  ),
                                )
                                .toList(),
                            onChanged: _isSubmitting
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedDebt = value;
                                    });
                                  },
                          ),
                          if (_selectedDebt != null) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _primarySoft.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Remaining Debt: ${_formatMoney(_selectedDebt!.remainingBalance)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: _textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) =>
                        Text('Error loading debts: $error'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}