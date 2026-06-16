import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDatasource _datasource;

  const ExpenseRepositoryImpl(this._datasource);

  @override
  Future<List<ExpenseEntity>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    ExpenseCategory? category,
  }) {
    return _datasource.getExpenses(
      startDate: startDate,
      endDate: endDate,
      category: category,
    );
  }

  @override
  Future<double> getTotalByMonth(DateTime month) =>
      _datasource.getTotalByMonth(month);

  @override
  Future<int> saveExpense(ExpenseEntity expense) =>
      _datasource.saveExpense(ExpenseModel.fromEntity(expense));

  @override
  Future<void> updateExpense(ExpenseEntity expense) =>
      _datasource.updateExpense(ExpenseModel.fromEntity(expense));

  @override
  Future<void> deleteExpense(int id) => _datasource.deleteExpense(id);
}
