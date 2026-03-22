export '../../../data/local/db/database_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final dao = ref.watch(transactionsDaoProvider);
  return dao.watchAllTransactions();
});