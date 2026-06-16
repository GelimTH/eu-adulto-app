import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/users_table.dart';
import '../models/user_model.dart';

abstract class UserLocalDatasource {
  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<bool> hasUser();
}

class UserLocalDatasourceImpl implements UserLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const UserLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<UserModel?> getUser() async {
    final db = await _databaseHelper.database;
    final result = await db.query(UsersTable.tableName, limit: 1);
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final db = await _databaseHelper.database;
    await db.insert(
      UsersTable.tableName,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateUser(UserModel user) async {
    final db = await _databaseHelper.database;
    await db.update(
      UsersTable.tableName,
      user.toMap(),
      where: '${UsersTable.columnId} = ?',
      whereArgs: [user.id],
    );
  }

  @override
  Future<bool> hasUser() async {
    final db = await _databaseHelper.database;
    final result = await db.query(UsersTable.tableName, limit: 1);
    return result.isNotEmpty;
  }
}
