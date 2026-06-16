import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_local_datasource.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDatasource _datasource;

  const GoalRepositoryImpl(this._datasource);

  @override
  Future<List<GoalEntity>> getGoals() => _datasource.getGoals();

  @override
  Future<int> saveGoal(GoalEntity goal) =>
      _datasource.saveGoal(GoalModel.fromEntity(goal));

  @override
  Future<void> updateGoal(GoalEntity goal) =>
      _datasource.updateGoal(GoalModel.fromEntity(goal));

  @override
  Future<void> deleteGoal(int id) => _datasource.deleteGoal(id);
}
