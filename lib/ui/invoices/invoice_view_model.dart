import 'package:flutter/material.dart';
import '../../data/models/invoice.dart';
import '../../data/services/invoice_api_service.dart';

class InvoiceViewModel extends ChangeNotifier {
  final InvoiceApiService _service;
  final String token;
  final int? companyId;

  InvoiceViewModel({required InvoiceApiService service, required this.token, this.companyId})
      : _service = service;

  List<Invoice> _invoices = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  String _activeTab = 'ALL';

  List<Invoice> get invoices => _invoices;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;
  String get activeTab => _activeTab;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      _invoices = [];
      _currentPage = 1;
      _lastPage = 1;
      _loading = true;
    } else {
      _loadingMore = true;
    }
    _error = null;
    notifyListeners();
    try {
      final status = _activeTab == 'ALL' ? null : _activeTab;
      final res = await _service.getInvoices(token, companyId: companyId, page: _currentPage, status: status);
      if (reset) {
        _invoices = res.invoices;
      } else {
        _invoices.addAll(res.invoices);
      }
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !hasMore) return;
    _currentPage++;
    await load(reset: false);
  }

  void setTab(String tab) {
    if (_activeTab == tab) return;
    _activeTab = tab;
    load();
  }
}
