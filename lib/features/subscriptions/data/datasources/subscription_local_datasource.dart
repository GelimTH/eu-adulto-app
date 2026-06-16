import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/subscriptions_table.dart';
import '../models/subscription_model.dart';

abstract class SubscriptionLocalDatasource {
  Future<List<SubscriptionModel>> getSubscriptions();
  Future<double> getMonthlyCost();
  Future<int> saveSubscription(SubscriptionModel subscription);
  Future<void> updateSubscription(SubscriptionModel subscription);
  Future<void> deleteSubscription(int id);
}

class SubscriptionLocalDatasourceImpl implements SubscriptionLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const SubscriptionLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<List<SubscriptionModel>> getSubscriptions() async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      SubscriptionsTable.tableName,
      orderBy: '${SubscriptionsTable.columnAtiva} DESC, ${SubscriptionsTable.columnNome} ASC',
    );
    return result.map((map) => SubscriptionModel.fromMap(map)).toList();
  }

  @override
  Future<double> getMonthlyCost() async {
    final subscriptions = await getSubscriptions();
    return subscriptions
        .where((s) => s.ativa)
        .fold<double>(0.0, (sum, s) => sum + s.custoMensal);
  }

  @override
  Future<int> saveSubscription(SubscriptionModel subscription) async {
    final db = await _databaseHelper.database;
    return db.insert(
      SubscriptionsTable.tableName,
      subscription.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateSubscription(SubscriptionModel subscription) async {
    final db = await _databaseHelper.database;
    await db.update(
      SubscriptionsTable.tableName,
      subscription.toMap(),
      where: '${SubscriptionsTable.columnId} = ?',
      whereArgs: [subscription.id],
    );
  }

  @override
  Future<void> deleteSubscription(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      SubscriptionsTable.tableName,
      where: '${SubscriptionsTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
