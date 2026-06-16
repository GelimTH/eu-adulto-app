import 'package:sqflite/sqflite.dart';
import '../../../../database/database_helper.dart';
import '../../../../database/tables/cards_table.dart';
import '../models/card_model.dart';

abstract class CardLocalDatasource {
  Future<List<CardModel>> getCards();
  Future<List<CardModel>> getCardsByBank(int bankId);
  Future<int> saveCard(CardModel card);
  Future<void> updateCard(CardModel card);
  Future<void> deleteCard(int id);
}

class CardLocalDatasourceImpl implements CardLocalDatasource {
  final DatabaseHelper _databaseHelper;

  const CardLocalDatasourceImpl(this._databaseHelper);

  @override
  Future<List<CardModel>> getCards() async {
    final db = await _databaseHelper.database;
    final result = await db.query(CardsTable.tableName);
    return result.map((map) => CardModel.fromMap(map)).toList();
  }

  @override
  Future<List<CardModel>> getCardsByBank(int bankId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      CardsTable.tableName,
      where: '${CardsTable.columnBancoId} = ?',
      whereArgs: [bankId],
    );
    return result.map((map) => CardModel.fromMap(map)).toList();
  }

  @override
  Future<int> saveCard(CardModel card) async {
    final db = await _databaseHelper.database;
    return db.insert(
      CardsTable.tableName,
      card.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  @override
  Future<void> updateCard(CardModel card) async {
    final db = await _databaseHelper.database;
    await db.update(
      CardsTable.tableName,
      card.toMap(),
      where: '${CardsTable.columnId} = ?',
      whereArgs: [card.id],
    );
  }

  @override
  Future<void> deleteCard(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      CardsTable.tableName,
      where: '${CardsTable.columnId} = ?',
      whereArgs: [id],
    );
  }
}
