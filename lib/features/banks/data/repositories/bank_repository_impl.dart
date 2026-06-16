import '../../domain/entities/bank_entity.dart';
import '../../domain/repositories/bank_repository.dart';
import '../datasources/bank_local_datasource.dart';
import '../models/bank_model.dart';

class BankRepositoryImpl implements BankRepository {
  final BankLocalDatasource _datasource;

  const BankRepositoryImpl(this._datasource);

  @override
  Future<List<BankEntity>> getBanks() => _datasource.getBanks();

  @override
  Future<BankEntity?> getBankById(int id) => _datasource.getBankById(id);

  @override
  Future<int> saveBank(BankEntity bank) =>
      _datasource.saveBank(BankModel.fromEntity(bank));

  @override
  Future<void> updateBank(BankEntity bank) =>
      _datasource.updateBank(BankModel.fromEntity(bank));

  @override
  Future<void> deleteBank(int id) => _datasource.deleteBank(id);
}
