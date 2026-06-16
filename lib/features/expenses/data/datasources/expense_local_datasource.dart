import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/expenses_table.dart';
import '../../domain/entities/expense_entity.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDatasource {
  Future<List<ExpenseModel>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    ExpenseCategory? category,
  });
  Future<double> getTotalByMonth(DateTime month);
  Future<int> saveExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

class ExpenseLocalDatasourceImpl implements ExpenseLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const ExpenseLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<List<ExpenseModel>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    ExpenseCategory? category,
  }) async {
    final db = await _databaseHelper.database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (startDate != null) {
      conditions.add('${ExpensesTable.columnData} >= ?');
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      conditions.add('${ExpensesTable.columnData} <= ?');
      args.add(endDate.toIso8601String());
    }
    if (category != null) {
      conditions.add('${ExpensesTable.columnCategoria} = ?');
      args.add(category.name);
    }

    final result = await db.query(
      ExpensesTable.tableName,
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: '${ExpensesTable.columnData} DESC',
    );
    return result.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  @override
  Future<double> getTotalByMonth(DateTime month) async {
    final db = await _databaseHelper.database;
    final start = DateTime(month.year, month.month, 1).toIso8601String();
    final end =
        DateTime(month.year, month.month + 1, 0, 23, 59, 59).toIso8601String();

    final result = await db.rawQuery(
      'SELECT SUM(${ExpensesTable.columnValor}) as total FROM ${ExpensesTable.tableName} '
      'WHERE ${ExpensesTable.columnData} >= ? AND ${ExpensesTable.columnData} <= ?',
      [start, end],
    );

    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  @override
  Future<int> saveExpense(ExpenseModel expense) async {
    final db = await _databaseHelper.database;
    return db.insert(
      ExpensesTable.tableName,
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await _databaseHelper.database;
    await db.update(
      ExpensesTable.tableName,
      expense.toMap(),
      where: '${ExpensesTable.columnId} = ?',
      whereArgs: [expense.id],
    );
  }

  @override
  Future<void> deleteExpense(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      ExpensesTable.tableName,
      where: '${ExpensesTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
