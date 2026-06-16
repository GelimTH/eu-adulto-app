import 'package:sqflite/sqflite.dart';
import '../tables/debts_table.dart';

class MigrationV3 {
  static Future<void> run(Database db) async {
    await db.execute(
      "ALTER TABLE ${DebtsTable.tableName} ADD COLUMN ${DebtsTable.columnTipo} TEXT NOT NULL DEFAULT 'divida'",
    );
  }
}
