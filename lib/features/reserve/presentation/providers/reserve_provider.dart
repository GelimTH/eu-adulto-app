import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reserve_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final reserveProvider = FutureProvider<ReserveEntity?>((ref) async {
  return ref.read(reserveRepositoryProvider).getReserve();
});

class ReserveNotifier extends AsyncNotifier<ReserveEntity?> {
  @override
  Future<ReserveEntity?> build() async {
    return ref.read(reserveRepositoryProvider).getReserve();
  }

  Future<void> updateReserve(double valor) async {
    final current = await ref.read(reserveRepositoryProvider).getReserve();
    final reserve = ReserveEntity(
      id: current?.id,
      valorAtual: valor,
      dataAtualizacao: DateTime.now(),
    );
    await ref.read(reserveRepositoryProvider).saveOrUpdateReserve(reserve);
    ref.invalidateSelf();
  }

  Future<void> addToReserve(double valor) async {
    final current = await ref.read(reserveRepositoryProvider).getReserve();
    final novoValor = (current?.valorAtual ?? 0) + valor;
    await updateReserve(novoValor);
  }
}

final reserveNotifierProvider =
    AsyncNotifierProvider<ReserveNotifier, ReserveEntity?>(
        ReserveNotifier.new);
