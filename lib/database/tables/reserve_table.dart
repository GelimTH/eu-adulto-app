abstract class ReserveTable {
  static const String tableName = 'reserve';
  static const String columnId = 'id';
  static const String columnValorAtual = 'valor_atual';
  static const String columnDataAtualizacao = 'data_atualizacao';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnValorAtual REAL NOT NULL DEFAULT 0,
      $columnDataAtualizacao TEXT NOT NULL
    )
  ''';
}
