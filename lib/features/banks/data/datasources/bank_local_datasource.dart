import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/banks_table.dart';
import '../models/bank_model.dart';

abstract class BankLocalDatasource {
  Future<List<BankModel>> getBanks();
  Future<BankModel?> getBankById(int id);
  Future<int> saveBank(BankModel bank);
  Future<void> updateBank(BankModel bank);
  Future<void> deleteBank(int id);
}

class BankLocalDatasourceImpl implements BankLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const BankLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<List<BankModel>> getBanks() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      BanksTable.tableName,
      orderBy: '${BanksTable.columnNome} ASC',
    );
    return result.map((map) => BankModel.fromMap(map)).toList();
  }

  @override
  Future<BankModel?> getBankById(int id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      BanksTable.tableName,
      where: '${BanksTable.columnId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return BankModel.fromMap(result.first);
  }

  @override
  Future<int> saveBank(BankModel bank) async {
    final db = await _databaseHelper.database;
    return db.insert(
      BanksTable.tableName,
      bank.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateBank(BankModel bank) async {
    final db = await _databaseHelper.database;
    await db.update(
      BanksTable.tableName,
      bank.toMap(),
      where: '${BanksTable.columnId} = ?',
      whereArgs: [bank.id],
    );
  }

  @override
  Future<void> deleteBank(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      BanksTable.tableName,
      where: '${BanksTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
