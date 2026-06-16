import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/installments_table.dart';
import '../models/installment_model.dart';

abstract class InstallmentLocalDatasource {
  Future<List<InstallmentModel>> getInstallments();
  Future<double> getMonthlyInstallmentTotal();
  Future<int> saveInstallment(InstallmentModel installment);
  Future<void> updateInstallment(InstallmentModel installment);
  Future<void> deleteInstallment(int id);
}

class InstallmentLocalDatasourceImpl implements InstallmentLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const InstallmentLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<List<InstallmentModel>> getInstallments() async {
    final db = await _databaseHelper.database;
    final result = await db.query(InstallmentsTable.tableName);
    return result.map((map) => InstallmentModel.fromMap(map)).toList();
  }

  @override
  Future<double> getMonthlyInstallmentTotal() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(${InstallmentsTable.columnValorParcela}) as total FROM ${InstallmentsTable.tableName} '
      'WHERE ${InstallmentsTable.columnParcelaAtual} <= ${InstallmentsTable.columnTotalParcelas}',
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  @override
  Future<int> saveInstallment(InstallmentModel installment) async {
    final db = await _databaseHelper.database;
    return db.insert(
      InstallmentsTable.tableName,
      installment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateInstallment(InstallmentModel installment) async {
    final db = await _databaseHelper.database;
    await db.update(
      InstallmentsTable.tableName,
      installment.toMap(),
      where: '${InstallmentsTable.columnId} = ?',
      whereArgs: [installment.id],
    );
  }

  @override
  Future<void> deleteInstallment(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      InstallmentsTable.tableName,
      where: '${InstallmentsTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
