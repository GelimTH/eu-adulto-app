import 'package:flutter_test/flutter_test.dart';
import 'package:eu_adulto/features/goals/domain/entities/goal_entity.dart';

void main() {
  group('GoalEntity Unit Tests', () {
    final now = DateTime.now();

    test('should calculate correct percentualConcluido', () {
      final goal = GoalEntity(
        nome: 'Reserva',
        valorAlvo: 1000.0,
        valorAtual: 250.0,
        dataCriacao: now,
      );

      expect(goal.percentualConcluido, 25.0);
    });

    test('should clamp percentualConcluido between 0 and 100', () {
      final goalLow = GoalEntity(
        nome: 'Reserva',
        valorAlvo: 1000.0,
        valorAtual: -50.0,
        dataCriacao: now,
      );
      final goalHigh = GoalEntity(
        nome: 'Reserva',
        valorAlvo: 1000.0,
        valorAtual: 1500.0,
        dataCriacao: now,
      );

      expect(goalLow.percentualConcluido, 0.0);
      expect(goalHigh.percentualConcluido, 100.0);
    });

    test('should return 0 percentualConcluido if valorAlvo is 0 or negative', () {
      final goalZero = GoalEntity(
        nome: 'Reserva',
        valorAlvo: 0.0,
        valorAtual: 250.0,
        dataCriacao: now,
      );

      expect(goalZero.percentualConcluido, 0.0);
    });

    test('should calculate correct valorFaltante', () {
      final goal = GoalEntity(
        nome: 'Viagem',
        valorAlvo: 5000.0,
        valorAtual: 1200.0,
        dataCriacao: now,
      );

      expect(goal.valorFaltante, 3800.0);
    });

    test('should return 0 valorFaltante if valorAtual exceeds valorAlvo', () {
      final goal = GoalEntity(
        nome: 'Viagem',
        valorAlvo: 5000.0,
        valorAtual: 6000.0,
        dataCriacao: now,
      );

      expect(goal.valorFaltante, 0.0);
    });

    test('should return true for concluida if target is reached or exceeded', () {
      final goalNotConcluded = GoalEntity(
        nome: 'Curso',
        valorAlvo: 100.0,
        valorAtual: 99.9,
        dataCriacao: now,
      );
      final goalConcluded = GoalEntity(
        nome: 'Curso',
        valorAlvo: 100.0,
        valorAtual: 100.0,
        dataCriacao: now,
      );
      final goalOverConcluded = GoalEntity(
        nome: 'Curso',
        valorAlvo: 100.0,
        valorAtual: 150.0,
        dataCriacao: now,
      );

      expect(goalNotConcluded.concluida, isFalse);
      expect(goalConcluded.concluida, isTrue);
      expect(goalOverConcluded.concluida, isTrue);
    });
  });
}
