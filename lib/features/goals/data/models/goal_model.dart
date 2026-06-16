import '../../domain/entities/goal_entity.dart';
import '../../../../database/tables/goals_table.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    super.id,
    required super.nome,
    required super.valorAlvo,
    required super.valorAtual,
    super.prazo,
    required super.dataCriacao,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    final prazoStr = map[GoalsTable.columnPrazo] as String?;
    return GoalModel(
      id: map[GoalsTable.columnId] as int?,
      nome: map[GoalsTable.columnNome] as String,
      valorAlvo: (map[GoalsTable.columnValorAlvo] as num).toDouble(),
      valorAtual: (map[GoalsTable.columnValorAtual] as num).toDouble(),
      prazo: prazoStr != null ? DateTime.parse(prazoStr) : null,
      dataCriacao:
          DateTime.parse(map[GoalsTable.columnDataCriacao] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      GoalsTable.columnNome: nome,
      GoalsTable.columnValorAlvo: valorAlvo,
      GoalsTable.columnValorAtual: valorAtual,
      GoalsTable.columnPrazo: prazo?.toIso8601String(),
      GoalsTable.columnDataCriacao: dataCriacao.toIso8601String(),
    };
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      nome: entity.nome,
      valorAlvo: entity.valorAlvo,
      valorAtual: entity.valorAtual,
      prazo: entity.prazo,
      dataCriacao: entity.dataCriacao,
    );
  }
}
