abstract class InstallmentsTable {
  static const String tableName = 'installments';
  static const String columnId = 'id';
  static const String columnDescricao = 'descricao';
  static const String columnValorTotal = 'valor_total';
  static const String columnValorParcela = 'valor_parcela';
  static const String columnParcelaAtual = 'parcela_atual';
  static const String columnTotalParcelas = 'total_parcelas';
  static const String columnBancoId = 'banco_id';
  static const String columnCartaoId = 'cartao_id';
  static const String columnDataInicio = 'data_inicio';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnDescricao TEXT NOT NULL,
      $columnValorTotal REAL NOT NULL,
      $columnValorParcela REAL NOT NULL,
      $columnParcelaAtual INTEGER NOT NULL DEFAULT 1,
      $columnTotalParcelas INTEGER NOT NULL,
      $columnBancoId INTEGER,
      $columnCartaoId INTEGER,
      $columnDataInicio TEXT NOT NULL,
      FOREIGN KEY ($columnBancoId) REFERENCES banks(id) ON DELETE SET NULL,
      FOREIGN KEY ($columnCartaoId) REFERENCES cards(id) ON DELETE SET NULL
    )
  ''';
}
