import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/prefs/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

class MonthlyBudgetNotifier extends AsyncNotifier<double> {
  @override
  Future<double> build() async {
    return ref.read(settingsServiceProvider).getMonthlyBudget();
  }

  Future<void> setBudget(double value) async {
    state = AsyncValue.data(value);
    await ref.read(settingsServiceProvider).setMonthlyBudget(value);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    final value = await ref.read(settingsServiceProvider).getMonthlyBudget();
    state = AsyncValue.data(value);
  }
}

final monthlyBudgetProvider =
    AsyncNotifierProvider<MonthlyBudgetNotifier, double>(
      MonthlyBudgetNotifier.new,
    );

final currentDateTimeProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();

  while (true) {
    await Future.delayed(const Duration(minutes: 1));
    yield DateTime.now();
  }
});