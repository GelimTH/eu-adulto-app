import 'package:equatable/equatable.dart';

class GoalEntity extends Equatable {
  final int? id;
  final String nome;
  final double valorAlvo;
  final double valorAtual;
  final DateTime? prazo;
  final DateTime dataCriacao;

  const GoalEntity({
    this.id,
    required this.nome,
    required this.valorAlvo,
    required this.valorAtual,
    this.prazo,
    required this.dataCriacao,
  });

  double get percentualConcluido {
    if (valorAlvo <= 0) return 0;
    final pct = valorAtual / valorAlvo * 100;
    return pct.clamp(0, 100);
  }

  double get valorFaltante => (valorAlvo - valorAtual).clamp(0, double.infinity);

  bool get concluida => valorAtual >= valorAlvo;

  GoalEntity copyWith({
    int? id,
    String? nome,
    double? valorAlvo,
    double? valorAtual,
    DateTime? prazo,
    DateTime? dataCriacao,
  }) {
    return GoalEntity(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valorAlvo: valorAlvo ?? this.valorAlvo,
      valorAtual: valorAtual ?? this.valorAtual,
      prazo: prazo ?? this.prazo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  List<Object?> get props =>
      [id, nome, valorAlvo, valorAtual, prazo, dataCriacao];
}
