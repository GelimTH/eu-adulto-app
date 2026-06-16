import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/goal_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final goalsProvider = FutureProvider<List<GoalEntity>>((ref) async {
  return ref.read(goalRepositoryProvider).getGoals();
});

class GoalsNotifier extends AsyncNotifier<List<GoalEntity>> {
  @override
  Future<List<GoalEntity>> build() async {
    return ref.read(goalRepositoryProvider).getGoals();
  }

  Future<void> add(GoalEntity goal) async {
    await ref.read(goalRepositoryProvider).saveGoal(goal);
    ref.invalidateSelf();
  }

  Future<void> editItem(GoalEntity goal) async {
    await ref.read(goalRepositoryProvider).updateGoal(goal);
    ref.invalidateSelf();
  }

  Future<void> addToGoal(GoalEntity goal, double amount) async {
    final goalUpdated = goal.copyWith(valorAtual: goal.valorAtual + amount);
    await ref.read(goalRepositoryProvider).updateGoal(goalUpdated);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(goalRepositoryProvider).deleteGoal(id);
    ref.invalidateSelf();
  }
}

final goalsNotifierProvider =
    AsyncNotifierProvider<GoalsNotifier, List<GoalEntity>>(GoalsNotifier.new);
