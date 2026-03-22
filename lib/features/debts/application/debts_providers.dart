import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/database_providers.dart';

final activeDebtsStreamProvider = StreamProvider<List<Debt>>((ref) {
  final dao = ref.watch(debtsDaoProvider);
  return dao.watchActiveDebts();
});

final settledDebtsStreamProvider = StreamProvider<List<Debt>>((ref) {
  final dao = ref.watch(debtsDaoProvider);
  return dao.watchSettledDebts();
});

final selectableDebtsStreamProvider =
    StreamProvider.family<List<Debt>, String>((ref, direction) {
  final dao = ref.watch(debtsDaoProvider);
  return dao.watchSelectableDebts(direction);
});