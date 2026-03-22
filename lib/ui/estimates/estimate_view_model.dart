import 'package:flutter/material.dart';
import '../../data/models/estimate.dart';
import '../../data/services/estimate_api_service.dart';

class EstimateViewModel extends ChangeNotifier {
  final EstimateApiService _service;
  final String token;
  final int? companyId;

  EstimateViewModel({required EstimateApiService service, required this.token, this.companyId})
      : _service = service;

  List<Estimate> _estimates = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  String _activeTab = 'ALL';

  List<Estimate> get estimates => _estimates;
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _currentPage < _lastPage;
  String get activeTab => _activeTab;

  Future<void> load({bool reset = true}) async {
    if (reset) {
      _estimates = [];
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
      final res = await _service.getEstimates(token, companyId: companyId, page: _currentPage, status: status);
      if (reset) {
        _estimates = res.estimates;
      } else {
        _estimates.addAll(res.estimates);
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
