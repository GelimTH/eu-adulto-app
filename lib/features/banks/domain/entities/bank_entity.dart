import 'package:equatable/equatable.dart';

class BankEntity extends Equatable {
  final int? id;
  final String nome;

  const BankEntity({this.id, required this.nome});

  BankEntity copyWith({int? id, String? nome}) {
    return BankEntity(id: id ?? this.id, nome: nome ?? this.nome);
  }

  @override
  List<Object?> get props => [id, nome];
}
