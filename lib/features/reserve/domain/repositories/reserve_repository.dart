import '../entities/reserve_entity.dart';

abstract class ReserveRepository {
  Future<ReserveEntity?> getReserve();
  Future<void> saveOrUpdateReserve(ReserveEntity reserve);
}
