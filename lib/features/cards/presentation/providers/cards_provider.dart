import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/card_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final cardsProvider = FutureProvider<List<CardEntity>>((ref) async {
  return ref.read(cardRepositoryProvider).getCards();
});

class CardsNotifier extends AsyncNotifier<List<CardEntity>> {
  @override
  Future<List<CardEntity>> build() async {
    return ref.read(cardRepositoryProvider).getCards();
  }

  Future<void> add(CardEntity card) async {
    await ref.read(cardRepositoryProvider).saveCard(card);
    ref.invalidateSelf();
  }

  Future<void> editItem(CardEntity card) async {
    await ref.read(cardRepositoryProvider).updateCard(card);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(cardRepositoryProvider).deleteCard(id);
    ref.invalidateSelf();
  }
}

final cardsNotifierProvider =
    AsyncNotifierProvider<CardsNotifier, List<CardEntity>>(CardsNotifier.new);
