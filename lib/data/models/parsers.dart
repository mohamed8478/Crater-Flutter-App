
double parseAmount(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble() / 100.0;
  if (value is String) return (double.tryParse(value) ?? 0.0) / 100.0;
  return 0.0;
}

double parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

