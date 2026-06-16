import '../entities/expense_entity.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseEntity>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    ExpenseCategory? category,
  });
  Future<double> getTotalByMonth(DateTime month);
  Future<int> saveExpense(ExpenseEntity expense);
  Future<void> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);
}
