import '../entities/debt_entity.dart';

abstract class DebtRepository {
  Future<List<DebtEntity>> getDebts();
  Future<double> getTotalDebt();
  Future<double> getMonthlyDebtPayment();
  Future<int> saveDebt(DebtEntity debt);
  Future<void> updateDebt(DebtEntity debt);
  Future<void> deleteDebt(int id);
}
