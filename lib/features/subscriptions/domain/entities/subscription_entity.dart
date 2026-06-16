import 'package:equatable/equatable.dart';

enum SubscriptionPeriodicity {
  mensal,
  anual,
  semanal;

  String get label {
    switch (this) {
      case mensal:
        return 'Mensal';
      case anual:
        return 'Anual';
      case semanal:
        return 'Semanal';
    }
  }

  static SubscriptionPeriodicity fromString(String value) {
    return SubscriptionPeriodicity.values.firstWhere(
      (e) => e.name == value,
      orElse: () => mensal,
    );
  }
}

enum SubscriptionCategory {
  streaming,
  musica,
  jogos,
  saude,
  educacao,
  trabalho,
  noticias,
  outros;

  String get label {
    switch (this) {
      case streaming:
        return 'Streaming';
      case musica:
        return 'Música';
      case jogos:
        return 'Jogos';
      case saude:
        return 'Saúde';
      case educacao:
        return 'Educação';
      case trabalho:
        return 'Trabalho';
      case noticias:
        return 'Notícias';
      case outros:
        return 'Outros';
    }
  }

  String get emoji {
    switch (this) {
      case streaming:
        return '🎬';
      case musica:
        return '🎵';
      case jogos:
        return '🎮';
      case saude:
        return '💊';
      case educacao:
        return '📚';
      case trabalho:
        return '💼';
      case noticias:
        return '📰';
      case outros:
        return '📦';
    }
  }

  static SubscriptionCategory fromString(String value) {
    return SubscriptionCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => outros,
    );
  }
}

class SubscriptionEntity extends Equatable {
  final int? id;
  final String nome;
  final double valor;
  final SubscriptionPeriodicity periodicidade;
  final int diaVencimento;
  final SubscriptionCategory categoria;
  final bool ativa;
  final DateTime dataInicio;

  const SubscriptionEntity({
    this.id,
    required this.nome,
    required this.valor,
    required this.periodicidade,
    required this.diaVencimento,
    required this.categoria,
    required this.ativa,
    required this.dataInicio,
  });

  double get custoMensal {
    switch (periodicidade) {
      case SubscriptionPeriodicity.mensal:
        return valor;
      case SubscriptionPeriodicity.anual:
        return valor / 12;
      case SubscriptionPeriodicity.semanal:
        return valor * 52 / 12;
    }
  }

  DateTime get proximoVencimento {
    final now = DateTime.now();
    var venc = DateTime(now.year, now.month, diaVencimento.clamp(1, 28));
    if (!venc.isAfter(now)) {
      venc = DateTime(now.year, now.month + 1, diaVencimento.clamp(1, 28));
    }
    return venc;
  }

  SubscriptionEntity copyWith({
    int? id,
    String? nome,
    double? valor,
    SubscriptionPeriodicity? periodicidade,
    int? diaVencimento,
    SubscriptionCategory? categoria,
    bool? ativa,
    DateTime? dataInicio,
  }) {
    return SubscriptionEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valor: valor ?? this.valor,
      periodicidade: periodicidade ?? this.periodicidade,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      categoria: categoria ?? this.categoria,
      ativa: ativa ?? this.ativa,
      dataInicio: dataInicio ?? this.dataInicio,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nome,
        valor,
        periodicidade,
        diaVencimento,
        categoria,
        ativa,
        dataInicio,
      ];
}
