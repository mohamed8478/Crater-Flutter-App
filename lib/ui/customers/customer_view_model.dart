import 'package:flutter/material.dart';
import '../../data/models/customer.dart';
import '../../data/services/customer_api_service.dart';

class CustomerViewModel extends ChangeNotifier {
  final CustomerApiService _service;
  final String token;
  final int? companyId;

  CustomerViewModel({required CustomerApiService service, required this.token, this.companyId})
      : _service = service;

  List<Customer> _customers = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;

  String _searchName = '';

  List<Customer> get customers => _customers;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      _customers = [];
      _currentPage = 1;
      _lastPage = 1;
      _loading = true;
    } else {
      _loadingMore = true;
    }
    _error = null;
    notifyListeners();
    try {
      final res = await _service.getCustomers(
        token,
        companyId: companyId,
        page: _currentPage,
        displayName: _searchName.isEmpty ? null : _searchName,
      );
      if (reset) {
        _customers = res.customers;
      } else {
        _customers.addAll(res.customers);
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

  void search(String name) {
    _searchName = name;
    load();
  }

  Future<bool> addCustomer(Map<String, dynamic> data) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createCustomer(token, data, companyId: companyId);
      await load(reset: true);
      return true;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
