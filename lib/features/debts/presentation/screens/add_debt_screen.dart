import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../providers/debts_provider.dart';
import '../../domain/entities/debt_entity.dart';
import '../../../banks/presentation/providers/banks_provider.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  final DebtEntity? debtToEdit;

  const AddDebtScreen({super.key, this.debtToEdit});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _jurosController = TextEditingController();
  final _parcelasController = TextEditingController();
  final _parcelasRestantesController = TextEditingController();
  int? _selectedBankId;
  DebtType _tipo = DebtType.divida;
  bool _isLoading = false;

  bool get _isEditing => widget.debtToEdit != null;

  @override
  void initState() {
    super.initState();
    final d = widget.debtToEdit;
    if (d != null) {
      _descricaoController.text = d.descricao;
      _valorController.text = d.valorOriginal.toStringAsFixed(2).replaceAll('.', ',');
      _jurosController.text = d.juros.toString();
      _parcelasController.text = d.parcelas.toString();
      _parcelasRestantesController.text = d.parcelasRestantes.toString();
      _selectedBankId = d.bancoId;
      _tipo = d.tipo;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _jurosController.dispose();
    _parcelasController.dispose();
    _parcelasRestantesController.dispose();
    super.dispose();
  }

  double get _valorParcela {
    final valor = _valorController.text.parseBrl;
    final parcelas = int.tryParse(_parcelasController.text) ?? 1;
    final juros = double.tryParse(_jurosController.text.replaceAll(',', '.')) ?? 0;
    if (parcelas <= 0) return 0;
    if (juros <= 0) return valor / parcelas;
    final taxa = juros / 100;
    return valor * taxa / (1 - (1 / (1 + taxa) * parcelas));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final valorOriginal = _valorController.text.parseBrl;
    final parcelas = int.tryParse(_parcelasController.text) ?? 1;
    final parcelasRestantes =
        int.tryParse(_parcelasRestantesController.text) ?? parcelas;
    final juros = double.tryParse(_jurosController.text.replaceAll(',', '.')) ?? 0;
    final valorParcela = _valorParcela;
    final valorRestante = valorParcela * parcelasRestantes;

    final debt = DebtEntity(
      id: widget.debtToEdit?.id,
      bancoId: _selectedBankId,
      tipo: _tipo,
      descricao: _descricaoController.text.trim(),
      valorOriginal: valorOriginal,
      valorRestante: valorRestante,
      juros: juros,
      parcelas: parcelas,
      parcelasRestantes: parcelasRestantes,
      valorParcela: valorParcela,
      dataInicio: widget.debtToEdit?.dataInicio ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await ref.read(debtsNotifierProvider.notifier).editItem(debt);
      } else {
        await ref.read(debtsNotifierProvider.notifier).add(debt);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final banksAsync = ref.watch(banksNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? 'Editar ${_tipo.label}'
            : _tipo == DebtType.emprestimo
                ? 'Novo Empréstimo'
                : AppStrings.novaDivida),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle de tipo
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: DebtType.values.map((t) {
                    final selected = _tipo == t;
                    final color = t == DebtType.emprestimo
                        ? AppColors.info
                        : AppColors.error;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tipo = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? color.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            border: selected
                                ? Border.all(color: color.withValues(alpha: 0.4))
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t.emoji,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                t.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: selected
                                      ? color
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: AppStrings.descricao,
                controller: _descricaoController,
                validator: (v) =>
                    v == null || v.isEmpty ? AppStrings.campoObrigatorio : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppStrings.valorOriginal,
                controller: _valorController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                ],
                validator: (v) =>
                    v == null || v.isEmpty ? AppStrings.campoObrigatorio : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: AppStrings.juros,
                      controller: _jurosController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      label: AppStrings.parcelas,
                      controller: _parcelasController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: (v) => v == null || v.isEmpty
                          ? AppStrings.campoObrigatorio
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Parcelas Restantes',
                controller: _parcelasRestantesController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              banksAsync.when(
                loading: () => const SizedBox(),
                error: (_, _) => const SizedBox(),
                data: (banks) {
                  if (banks.isEmpty) return const SizedBox();
                  return DropdownButtonFormField<int?>(
                    initialValue: _selectedBankId,
                    decoration: const InputDecoration(
                        labelText: AppStrings.banco),
                    dropdownColor: AppColors.cardDark,
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('Nenhum')),
                      ...banks.map((b) => DropdownMenuItem<int?>(
                            value: b.id,
                            child: Text(b.nome),
                          )),
                    ],
                    onChanged: (v) => setState(() => _selectedBankId = v),
                  );
                },
              ),
              if (_valorController.text.isNotEmpty &&
                  _parcelasController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Valor da parcela estimada'),
                      Text(
                        _valorParcela.brl,
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: AppStrings.salvar,
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
