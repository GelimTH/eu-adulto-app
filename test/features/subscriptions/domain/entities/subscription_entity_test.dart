import 'package:flutter_test/flutter_test.dart';
import 'package:eu_adulto/features/subscriptions/domain/entities/subscription_entity.dart';

void main() {
  group('SubscriptionEntity Unit Tests', () {
    final now = DateTime.now();

    test('should calculate correct custoMensal for different periodicities', () {
      final subMensal = SubscriptionEntity(
        nome: 'Netflix',
        valor: 50.0,
        periodicidade: SubscriptionPeriodicity.mensal,
        diaVencimento: 10,
        categoria: SubscriptionCategory.streaming,
        ativa: true,
        dataInicio: now,
      );

      final subAnual = SubscriptionEntity(
        nome: 'Amazon Prime',
        valor: 120.0,
        periodicidade: SubscriptionPeriodicity.anual,
        diaVencimento: 15,
        categoria: SubscriptionCategory.streaming,
        ativa: true,
        dataInicio: now,
      );

      final subSemanal = SubscriptionEntity(
        nome: 'Personal Trainer App',
        valor: 10.0,
        periodicidade: SubscriptionPeriodicity.semanal,
        diaVencimento: 5,
        categoria: SubscriptionCategory.saude,
        ativa: true,
        dataInicio: now,
      );

      expect(subMensal.custoMensal, 50.0);
      expect(subAnual.custoMensal, 10.0); // 120 / 12
      expect(subSemanal.custoMensal, closeTo(43.33, 0.01)); // 10 * 52 / 12 = 43.3333...
    });

    test('should return proximoVencimento in the future', () {
      final sub = SubscriptionEntity(
        nome: 'Spotify',
        valor: 20.0,
        periodicidade: SubscriptionPeriodicity.mensal,
        diaVencimento: 15,
        categoria: SubscriptionCategory.musica,
        ativa: true,
        dataInicio: now,
      );

      final nextVenc = sub.proximoVencimento;
      final today = DateTime.now();

      expect(nextVenc.isAfter(today), isTrue);
      expect(nextVenc.day, 15);
    });

    test('should clamp diaVencimento to 1-28 for proximoVencimento calculation', () {
      final subOver = SubscriptionEntity(
        nome: 'Extra service',
        valor: 15.0,
        periodicidade: SubscriptionPeriodicity.mensal,
        diaVencimento: 31,
        categoria: SubscriptionCategory.outros,
        ativa: true,
        dataInicio: now,
      );

      final subUnder = SubscriptionEntity(
        nome: 'Low service',
        valor: 15.0,
        periodicidade: SubscriptionPeriodicity.mensal,
        diaVencimento: 0,
        categoria: SubscriptionCategory.outros,
        ativa: true,
        dataInicio: now,
      );

      expect(subOver.proximoVencimento.day, 28);
      expect(subUnder.proximoVencimento.day, 1);
    });
  });
}
