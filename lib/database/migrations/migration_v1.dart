import 'package:sqflite/sqflite.dart';
import '../tables/users_table.dart';
import '../tables/banks_table.dart';
import '../tables/cards_table.dart';
import '../tables/expenses_table.dart';
import '../tables/debts_table.dart';
import '../tables/installments_table.dart';
import '../tables/goals_table.dart';
import '../tables/reserve_table.dart';

class MigrationV1 {
  static Future<void> create(Database db) async {
    await db.execute(UsersTable.createSql);
    await db.execute(BanksTable.createSql);
    await db.execute(CardsTable.createSql);
    await db.execute(ExpensesTable.createSql);
    await db.execute(DebtsTable.createSql);
    await db.execute(InstallmentsTable.createSql);
    await db.execute(GoalsTable.createSql);
    await db.execute(ReserveTable.createSql);
  }
}
