import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final Color confirmColor;

  const ConfirmationDialog({
    super.key,
    this.title = AppStrings.confirmarExclusao,
    this.content = AppStrings.acaoIrreversivel,
    this.confirmLabel = AppStrings.excluir,
    this.confirmColor = AppColors.error,
  });

  static Future<bool> show(
    BuildContext context, {
    String? title,
    String? content,
    String confirmLabel = AppStrings.excluir,
    Color confirmColor = AppColors.error,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmationDialog(
        title: title ?? AppStrings.confirmarExclusao,
        content: content ?? AppStrings.acaoIrreversivel,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(AppStrings.cancelar),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: confirmColor),
          ),
        ),
      ],
    );
  }
}
