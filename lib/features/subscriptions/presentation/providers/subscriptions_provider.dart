import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

class SubscriptionsNotifier extends AsyncNotifier<List<SubscriptionEntity>> {
  @override
  Future<List<SubscriptionEntity>> build() async {
    return ref.read(subscriptionRepositoryProvider).getSubscriptions();
  }

  Future<void> add(SubscriptionEntity subscription) async {
    await ref.read(subscriptionRepositoryProvider).saveSubscription(subscription);
    ref.invalidateSelf();
  }

  Future<void> editItem(SubscriptionEntity subscription) async {
    await ref
        .read(subscriptionRepositoryProvider)
        .updateSubscription(subscription);
    ref.invalidateSelf();
  }

  Future<void> toggleAtiva(SubscriptionEntity subscription) async {
    await ref.read(subscriptionRepositoryProvider).updateSubscription(
          subscription.copyWith(ativa: !subscription.ativa),
        );
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await ref.read(subscriptionRepositoryProvider).deleteSubscription(id);
    ref.invalidateSelf();
  }
}

final subscriptionsNotifierProvider =
    AsyncNotifierProvider<SubscriptionsNotifier, List<SubscriptionEntity>>(
        SubscriptionsNotifier.new);

final monthlySubscriptionCostProvider = FutureProvider<double>((ref) async {
  ref.watch(subscriptionsNotifierProvider);
  return ref.read(subscriptionRepositoryProvider).getMonthlyCost();
});
