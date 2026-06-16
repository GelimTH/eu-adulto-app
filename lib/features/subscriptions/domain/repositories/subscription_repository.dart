import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionEntity>> getSubscriptions();
  Future<double> getMonthlyCost();
  Future<int> saveSubscription(SubscriptionEntity subscription);
  Future<void> updateSubscription(SubscriptionEntity subscription);
  Future<void> deleteSubscription(int id);
}
