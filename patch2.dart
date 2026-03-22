import 'dart:io';

void main() {
  final files = [
    'lib/data/models/customer.dart',
    'lib/data/models/estimate.dart',
    'lib/data/models/expense.dart',
    'lib/data/models/invoice.dart',
    'lib/data/models/item.dart',
    'lib/data/models/payment.dart',
    'lib/ui/dashboard/dashboard_screen.dart'
  ];

  for (final file in files) {
    var content = File(file).readAsStringSync();
    
    if (!content.contains('parsers.dart')) {
      if (file.contains('/dashboard/')) {
        content = "import '../../data/models/parsers.dart';\n" + content;
      } else {
        content = "import 'parsers.dart';\n" + content;
      }
    }

    content = content.replaceAllMapped(RegExp(r"\(\s*json\[\s*'(.*?)'\s*\]\s*\?\?\s*0\s*\)\s*/\s*100\.0"), (m) => "parseAmount(json['${m.group(1)}'])");
    content = content.replaceAllMapped(RegExp(r"\(\(\s*json\[\s*'(.*?)'\s*\]\s*\?\?\s*0\s*\)\s*as\s*num\)\.toDouble\(\)\s*/\s*100\.0"), (m) => "parseAmount(json['${m.group(1)}'])");
    content = content.replaceAllMapped(RegExp(r"\(\s*json\[\s*'(.*?)'\s*\]\s*\?\?\s*0\s*\)\.toDouble\(\)"), (m) => "parseDouble(json['${m.group(1)}'])");
    content = content.replaceAllMapped(RegExp(r"\(\s*inv\[\s*'(.*?)'\s*\]\s*\?\?\s*0\s*\)\s*/\s*100\.0"), (m) => "parseAmount(inv['${m.group(1)}'])");

    File(file).writeAsStringSync(content);
    print('Patched ' + file);
  }
}
