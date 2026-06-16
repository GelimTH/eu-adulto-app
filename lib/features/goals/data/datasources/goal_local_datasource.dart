import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/goals_table.dart';
import '../models/goal_model.dart';

abstract class GoalLocalDatasource {
  Future<List<GoalModel>> getGoals();
  Future<int> saveGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(int id);
}

class GoalLocalDatasourceImpl implements GoalLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const GoalLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<List<GoalModel>> getGoals() async {
    final db = await _databaseHelper.database;
    final result = await db.query(GoalsTable.tableName);
    return result.map((map) => GoalModel.fromMap(map)).toList();
  }

  @override
  Future<int> saveGoal(GoalModel goal) async {
    final db = await _databaseHelper.database;
    return db.insert(
      GoalsTable.tableName,
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    final db = await _databaseHelper.database;
    await db.update(
      GoalsTable.tableName,
      goal.toMap(),
      where: '${GoalsTable.columnId} = ?',
      whereArgs: [goal.id],
    );
  }

  @override
  Future<void> deleteGoal(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      GoalsTable.tableName,
      where: '${GoalsTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
