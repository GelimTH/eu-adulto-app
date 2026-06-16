import '../entities/installment_entity.dart';

abstract class InstallmentRepository {
  Future<List<InstallmentEntity>> getInstallments();
  Future<double> getMonthlyInstallmentTotal();
  Future<int> saveInstallment(InstallmentEntity installment);
  Future<void> updateInstallment(InstallmentEntity installment);
  Future<void> deleteInstallment(int id);
}
