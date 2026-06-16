abstract class GoalsTable {
  static const String tableName = 'goals';
  static const String columnId = 'id';
  static const String columnNome = 'nome';
  static const String columnValorAlvo = 'valor_alvo';
  static const String columnValorAtual = 'valor_atual';
  static const String columnPrazo = 'prazo';
  static const String columnDataCriacao = 'data_criacao';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnNome TEXT NOT NULL,
      $columnValorAlvo REAL NOT NULL,
      $columnValorAtual REAL NOT NULL DEFAULT 0,
      $columnPrazo TEXT,
      $columnDataCriacao TEXT NOT NULL
    )
  ''';
}
