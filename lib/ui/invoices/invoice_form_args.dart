import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../data/models/invoice_draft.dart';

class InvoiceFormArgs {
  final InvoiceDraft? draft;
  final File? scanFile;
  final XFile? xFile;

  const InvoiceFormArgs({this.draft, this.scanFile, this.xFile});
}
