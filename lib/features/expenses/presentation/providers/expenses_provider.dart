import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final selectedCategoryProvider = StateProvider<ExpenseCategory?>((ref) => null);

final expensesProvider = FutureProvider<List<ExpenseEntity>>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  return ref.read(expenseRepositoryProvider).getExpenses(
        startDate: start,
        endDate: end,
      );
});

final expensesTotalProvider = FutureProvider<double>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  return ref.read(expenseRepositoryProvider).getTotalByMonth(month);
});

class ExpensesNotifier extends AsyncNotifier<List<ExpenseEntity>> {
  @override
  Future<List<ExpenseEntity>> build() async {
    final month = ref.watch(selectedMonthProvider);
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return ref.read(expenseRepositoryProvider).getExpenses(
          startDate: start,
          endDate: end,
        );
  }

  Future<void> add(ExpenseEntity expense) async {
    await ref.read(expenseRepositoryProvider).saveExpense(expense);
    ref.invalidateSelf();
    ref.invalidate(expensesTotalProvider);
  }

  Future<void> editItem(ExpenseEntity expense) async {
    await ref.read(expenseRepositoryProvider).updateExpense(expense);
    ref.invalidateSelf();
    ref.invalidate(expensesTotalProvider);
  }

  Future<void> delete(int id) async {
    await ref.read(expenseRepositoryProvider).deleteExpense(id);
    ref.invalidateSelf();
    ref.invalidate(expensesTotalProvider);
  }
}

final expensesNotifierProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<ExpenseEntity>>(
        ExpensesNotifier.new);
