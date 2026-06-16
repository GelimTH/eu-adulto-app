import '../../domain/entities/reserve_entity.dart';
import '../../domain/repositories/reserve_repository.dart';
import '../datasources/reserve_local_datasource.dart';
import '../models/reserve_model.dart';

class ReserveRepositoryImpl implements ReserveRepository {
  final ReserveLocalDatasource _datasource;

  const ReserveRepositoryImpl(this._datasource);

  @override
  Future<ReserveEntity?> getReserve() => _datasource.getReserve();

  @override
  Future<void> saveOrUpdateReserve(ReserveEntity reserve) =>
      _datasource.saveOrUpdateReserve(ReserveModel.fromEntity(reserve));
}
