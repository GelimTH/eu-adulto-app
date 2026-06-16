import '../../domain/entities/subscription_entity.dart';
import '../../../../database/tables/subscriptions_table.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    super.id,
    required super.nome,
    required super.valor,
    required super.periodicidade,
    required super.diaVencimento,
    required super.categoria,
    required super.ativa,
    required super.dataInicio,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map[SubscriptionsTable.columnId] as int?,
      nome: map[SubscriptionsTable.columnNome] as String,
      valor: (map[SubscriptionsTable.columnValor] as num).toDouble(),
      periodicidade: SubscriptionPeriodicity.fromString(
          map[SubscriptionsTable.columnPeriodicidade] as String),
      diaVencimento: map[SubscriptionsTable.columnDiaVencimento] as int,
      categoria: SubscriptionCategory.fromString(
          map[SubscriptionsTable.columnCategoria] as String),
      ativa: (map[SubscriptionsTable.columnAtiva] as int) == 1,
      dataInicio:
          DateTime.parse(map[SubscriptionsTable.columnDataInicio] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      SubscriptionsTable.columnNome: nome,
      SubscriptionsTable.columnValor: valor,
      SubscriptionsTable.columnPeriodicidade: periodicidade.name,
      SubscriptionsTable.columnDiaVencimento: diaVencimento,
      SubscriptionsTable.columnCategoria: categoria.name,
      SubscriptionsTable.columnAtiva: ativa ? 1 : 0,
      SubscriptionsTable.columnDataInicio: dataInicio.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromEntity(SubscriptionEntity entity) {
    return SubscriptionModel(
      id: entity.id,
      nome: entity.nome,
      valor: entity.valor,
      periodicidade: entity.periodicidade,
      diaVencimento: entity.diaVencimento,
      categoria: entity.categoria,
      ativa: entity.ativa,
      dataInicio: entity.dataInicio,
    );
  }
}
