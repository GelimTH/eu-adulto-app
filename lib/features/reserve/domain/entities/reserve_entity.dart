import 'package:equatable/equatable.dart';

class ReserveEntity extends Equatable {
  final int? id;
  final double valorAtual;
  final DateTime dataAtualizacao;

  const ReserveEntity({
    this.id,
    required this.valorAtual,
    required this.dataAtualizacao,
  });

  double metaIdeal(double mediaDespestasMensais) => mediaDespestasMensais * 6;

  double percentualMeta(double mediaDespestasMensais) {
    final meta = metaIdeal(mediaDespestasMensais);
    if (meta <= 0) return 0;
    return (valorAtual / meta * 100).clamp(0, 100);
  }

  ReserveEntity copyWith({
    int? id,
    double? valorAtual,
    DateTime? dataAtualizacao,
  }) {
    return ReserveEntity(
      id: id ?? this.id,
      valorAtual: valorAtual ?? this.valorAtual,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  @override
  List<Object?> get props => [id, valorAtual, dataAtualizacao];
}
