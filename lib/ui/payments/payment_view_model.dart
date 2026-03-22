import 'package:flutter/material.dart';
import '../../data/models/payment.dart';
import '../../data/services/payment_api_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentApiService _service;
  final String token;
  final int? companyId;

  PaymentViewModel({required PaymentApiService service, required this.token, this.companyId})
      : _service = service;

  List<Payment> _payments = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;

  List<Payment> get payments => _payments;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      _payments = [];
      _currentPage = 1;
      _lastPage = 1;
      _loading = true;
    } else {
      _loadingMore = true;
    }
    _error = null;
    notifyListeners();
    try {
      final res = await _service.getPayments(token, companyId: companyId, page: _currentPage);
      if (reset) {
        _payments = res.payments;
      } else {
        _payments.addAll(res.payments);
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
}
