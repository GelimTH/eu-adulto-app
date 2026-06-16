import 'package:sqflite/sqflite.dart';
import '../tables/subscriptions_table.dart';

class MigrationV2 {
  static Future<void> run(Database db) async {
    await db.execute(SubscriptionsTable.createSql);
  }
}
