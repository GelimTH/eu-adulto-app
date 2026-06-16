import '../../domain/entities/bank_entity.dart';
import '../../../../database/tables/banks_table.dart';

class BankModel extends BankEntity {
  const BankModel({super.id, required super.nome});

  factory BankModel.fromMap(Map<String, dynamic> map) {
    return BankModel(
      id: map[BanksTable.columnId] as int?,
      nome: map[BanksTable.columnNome] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {BanksTable.columnNome: nome};
  }

  factory BankModel.fromEntity(BankEntity entity) {
    return BankModel(id: entity.id, nome: entity.nome);
  }
}
