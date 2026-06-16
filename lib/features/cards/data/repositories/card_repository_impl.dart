import '../../domain/entities/card_entity.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_local_datasource.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final CardLocalDatasource _datasource;

  const CardRepositoryImpl(this._datasource);

  @override
  Future<List<CardEntity>> getCards() => _datasource.getCards();

  @override
  Future<List<CardEntity>> getCardsByBank(int bankId) =>
      _datasource.getCardsByBank(bankId);

  @override
  Future<int> saveCard(CardEntity card) =>
      _datasource.saveCard(CardModel.fromEntity(card));

  @override
  Future<void> updateCard(CardEntity card) =>
      _datasource.updateCard(CardModel.fromEntity(card));

  @override
  Future<void> deleteCard(int id) => _datasource.deleteCard(id);
}
