import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/debts_table.dart';
import '../models/debt_model.dart';

abstract class DebtLocalDatasource {
  Future<List<DebtModel>> getDebts();
  Future<double> getTotalDebt();
  Future<double> getMonthlyDebtPayment();
  Future<int> saveDebt(DebtModel debt);
  Future<void> updateDebt(DebtModel debt);
  Future<void> deleteDebt(int id);
}

class DebtLocalDatasourceImpl implements DebtLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const DebtLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<List<DebtModel>> getDebts() async {
    final db = await _databaseHelper.database;
    final result = await db.query(DebtsTable.tableName);
    return result.map((map) => DebtModel.fromMap(map)).toList();
  }

  @override
  Future<double> getTotalDebt() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${DebtsTable.columnValorRestante}) as total FROM ${DebtsTable.tableName}',
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  @override
  Future<double> getMonthlyDebtPayment() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${DebtsTable.columnValorParcela}) as total FROM ${DebtsTable.tableName} '
      'WHERE ${DebtsTable.columnParcelasRestantes} > 0',
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  @override
  Future<int> saveDebt(DebtModel debt) async {
    final db = await _databaseHelper.database;
    return db.insert(
      DebtsTable.tableName,
      debt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    final db = await _databaseHelper.database;
    await db.update(
      DebtsTable.tableName,
      debt.toMap(),
      where: '${DebtsTable.columnId} = ?',
      whereArgs: [debt.id],
    );
  }

  @override
  Future<void> deleteDebt(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      DebtsTable.tableName,
      where: '${DebtsTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
