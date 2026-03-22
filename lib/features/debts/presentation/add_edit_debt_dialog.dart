import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';

class AddEditDebtDialog extends ConsumerStatefulWidget {
  final Debt? debt;

  const AddEditDebtDialog({super.key, this.debt});

  @override
  ConsumerState<AddEditDebtDialog> createState() => _AddEditDebtDialogState();
}

class _AddEditDebtDialogState extends ConsumerState<AddEditDebtDialog> {
  static const Color _primary = Color(0xFF0F766E);
  static const Color _primarySoft = Color(0xFFCCFBF1);
  static const Color _surface = Colors.white;
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _border = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _personNameController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;

  late DateTime _selectedDate;
  late String _type;

  bool _isSubmitting = false;

  bool get _isEditing => widget.debt != null;

  @override
  void initState() {
    super.initState();

    _personNameController = TextEditingController(
      text: widget.debt?.personName ?? '',
    );
    _amountController = TextEditingController(
      text: widget.debt?.originalAmount.toStringAsFixed(2) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.debt?.description ?? '',
    );

    _selectedDate = widget.debt?.dateCreated ?? DateTime.now();
    _type = widget.debt?.type ?? 'owed';
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
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

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
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

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final db = ref.read(appDatabaseProvider);

    try {
      if (_isEditing) {
        final currentDebt = widget.debt!;
        final amountAlreadyPaid =
            currentDebt.originalAmount - currentDebt.remainingBalance;

        if (amount < amountAlreadyPaid) {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Original amount cannot be lower than the amount already paid',
              ),
            ),
          );
          return;
        }

        final rawNewRemaining = amount - amountAlreadyPaid;
        final isSettled = rawNewRemaining.abs() < 0.0001;
        final newRemaining = isSettled ? 0.0 : rawNewRemaining;

        final String newStatus;
        if (isSettled) {
          newStatus = 'settled';
        } else if (amountAlreadyPaid > 0) {
          newStatus = 'partially_paid';
        } else {
          newStatus = 'active';
        }

        await db.transaction(() async {
          await db.debtsDao.updateDebt(
            id: currentDebt.id,
            personName: _personNameController.text.trim(),
            originalAmount: amount,
            remainingBalance: newRemaining,
            description: _descriptionController.text.trim(),
            dateCreated: currentDebt.dateCreated,
            type: currentDebt.type,
            status: newStatus,
          );

          if (currentDebt.type == 'given') {
            await db.transactionsDao.updateDebtGivenOutflowTransaction(
              debtId: currentDebt.id,
              amount: amount,
              date: currentDebt.dateCreated,
              description: 'Debt Given to ${_personNameController.text.trim()}',
            );
          }
        });
      } else {
        await db.transaction(() async {
          final debtId = await db.debtsDao.insertDebt(
            personName: _personNameController.text.trim(),
            originalAmount: amount,
            remainingBalance: amount,
            description: _descriptionController.text.trim(),
            dateCreated: _selectedDate,
            type: _type,
            status: 'active',
          );

          if (_type == 'given') {
            await db.transactionsDao.insertTransaction(
              description: 'Debt Given to ${_personNameController.text.trim()}',
              amount: amount,
              date: _selectedDate,
              direction: 'expense',
              source: 'manual',
              transactionKind: 'debt_given_outflow',
              category: null,
              spendingType: null,
              linkedDebtId: debtId,
            );
          }
        });
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save debt: $error')),
        );
      }
    }
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
            child: Icon(
              _isEditing ? Icons.edit_note_rounded : Icons.account_balance_wallet_outlined,
              color: _primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Debt' : 'Add Debt',
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
                  _isEditing
                      ? 'Update debt details while keeping existing debt logic intact.'
                      : 'Create a new debt record and optionally generate the related debt-given outflow.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _personNameController,
                  decoration: _fieldDecoration('Person Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Person name is required';
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
                  decoration: _fieldDecoration('Amount'),
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
                TextFormField(
                  controller: _descriptionController,
                  decoration: _fieldDecoration('Description'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                if (_isEditing)
                  InputDecorator(
                    decoration: _fieldDecoration('Debt Type'),
                    child: Text(_type == 'owed' ? 'Debt Owed' : 'Debt Given'),
                  )
                else
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _type,
                    decoration: _fieldDecoration('Debt Type'),
                    items: const [
                      DropdownMenuItem(value: 'owed', child: Text('Debt Owed')),
                      DropdownMenuItem(value: 'given', child: Text('Debt Given')),
                    ],
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _type = value;
                            });
                          },
                  ),
                const SizedBox(height: 12),
                if (_isEditing)
                  InputDecorator(
                    decoration: _fieldDecoration('Date'),
                    child: Text(_formatDate(_selectedDate)),
                  )
                else
                  InkWell(
                    onTap: _isSubmitting ? null : _pickDate,
                    borderRadius: BorderRadius.circular(14),
                    child: InputDecorator(
                      decoration: _fieldDecoration('Date'),
                      child: Text(_formatDate(_selectedDate)),
                    ),
                  ),
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
              : Text(_isEditing ? 'Update' : 'Save'),
        ),
      ],
    );
  }
}