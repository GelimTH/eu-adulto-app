import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/debt_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final debtsProvider = FutureProvider<List<DebtEntity>>((ref) async {
  return ref.read(debtRepositoryProvider).getDebts();
});

final totalDebtProvider = FutureProvider<double>((ref) async {
  ref.watch(debtsProvider);
  return ref.read(debtRepositoryProvider).getTotalDebt();
});

final monthlyDebtPaymentProvider = FutureProvider<double>((ref) async {
  ref.watch(debtsProvider);
  return ref.read(debtRepositoryProvider).getMonthlyDebtPayment();
});

class DebtsNotifier extends AsyncNotifier<List<DebtEntity>> {
  @override
  Future<List<DebtEntity>> build() async {
    return ref.read(debtRepositoryProvider).getDebts();
  }

  Future<void> add(DebtEntity debt) async {
    await ref.read(debtRepositoryProvider).saveDebt(debt);
    _invalidateAll();
  }

  Future<void> editItem(DebtEntity debt) async {
    await ref.read(debtRepositoryProvider).updateDebt(debt);
    _invalidateAll();
  }

  Future<void> delete(int id) async {
    await ref.read(debtRepositoryProvider).deleteDebt(id);
    _invalidateAll();
  }

  void _invalidateAll() {
    ref.invalidateSelf();
    ref.invalidate(totalDebtProvider);
    ref.invalidate(monthlyDebtPaymentProvider);
  }
}

final debtsNotifierProvider =
    AsyncNotifierProvider<DebtsNotifier, List<DebtEntity>>(DebtsNotifier.new);
