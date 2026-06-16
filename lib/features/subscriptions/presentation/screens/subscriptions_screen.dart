import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/currency_extension.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../providers/subscriptions_provider.dart';
import '../../domain/entities/subscription_entity.dart';

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSubs = ref.watch(subscriptionsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assinaturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.primary,
            onPressed: () => _showForm(context, ref),
          ),
        ],
      ),
      body: asyncSubs.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (subs) {
          final ativas = subs.where((s) => s.ativa).toList();
          final pausadas = subs.where((s) => !s.ativa).toList();
          final totalMensal =
              ativas.fold(0.0, (sum, s) => sum + s.custoMensal);

          if (subs.isEmpty) {
            return EmptyStateWidget(
              message:
                  'Nenhuma assinatura cadastrada.\nAdicione seus planos e serviços recorrentes.',
              actionLabel: 'Nova Assinatura',
              icon: Icons.subscriptions_outlined,
              onAction: () => _showForm(context, ref),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _TotalCard(totalMensal: totalMensal, totalCount: ativas.length),
              const SizedBox(height: 20),
              if (ativas.isNotEmpty) ...[
                Text('Ativas', style: AppTextStyles.label),
                const SizedBox(height: 10),
                ...ativas.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SubscriptionCard(
                        subscription: s,
                        onEdit: () => _showForm(context, ref, s),
                        onToggle: () => ref
                            .read(subscriptionsNotifierProvider.notifier)
                            .toggleAtiva(s),
                        onDelete: () => _confirmDelete(context, ref, s),
                      ),
                    )),
              ],
              if (pausadas.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text('Pausadas', style: AppTextStyles.label),
                const SizedBox(height: 10),
                ...pausadas.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SubscriptionCard(
                        subscription: s,
                        onEdit: () => _showForm(context, ref, s),
                        onToggle: () => ref
                            .read(subscriptionsNotifierProvider.notifier)
                            .toggleAtiva(s),
                        onDelete: () => _confirmDelete(context, ref, s),
                      ),
                    )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nova Assinatura',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref,
      [SubscriptionEntity? sub]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _SubscriptionFormSheet(ref: ref, subscription: sub),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, SubscriptionEntity sub) async {
    final confirmed = await ConfirmationDialog.show(context);
    if (confirmed && sub.id != null) {
      ref.read(subscriptionsNotifierProvider.notifier).delete(sub.id!);
    }
  }
}

class _TotalCard extends StatelessWidget {
  final double totalMensal;
  final int totalCount;

  const _TotalCard({required this.totalMensal, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.subscriptions_outlined,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Custo mensal total', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                totalMensal.brl,
                style: AppTextStyles.moneyLarge
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$totalCount ativa${totalCount != 1 ? 's' : ''}',
                  style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(
                '${(totalMensal * 12).brlCompact}/ano',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionEntity subscription;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _SubscriptionCard({
    required this.subscription,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = subscription;
    final isActive = s.ativa;
    final now = DateTime.now();
    final diasAteVencer = s.proximoVencimento.difference(now).inDays;

    return Opacity(
      opacity: isActive ? 1.0 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.border
                : AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            // Conteúdo principal
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isActive ? 0.12 : 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(s.categoria.emoji,
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.nome,
                                style: AppTextStyles.body,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isActive)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Pausada',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              s.periodicidade == SubscriptionPeriodicity.mensal
                                  ? s.valor.brl
                                  : '${s.valor.brl}/${s.periodicidade == SubscriptionPeriodicity.anual ? 'ano' : 'sem'}',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            if (s.periodicidade !=
                                SubscriptionPeriodicity.mensal) ...[
                              const SizedBox(width: 4),
                              Text('≈ ${s.custoMensal.brl}/mês',
                                  style: AppTextStyles.caption),
                            ],
                          ],
                        ),
                        if (isActive) ...[
                          const SizedBox(height: 3),
                          Text(
                            diasAteVencer <= 0
                                ? 'Vence hoje'
                                : diasAteVencer == 1
                                    ? 'Vence amanhã'
                                    : 'Vence em $diasAteVencer dias',
                            style: AppTextStyles.caption.copyWith(
                              color: diasAteVencer <= 3
                                  ? AppColors.warning
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Barra de ações direta — sem popup, 1 toque por ação
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5)),
                ),
              ),
              child: Row(
                children: [
                  _ActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Editar',
                    color: AppColors.textSecondary,
                    onTap: onEdit,
                  ),
                  _VerticalDivider(),
                  _ActionButton(
                    icon: isActive
                        ? Icons.pause_outlined
                        : Icons.play_arrow_outlined,
                    label: isActive ? 'Pausar' : 'Reativar',
                    color: AppColors.warning,
                    onTap: onToggle,
                  ),
                  _VerticalDivider(),
                  _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Excluir',
                    color: AppColors.error,
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.border.withValues(alpha: 0.5),
    );
  }
}

class _SubscriptionFormSheet extends StatefulWidget {
  final WidgetRef ref;
  final SubscriptionEntity? subscription;

  const _SubscriptionFormSheet({required this.ref, this.subscription});

  @override
  State<_SubscriptionFormSheet> createState() => _SubscriptionFormSheetState();
}

class _SubscriptionFormSheetState extends State<_SubscriptionFormSheet> {
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _diaController = TextEditingController(text: '1');

  SubscriptionPeriodicity _periodicidade = SubscriptionPeriodicity.mensal;
  SubscriptionCategory _categoria = SubscriptionCategory.streaming;
  bool _ativa = true;
  bool _isLoading = false;

  bool get _isEditing => widget.subscription != null;

  @override
  void initState() {
    super.initState();
    final s = widget.subscription;
    if (s != null) {
      _nomeController.text = s.nome;
      _valorController.text =
          s.valor.toStringAsFixed(2).replaceAll('.', ',');
      _diaController.text = s.diaVencimento.toString();
      _periodicidade = s.periodicidade;
      _categoria = s.categoria;
      _ativa = s.ativa;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _diaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nomeController.text.trim().isEmpty) return;
    final valor = _valorController.text.parseBrl;
    if (valor <= 0) return;

    setState(() => _isLoading = true);

    final subscription = SubscriptionEntity(
      id: widget.subscription?.id,
      nome: _nomeController.text.trim(),
      valor: valor,
      periodicidade: _periodicidade,
      diaVencimento: int.tryParse(_diaController.text) ?? 1,
      categoria: _categoria,
      ativa: _ativa,
      dataInicio: widget.subscription?.dataInicio ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await widget.ref
            .read(subscriptionsNotifierProvider.notifier)
            .editItem(subscription);
      } else {
        await widget.ref
            .read(subscriptionsNotifierProvider.notifier)
            .add(subscription);
      }
      if (mounted) Navigator.of(context).pop();
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
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? 'Editar Assinatura' : 'Nova Assinatura',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nomeController,
            autofocus: !_isEditing,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nome do serviço',
              hintText: 'Netflix, Academia, Spotify...',
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _valorController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d,\.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    prefixText: 'R\$ ',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _diaController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      const InputDecoration(labelText: 'Dia venc.'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Periodicidade', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Row(
            children: SubscriptionPeriodicity.values.map((p) {
              final selected = _periodicidade == p;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: p != SubscriptionPeriodicity.semanal ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _periodicidade = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.inputFill,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          p.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text('Categoria', style: AppTextStyles.label),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: SubscriptionCategory.values.length,
            itemBuilder: (_, i) {
              final cat = SubscriptionCategory.values[i];
              final selected = _categoria == cat;
              return GestureDetector(
                onTap: () => setState(() => _categoria = cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 3),
                      Text(
                        cat.label,
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 9),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isEditing) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assinatura ativa', style: AppTextStyles.body),
                Switch(
                  value: _ativa,
                  onChanged: (v) => setState(() => _ativa = v),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(_isEditing ? 'Salvar alterações' : 'Adicionar'),
          ),
        ],
      ),
    );
  }
}
