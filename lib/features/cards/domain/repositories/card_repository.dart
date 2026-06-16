import '../entities/card_entity.dart';

abstract class CardRepository {
  Future<List<CardEntity>> getCards();
  Future<List<CardEntity>> getCardsByBank(int bankId);
  Future<int> saveCard(CardEntity card);
  Future<void> updateCard(CardEntity card);
  Future<void> deleteCard(int id);
}
