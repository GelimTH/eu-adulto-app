import '../../domain/entities/debt_entity.dart';
import '../../../../database/tables/debts_table.dart';

class DebtModel extends DebtEntity {
  const DebtModel({
    super.id,
    super.bancoId,
    super.tipo,
    required super.descricao,
    required super.valorOriginal,
    required super.valorRestante,
    required super.juros,
    required super.parcelas,
    required super.parcelasRestantes,
    required super.valorParcela,
    required super.dataInicio,
  });

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map[DebtsTable.columnId] as int?,
      bancoId: map[DebtsTable.columnBancoId] as int?,
      tipo: DebtType.fromString(
          (map[DebtsTable.columnTipo] as String?) ?? 'divida'),
      descricao: map[DebtsTable.columnDescricao] as String,
      valorOriginal: (map[DebtsTable.columnValorOriginal] as num).toDouble(),
      valorRestante: (map[DebtsTable.columnValorRestante] as num).toDouble(),
      juros: (map[DebtsTable.columnJuros] as num).toDouble(),
      parcelas: map[DebtsTable.columnParcelas] as int,
      parcelasRestantes: map[DebtsTable.columnParcelasRestantes] as int,
      valorParcela: (map[DebtsTable.columnValorParcela] as num).toDouble(),
      dataInicio: DateTime.parse(map[DebtsTable.columnDataInicio] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DebtsTable.columnBancoId: bancoId,
      DebtsTable.columnTipo: tipo.name,
      DebtsTable.columnDescricao: descricao,
      DebtsTable.columnValorOriginal: valorOriginal,
      DebtsTable.columnValorRestante: valorRestante,
      DebtsTable.columnJuros: juros,
      DebtsTable.columnParcelas: parcelas,
      DebtsTable.columnParcelasRestantes: parcelasRestantes,
      DebtsTable.columnValorParcela: valorParcela,
      DebtsTable.columnDataInicio: dataInicio.toIso8601String(),
    };
  }

  factory DebtModel.fromEntity(DebtEntity entity) {
    return DebtModel(
      id: entity.id,
      bancoId: entity.bancoId,
      tipo: entity.tipo,
      descricao: entity.descricao,
      valorOriginal: entity.valorOriginal,
      valorRestante: entity.valorRestante,
      juros: entity.juros,
      parcelas: entity.parcelas,
      parcelasRestantes: entity.parcelasRestantes,
      valorParcela: entity.valorParcela,
      dataInicio: entity.dataInicio,
    );
  }
}
