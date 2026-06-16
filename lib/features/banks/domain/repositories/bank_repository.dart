import '../entities/bank_entity.dart';

abstract class BankRepository {
  Future<List<BankEntity>> getBanks();
  Future<BankEntity?> getBankById(int id);
  Future<int> saveBank(BankEntity bank);
  Future<void> updateBank(BankEntity bank);
  Future<void> deleteBank(int id);
}
