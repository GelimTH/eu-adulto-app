import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/bank_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final banksProvider = FutureProvider<List<BankEntity>>((ref) async {
  return ref.read(bankRepositoryProvider).getBanks();
});

class BanksNotifier extends AsyncNotifier<List<BankEntity>> {
  @override
  Future<List<BankEntity>> build() async {
    return ref.read(bankRepositoryProvider).getBanks();
  }

  Future<void> add(BankEntity bank) async {
    await ref.read(bankRepositoryProvider).saveBank(bank);
    ref.invalidateSelf();
  }

  Future<void> editItem(BankEntity bank) async {
    await ref.read(bankRepositoryProvider).updateBank(bank);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(bankRepositoryProvider).deleteBank(id);
    ref.invalidateSelf();
  }
}

final banksNotifierProvider =
    AsyncNotifierProvider<BanksNotifier, List<BankEntity>>(BanksNotifier.new);
