abstract class SubscriptionsTable {
  static const String tableName = 'subscriptions';
  static const String columnId = 'id';
  static const String columnNome = 'nome';
  static const String columnValor = 'valor';
  static const String columnPeriodicidade = 'periodicidade';
  static const String columnDiaVencimento = 'dia_vencimento';
  static const String columnCategoria = 'categoria';
  static const String columnAtiva = 'ativa';
  static const String columnDataInicio = 'data_inicio';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnNome TEXT NOT NULL,
      $columnValor REAL NOT NULL,
      $columnPeriodicidade TEXT NOT NULL DEFAULT 'mensal',
      $columnDiaVencimento INTEGER NOT NULL DEFAULT 1,
      $columnCategoria TEXT NOT NULL DEFAULT 'outros',
      $columnAtiva INTEGER NOT NULL DEFAULT 1,
      $columnDataInicio TEXT NOT NULL
    )
  ''';
}
