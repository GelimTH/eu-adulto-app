import 'package:flutter_test/flutter_test.dart';
import 'package:eu_adulto/features/debts/domain/entities/debt_entity.dart';

void main() {
  group('DebtEntity Unit Tests', () {
    final dataInicio = DateTime(2026, 1, 10);

    test('should calculate correct quitacaoPrevista based on parcelasRestantes', () {
      final debt = DebtEntity(
        descricao: 'Empréstimo Banco do Brasil',
        tipo: DebtType.emprestimo,
        valorOriginal: 10000.0,
        valorRestante: 5000.0,
        juros: 2.5,
        parcelas: 24,
        parcelasRestantes: 12,
        valorParcela: 500.0,
        dataInicio: dataInicio,
      );

      final quitacao = debt.quitacaoPrevista;
      
      // Jan 10, 2026 + 12 months = Jan 10, 2027
      expect(quitacao, DateTime(2027, 1, 10));
    });

    test('should calculate correct economiaAntecipacao', () {
      final debt = DebtEntity(
        descricao: 'Cheque Especial',
        tipo: DebtType.divida,
        valorOriginal: 2000.0,
        valorRestante: 1500.0,
        juros: 8.0, // 8%
        parcelas: 6,
        parcelasRestantes: 3,
        valorParcela: 500.0,
        dataInicio: dataInicio,
      );

      // 1500 * 0.08 * 3 = 360.0
      expect(debt.economiaAntecipacao, 360.0);
    });

    test('should return 0 economiaAntecipacao when juros is 0 or negative', () {
      final debtZeroJuros = DebtEntity(
        descricao: 'Empréstimo Amigo',
        tipo: DebtType.divida,
        valorOriginal: 1000.0,
        valorRestante: 1000.0,
        juros: 0.0,
        parcelas: 10,
        parcelasRestantes: 5,
        valorParcela: 100.0,
        dataInicio: dataInicio,
      );

      final debtNegativeJuros = DebtEntity(
        descricao: 'Empréstimo Amigo',
        tipo: DebtType.divida,
        valorOriginal: 1000.0,
        valorRestante: 1000.0,
        juros: -1.0,
        parcelas: 10,
        parcelasRestantes: 5,
        valorParcela: 100.0,
        dataInicio: dataInicio,
      );

      expect(debtZeroJuros.economiaAntecipacao, 0.0);
      expect(debtNegativeJuros.economiaAntecipacao, 0.0);
    });

    test('should map DebtType fromString correctly', () {
      expect(DebtType.fromString('divida'), DebtType.divida);
      expect(DebtType.fromString('emprestimo'), DebtType.emprestimo);
      expect(DebtType.fromString('invalid'), DebtType.divida); // defaults to divida
    });
  });
}
