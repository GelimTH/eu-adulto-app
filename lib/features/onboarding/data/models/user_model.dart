import '../../domain/entities/user_entity.dart';
import '../../../../database/tables/users_table.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.nome,
    required super.salarioMensal,
    super.percentualNecessidades,
    super.percentualObjetivos,
    super.percentualReserva,
    required super.dataCriacao,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map[UsersTable.columnId] as int?,
      nome: map[UsersTable.columnNome] as String,
      salarioMensal: (map[UsersTable.columnSalarioMensal] as num).toDouble(),
      percentualNecessidades:
          (map[UsersTable.columnPercentualNecessidades] as num).toDouble(),
      percentualObjetivos:
          (map[UsersTable.columnPercentualObjetivos] as num).toDouble(),
      percentualReserva:
          (map[UsersTable.columnPercentualReserva] as num).toDouble(),
      dataCriacao: DateTime.parse(map[UsersTable.columnDataCriacao] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      UsersTable.columnNome: nome,
      UsersTable.columnSalarioMensal: salarioMensal,
      UsersTable.columnPercentualNecessidades: percentualNecessidades,
      UsersTable.columnPercentualObjetivos: percentualObjetivos,
      UsersTable.columnPercentualReserva: percentualReserva,
      UsersTable.columnDataCriacao: dataCriacao.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      nome: entity.nome,
      salarioMensal: entity.salarioMensal,
      percentualNecessidades: entity.percentualNecessidades,
      percentualObjetivos: entity.percentualObjetivos,
      percentualReserva: entity.percentualReserva,
      dataCriacao: entity.dataCriacao,
    );
  }
}
