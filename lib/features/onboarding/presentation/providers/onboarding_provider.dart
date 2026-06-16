import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../shared/providers/shared_providers.dart';

final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  return ref.read(getUserUseCaseProvider).call();
});

final hasUserProvider = FutureProvider<bool>((ref) async {
  return ref.read(userRepositoryProvider).hasUser();
});

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setName(String nome) {
    state = state.copyWith(nome: nome);
  }

  void setSalary(double salario) {
    state = state.copyWith(salarioMensal: salario);
  }

  void setPercentuais({
    required double necessidades,
    required double objetivos,
    required double reserva,
  }) {
    state = state.copyWith(
      percentualNecessidades: necessidades,
      percentualObjetivos: objetivos,
      percentualReserva: reserva,
    );
  }

  Future<void> save() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = UserEntity(
        nome: state.nome,
        salarioMensal: state.salarioMensal,
        percentualNecessidades: state.percentualNecessidades,
        percentualObjetivos: state.percentualObjetivos,
        percentualReserva: state.percentualReserva,
        dataCriacao: DateTime.now(),
      );
      await ref.read(saveUserUseCaseProvider).call(user);
      ref.invalidate(currentUserProvider);
      ref.invalidate(hasUserProvider);
      state = state.copyWith(isLoading: false, saved: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
        OnboardingNotifier.new);

class OnboardingState {
  final String nome;
  final double salarioMensal;
  final double percentualNecessidades;
  final double percentualObjetivos;
  final double percentualReserva;
  final bool isLoading;
  final bool saved;
  final String? error;

  const OnboardingState({
    this.nome = '',
    this.salarioMensal = 0,
    this.percentualNecessidades = 60,
    this.percentualObjetivos = 30,
    this.percentualReserva = 10,
    this.isLoading = false,
    this.saved = false,
    this.error,
  });

  OnboardingState copyWith({
    String? nome,
    double? salarioMensal,
    double? percentualNecessidades,
    double? percentualObjetivos,
    double? percentualReserva,
    bool? isLoading,
    bool? saved,
    String? error,
  }) {
    return OnboardingState(
      nome: nome ?? this.nome,
      salarioMensal: salarioMensal ?? this.salarioMensal,
      percentualNecessidades:
          percentualNecessidades ?? this.percentualNecessidades,
      percentualObjetivos: percentualObjetivos ?? this.percentualObjetivos,
      percentualReserva: percentualReserva ?? this.percentualReserva,
      isLoading: isLoading ?? this.isLoading,
      saved: saved ?? this.saved,
      error: error,
    );
  }
}
