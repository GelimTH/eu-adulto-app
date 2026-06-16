import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/reserve_table.dart';
import '../models/reserve_model.dart';

abstract class ReserveLocalDatasource {
  Future<ReserveModel?> getReserve();
  Future<void> saveOrUpdateReserve(ReserveModel reserve);
}

class ReserveLocalDatasourceImpl implements ReserveLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const ReserveLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<ReserveModel?> getReserve() async {
    final db = await _databaseHelper.database;
    final result = await db.query(ReserveTable.tableName, limit: 1);
    if (result.isEmpty) return null;
    return ReserveModel.fromMap(result.first);
  }

  @override
  Future<void> saveOrUpdateReserve(ReserveModel reserve) async {
    final db = await _databaseHelper.database;
    final existing = await getReserve();

    if (existing == null) {
      await db.insert(
        ReserveTable.tableName,
        reserve.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.update(
        ReserveTable.tableName,
        reserve.toMap(),
        where: '${ReserveTable.columnId} = ?',
        whereArgs: [existing.id],
      );
    }
  }
}
