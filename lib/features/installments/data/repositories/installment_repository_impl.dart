import '../../domain/entities/installment_entity.dart';
import '../../domain/repositories/installment_repository.dart';
import '../datasources/installment_local_datasource.dart';
import '../models/installment_model.dart';

class InstallmentRepositoryImpl implements InstallmentRepository {
  final InstallmentLocalDatasource _datasource;

  const InstallmentRepositoryImpl(this._datasource);

  @override
  Future<List<InstallmentEntity>> getInstallments() =>
      _datasource.getInstallments();

  @override
  Future<double> getMonthlyInstallmentTotal() =>
      _datasource.getMonthlyInstallmentTotal();

  @override
  Future<int> saveInstallment(InstallmentEntity installment) =>
      _datasource.saveInstallment(InstallmentModel.fromEntity(installment));

  @override
  Future<void> updateInstallment(InstallmentEntity installment) =>
      _datasource.updateInstallment(InstallmentModel.fromEntity(installment));

  @override
  Future<void> deleteInstallment(int id) => _datasource.deleteInstallment(id);
}
