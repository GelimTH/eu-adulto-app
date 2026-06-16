import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_datasource.dart';
import '../models/subscription_model.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDatasource _datasource;

  const SubscriptionRepositoryImpl(this._datasource);

  @override
  Future<List<SubscriptionEntity>> getSubscriptions() {
    return _datasource.getSubscriptions();
  }

  @override
  Future<double> getMonthlyCost() {
    return _datasource.getMonthlyCost();
  }

  @override
  Future<int> saveSubscription(SubscriptionEntity subscription) {
    return _datasource.saveSubscription(
        SubscriptionModel.fromEntity(subscription));
  }

  @override
  Future<void> updateSubscription(SubscriptionEntity subscription) {
    return _datasource.updateSubscription(
        SubscriptionModel.fromEntity(subscription));
  }

  @override
  Future<void> deleteSubscription(int id) {
    return _datasource.deleteSubscription(id);
  }
}
