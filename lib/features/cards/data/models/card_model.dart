import '../../domain/entities/card_entity.dart';
import '../../../../database/tables/cards_table.dart';

class CardModel extends CardEntity {
  const CardModel({
    super.id,
    super.bancoId,
    required super.nome,
    required super.limiteTotal,
    required super.fechamento,
    required super.vencimento,
  });

  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map[CardsTable.columnId] as int?,
      bancoId: map[CardsTable.columnBancoId] as int?,
      nome: map[CardsTable.columnNome] as String,
      limiteTotal: (map[CardsTable.columnLimiteTotal] as num).toDouble(),
      fechamento: map[CardsTable.columnFechamento] as int,
      vencimento: map[CardsTable.columnVencimento] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      CardsTable.columnBancoId: bancoId,
      CardsTable.columnNome: nome,
      CardsTable.columnLimiteTotal: limiteTotal,
      CardsTable.columnFechamento: fechamento,
      CardsTable.columnVencimento: vencimento,
    };
  }

  factory CardModel.fromEntity(CardEntity entity) {
    return CardModel(
      id: entity.id,
      bancoId: entity.bancoId,
      nome: entity.nome,
      limiteTotal: entity.limiteTotal,
      fechamento: entity.fechamento,
      vencimento: entity.vencimento,
    );
  }
}
