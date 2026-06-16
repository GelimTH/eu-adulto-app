import '../../domain/entities/debt_entity.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/debt_local_datasource.dart';
import '../models/debt_model.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDatasource _datasource;

  const DebtRepositoryImpl(this._datasource);

  @override
  Future<List<DebtEntity>> getDebts() => _datasource.getDebts();

  @override
  Future<double> getTotalDebt() => _datasource.getTotalDebt();

  @override
  Future<double> getMonthlyDebtPayment() => _datasource.getMonthlyDebtPayment();

  @override
  Future<int> saveDebt(DebtEntity debt) =>
      _datasource.saveDebt(DebtModel.fromEntity(debt));

  @override
  Future<void> updateDebt(DebtEntity debt) =>
      _datasource.updateDebt(DebtModel.fromEntity(debt));

  @override
  Future<void> deleteDebt(int id) => _datasource.deleteDebt(id);
}
