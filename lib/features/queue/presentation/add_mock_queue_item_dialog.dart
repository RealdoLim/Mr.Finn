import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/database_providers.dart';

class AddMockQueueItemDialog extends ConsumerStatefulWidget {
  const AddMockQueueItemDialog({super.key});

  @override
  ConsumerState<AddMockQueueItemDialog> createState() =>
      _AddMockQueueItemDialogState();
}

class _AddMockQueueItemDialogState
    extends ConsumerState<AddMockQueueItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final _rawTextController = TextEditingController();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();

  String _direction = 'expense';

  @override
  void dispose() {
    _rawTextController.dispose();
    _sourceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }

    await ref.read(notificationQueueDaoProvider).insertQueueItem(
          rawText: _rawTextController.text.trim(),
          sourceOrDestination: _sourceController.text.trim(),
          detectedAmount: amount,
          detectedDirection: _direction,
          detectedTime: DateTime.now(),
          detectionStatus: 'parsed',
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Mock Queue Item'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width < 500 ? 300 : 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _rawTextController,
                  decoration: const InputDecoration(
                    labelText: 'Raw Notification Text',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Raw text is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sourceController,
                  decoration: const InputDecoration(
                    labelText: 'Source / Destination',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Source / destination is required';
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
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Detected Direction',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'income',
                      child: Text('Income'),
                    ),
                    DropdownMenuItem(
                      value: 'expense',
                      child: Text('Expense'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _direction = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}