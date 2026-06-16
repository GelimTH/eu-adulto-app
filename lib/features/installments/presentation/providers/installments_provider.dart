import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/installment_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final installmentsProvider = FutureProvider<List<InstallmentEntity>>((ref) async {
  return ref.read(installmentRepositoryProvider).getInstallments();
});

final monthlyInstallmentTotalProvider = FutureProvider<double>((ref) async {
  ref.watch(installmentsProvider);
  return ref.read(installmentRepositoryProvider).getMonthlyInstallmentTotal();
});

class InstallmentsNotifier extends AsyncNotifier<List<InstallmentEntity>> {
  @override
  Future<List<InstallmentEntity>> build() async {
    return ref.read(installmentRepositoryProvider).getInstallments();
  }

  Future<void> add(InstallmentEntity installment) async {
    await ref.read(installmentRepositoryProvider).saveInstallment(installment);
    ref.invalidateSelf();
    ref.invalidate(monthlyInstallmentTotalProvider);
  }

  Future<void> editItem(InstallmentEntity installment) async {
    await ref.read(installmentRepositoryProvider).updateInstallment(installment);
    ref.invalidateSelf();
    ref.invalidate(monthlyInstallmentTotalProvider);
  }

  Future<void> delete(int id) async {
    await ref.read(installmentRepositoryProvider).deleteInstallment(id);
    ref.invalidateSelf();
    ref.invalidate(monthlyInstallmentTotalProvider);
  }
}

final installmentsNotifierProvider =
    AsyncNotifierProvider<InstallmentsNotifier, List<InstallmentEntity>>(
        InstallmentsNotifier.new);
