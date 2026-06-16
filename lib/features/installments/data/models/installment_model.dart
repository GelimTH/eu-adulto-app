import '../../domain/entities/installment_entity.dart';
import '../../../../database/tables/installments_table.dart';

class InstallmentModel extends InstallmentEntity {
  const InstallmentModel({
    super.id,
    required super.descricao,
    required super.valorTotal,
    required super.valorParcela,
    required super.parcelaAtual,
    required super.totalParcelas,
    super.bancoId,
    super.cartaoId,
    required super.dataInicio,
  });

  factory InstallmentModel.fromMap(Map<String, dynamic> map) {
    return InstallmentModel(
      id: map[InstallmentsTable.columnId] as int?,
      descricao: map[InstallmentsTable.columnDescricao] as String,
      valorTotal: (map[InstallmentsTable.columnValorTotal] as num).toDouble(),
      valorParcela:
          (map[InstallmentsTable.columnValorParcela] as num).toDouble(),
      parcelaAtual: map[InstallmentsTable.columnParcelaAtual] as int,
      totalParcelas: map[InstallmentsTable.columnTotalParcelas] as int,
      bancoId: map[InstallmentsTable.columnBancoId] as int?,
      cartaoId: map[InstallmentsTable.columnCartaoId] as int?,
      dataInicio:
          DateTime.parse(map[InstallmentsTable.columnDataInicio] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      InstallmentsTable.columnDescricao: descricao,
      InstallmentsTable.columnValorTotal: valorTotal,
      InstallmentsTable.columnValorParcela: valorParcela,
      InstallmentsTable.columnParcelaAtual: parcelaAtual,
      InstallmentsTable.columnTotalParcelas: totalParcelas,
      InstallmentsTable.columnBancoId: bancoId,
      InstallmentsTable.columnCartaoId: cartaoId,
      InstallmentsTable.columnDataInicio: dataInicio.toIso8601String(),
    };
  }

  factory InstallmentModel.fromEntity(InstallmentEntity entity) {
    return InstallmentModel(
      id: entity.id,
      descricao: entity.descricao,
      valorTotal: entity.valorTotal,
      valorParcela: entity.valorParcela,
      parcelaAtual: entity.parcelaAtual,
      totalParcelas: entity.totalParcelas,
      bancoId: entity.bancoId,
      cartaoId: entity.cartaoId,
      dataInicio: entity.dataInicio,
    );
  }
}
