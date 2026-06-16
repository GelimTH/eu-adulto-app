abstract class DebtsTable {
  static const String tableName = 'debts';
  static const String columnId = 'id';
  static const String columnBancoId = 'banco_id';
  static const String columnDescricao = 'descricao';
  static const String columnValorOriginal = 'valor_original';
  static const String columnValorRestante = 'valor_restante';
  static const String columnJuros = 'juros';
  static const String columnParcelas = 'parcelas';
  static const String columnParcelasRestantes = 'parcelas_restantes';
  static const String columnValorParcela = 'valor_parcela';
  static const String columnDataInicio = 'data_inicio';
  static const String columnTipo = 'tipo';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnBancoId INTEGER,
      $columnTipo TEXT NOT NULL DEFAULT 'divida',
      $columnDescricao TEXT NOT NULL,
      $columnValorOriginal REAL NOT NULL,
      $columnValorRestante REAL NOT NULL,
      $columnJuros REAL NOT NULL DEFAULT 0,
      $columnParcelas INTEGER NOT NULL DEFAULT 1,
      $columnParcelasRestantes INTEGER NOT NULL DEFAULT 1,
      $columnValorParcela REAL NOT NULL DEFAULT 0,
      $columnDataInicio TEXT NOT NULL,
      FOREIGN KEY ($columnBancoId) REFERENCES banks(id) ON DELETE SET NULL
    )
  ''';
}
