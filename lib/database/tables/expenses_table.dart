abstract class ExpensesTable {
  static const String tableName = 'expenses';
  static const String columnId = 'id';
  static const String columnValor = 'valor';
  static const String columnCategoria = 'categoria';
  static const String columnClassificacao = 'classificacao';
  static const String columnDescricao = 'descricao';
  static const String columnData = 'data';
  static const String columnBancoId = 'banco_id';
  static const String columnCartaoId = 'cartao_id';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnValor REAL NOT NULL,
      $columnCategoria TEXT NOT NULL,
      $columnClassificacao TEXT NOT NULL DEFAULT 'necessidade',
      $columnDescricao TEXT,
      $columnData TEXT NOT NULL,
      $columnBancoId INTEGER,
      $columnCartaoId INTEGER,
      FOREIGN KEY ($columnBancoId) REFERENCES banks(id) ON DELETE SET NULL,
      FOREIGN KEY ($columnCartaoId) REFERENCES cards(id) ON DELETE SET NULL
    )
  ''';
}
