abstract class UsersTable {
  static const String tableName = 'users';
  static const String columnId = 'id';
  static const String columnNome = 'nome';
  static const String columnSalarioMensal = 'salario_mensal';
  static const String columnPercentualNecessidades = 'percentual_necessidades';
  static const String columnPercentualObjetivos = 'percentual_objetivos';
  static const String columnPercentualReserva = 'percentual_reserva';
  static const String columnDataCriacao = 'data_criacao';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnNome TEXT NOT NULL,
      $columnSalarioMensal REAL NOT NULL DEFAULT 0,
      $columnPercentualNecessidades REAL NOT NULL DEFAULT 60,
      $columnPercentualObjetivos REAL NOT NULL DEFAULT 30,
      $columnPercentualReserva REAL NOT NULL DEFAULT 10,
      $columnDataCriacao TEXT NOT NULL
    )
  ''';
}
