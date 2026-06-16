import '../../domain/entities/expense_entity.dart';
import '../../../../database/tables/expenses_table.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    super.id,
    required super.valor,
    required super.categoria,
    required super.classificacao,
    super.descricao,
    required super.data,
    super.bancoId,
    super.cartaoId,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map[ExpensesTable.columnId] as int?,
      valor: (map[ExpensesTable.columnValor] as num).toDouble(),
      categoria: ExpenseCategory.fromString(
          map[ExpensesTable.columnCategoria] as String),
      classificacao: ExpenseClassification.fromString(
          map[ExpensesTable.columnClassificacao] as String),
      descricao: map[ExpensesTable.columnDescricao] as String?,
      data: DateTime.parse(map[ExpensesTable.columnData] as String),
      bancoId: map[ExpensesTable.columnBancoId] as int?,
      cartaoId: map[ExpensesTable.columnCartaoId] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ExpensesTable.columnValor: valor,
      ExpensesTable.columnCategoria: categoria.name,
      ExpensesTable.columnClassificacao: classificacao.name,
      ExpensesTable.columnDescricao: descricao,
      ExpensesTable.columnData: data.toIso8601String(),
      ExpensesTable.columnBancoId: bancoId,
      ExpensesTable.columnCartaoId: cartaoId,
    };
  }

  factory ExpenseModel.fromEntity(ExpenseEntity entity) {
    return ExpenseModel(
      id: entity.id,
      valor: entity.valor,
      categoria: entity.categoria,
      classificacao: entity.classificacao,
      descricao: entity.descricao,
      data: entity.data,
      bancoId: entity.bancoId,
      cartaoId: entity.cartaoId,
    );
  }
}
