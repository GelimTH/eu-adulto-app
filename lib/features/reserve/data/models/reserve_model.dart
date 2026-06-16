import '../../domain/entities/reserve_entity.dart';
import '../../../../database/tables/reserve_table.dart';

class ReserveModel extends ReserveEntity {
  const ReserveModel({
    super.id,
    required super.valorAtual,
    required super.dataAtualizacao,
  });

  factory ReserveModel.fromMap(Map<String, dynamic> map) {
    return ReserveModel(
      id: map[ReserveTable.columnId] as int?,
      valorAtual: (map[ReserveTable.columnValorAtual] as num).toDouble(),
      dataAtualizacao:
          DateTime.parse(map[ReserveTable.columnDataAtualizacao] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ReserveTable.columnValorAtual: valorAtual,
      ReserveTable.columnDataAtualizacao: dataAtualizacao.toIso8601String(),
    };
  }

  factory ReserveModel.fromEntity(ReserveEntity entity) {
    return ReserveModel(
      id: entity.id,
      valorAtual: entity.valorAtual,
      dataAtualizacao: entity.dataAtualizacao,
    );
  }
}
