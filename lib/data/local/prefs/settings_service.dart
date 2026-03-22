import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _monthlyBudgetKey = 'monthly_budget';

  Future<double> getMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_monthlyBudgetKey) ?? 0;
  }

  Future<void> setMonthlyBudget(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_monthlyBudgetKey, value);
  }
}