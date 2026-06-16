import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database_helper.dart';
import '../../features/onboarding/data/datasources/user_local_datasource.dart';
import '../../features/onboarding/data/repositories/user_repository_impl.dart';
import '../../features/onboarding/domain/repositories/user_repository.dart';
import '../../features/onboarding/domain/use_cases/get_user_use_case.dart';
import '../../features/onboarding/domain/use_cases/save_user_use_case.dart';
import '../../features/banks/data/datasources/bank_local_datasource.dart';
import '../../features/banks/data/repositories/bank_repository_impl.dart';
import '../../features/banks/domain/repositories/bank_repository.dart';
import '../../features/expenses/data/datasources/expense_local_datasource.dart';
import '../../features/expenses/data/repositories/expense_repository_impl.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/debts/data/datasources/debt_local_datasource.dart';
import '../../features/debts/data/repositories/debt_repository_impl.dart';
import '../../features/debts/domain/repositories/debt_repository.dart';
import '../../features/installments/data/datasources/installment_local_datasource.dart';
import '../../features/installments/data/repositories/installment_repository_impl.dart';
import '../../features/installments/domain/repositories/installment_repository.dart';
import '../../features/goals/data/datasources/goal_local_datasource.dart';
import '../../features/goals/data/repositories/goal_repository_impl.dart';
import '../../features/goals/domain/repositories/goal_repository.dart';
import '../../features/reserve/data/datasources/reserve_local_datasource.dart';
import '../../features/reserve/data/repositories/reserve_repository_impl.dart';
import '../../features/reserve/domain/repositories/reserve_repository.dart';
import '../../features/cards/data/datasources/card_local_datasource.dart';
import '../../features/cards/data/repositories/card_repository_impl.dart';
import '../../features/cards/domain/repositories/card_repository.dart';
import '../../features/subscriptions/data/datasources/subscription_local_datasource.dart';
import '../../features/subscriptions/data/repositories/subscription_repository_impl.dart';
import '../../features/subscriptions/domain/repositories/subscription_repository.dart';

// Database
final databaseHelperProvider = Provider<DatabaseHelper>((_) {
  return DatabaseHelper.instance;
});

// User
final userLocalDatasourceProvider = Provider<UserLocalDatasource>((ref) {
  return UserLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(userLocalDatasourceProvider));
});

final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  return GetUserUseCase(ref.read(userRepositoryProvider));
});

final saveUserUseCaseProvider = Provider<SaveUserUseCase>((ref) {
  return SaveUserUseCase(ref.read(userRepositoryProvider));
});

// Banks
final bankLocalDatasourceProvider = Provider<BankLocalDatasource>((ref) {
  return BankLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepositoryImpl(ref.read(bankLocalDatasourceProvider));
});

// Cards
final cardLocalDatasourceProvider = Provider<CardLocalDatasource>((ref) {
  return CardLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(ref.read(cardLocalDatasourceProvider));
});

// Expenses
final expenseLocalDatasourceProvider = Provider<ExpenseLocalDatasource>((ref) {
  return ExpenseLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(ref.read(expenseLocalDatasourceProvider));
});

// Debts
final debtLocalDatasourceProvider = Provider<DebtLocalDatasource>((ref) {
  return DebtLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryImpl(ref.read(debtLocalDatasourceProvider));
});

// Installments
final installmentLocalDatasourceProvider =
    Provider<InstallmentLocalDatasource>((ref) {
  return InstallmentLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final installmentRepositoryProvider = Provider<InstallmentRepository>((ref) {
  return InstallmentRepositoryImpl(ref.read(installmentLocalDatasourceProvider));
});

// Goals
final goalLocalDatasourceProvider = Provider<GoalLocalDatasource>((ref) {
  return GoalLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepositoryImpl(ref.read(goalLocalDatasourceProvider));
});

// Reserve
final reserveLocalDatasourceProvider = Provider<ReserveLocalDatasource>((ref) {
  return ReserveLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final reserveRepositoryProvider = Provider<ReserveRepository>((ref) {
  return ReserveRepositoryImpl(ref.read(reserveLocalDatasourceProvider));
});

// Subscriptions
final subscriptionLocalDatasourceProvider =
    Provider<SubscriptionLocalDatasource>((ref) {
  return SubscriptionLocalDatasourceImpl(ref.read(databaseHelperProvider));
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
      ref.read(subscriptionLocalDatasourceProvider));
});
