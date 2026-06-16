abstract class BanksTable {
  static const String tableName = 'banks';
  static const String columnId = 'id';
  static const String columnNome = 'nome';

  static const String createSql = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnNome TEXT NOT NULL
    )
  ''';
}
