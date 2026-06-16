import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String get ddMMyyyy => DateFormat('dd/MM/yyyy', 'pt_BR').format(this);

  String get mmmyyyy => DateFormat('MMM/yyyy', 'pt_BR').format(this);

  String get mesAno => DateFormat('MMMM yyyy', 'pt_BR').format(this);

  String get ddMMM => DateFormat('dd MMM', 'pt_BR').format(this);

  String get horaMinuto => DateFormat('HH:mm', 'pt_BR').format(this);

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);
}

extension NullableDateExtension on DateTime? {
  String get ddMMyyyyOrEmpty {
    if (this == null) return '—';
    return this!.ddMMyyyy;
  }
}
