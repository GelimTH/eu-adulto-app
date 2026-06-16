abstract class CardsTable {
  static const String tableName = 'cards';
  static const String columnId = 'id';
  static const String columnBancoId = 'banco_id';
  static const String columnNome = 'nome';
  static const String columnLimiteTotal = 'limite_total';
  static const String columnFechamento = 'fechamento';
  static const String columnVencimento = 'vencimento';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnBancoId INTEGER,
      $columnNome TEXT NOT NULL,
      $columnLimiteTotal REAL NOT NULL DEFAULT 0,
      $columnFechamento INTEGER NOT NULL DEFAULT 1,
      $columnVencimento INTEGER NOT NULL DEFAULT 10,
      FOREIGN KEY ($columnBancoId) REFERENCES banks(id) ON DELETE SET NULL
    )
  ''';
}
