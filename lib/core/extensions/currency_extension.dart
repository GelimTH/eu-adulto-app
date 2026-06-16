import 'package:intl/intl.dart';

extension CurrencyExtension on double {
  String get brl {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(this);
  }

  String get brlCompact {
    if (this >= 1000) {
      final formatter = NumberFormat.currency(
        locale: 'pt_BR',
        symbol: 'R\$',
        decimalDigits: 0,
      );
      return formatter.format(this);
    }
    return brl;
  }

  String get percentual {
    final formatter = NumberFormat.decimalPercentPattern(
      locale: 'pt_BR',
      decimalDigits: 1,
    );
    return formatter.format(this / 100);
  }
}

extension CurrencyStringExtension on String {
  double get parseBrl {
    final cleaned = replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
