import 'package:flutter_test/flutter_test.dart';
import 'package:crater_app/ui/customers/customer_view_model.dart';
import 'package:crater_app/data/services/customer_api_service.dart';
import 'package:crater_app/data/models/customer.dart';

class MockCustomerApiService implements CustomerApiService {
  bool getCustomersCalled = false;
  bool createCustomerCalled = false;
  Map<String, dynamic>? lastCreatedData;
  
  @override
  String baseUrl = 'mock';

  @override
  Future<CustomerListResponse> getCustomers(String token, {int page = 1, String? displayName, String? contactName, String? phone, int? companyId}) async {
    getCustomersCalled = true;
    return CustomerListResponse(
      customers: [],
      total: 0,
      currentPage: 1,
      lastPage: 1,
    );
  }

  @override
  Future<Customer> getCustomer(String token, int id, {int? companyId}) async {
     throw UnimplementedError();
  }

  @override
  Future<Customer> createCustomer(String token, Map<String, dynamic> data, {int? companyId}) async {
    createCustomerCalled = true;
    lastCreatedData = data;
    return Customer(
      id: 1, 
      name: data['name'], 
      dueAmount: 0, 
      invoicesCount: 0
    );
  }
}

void main() {
  test('addCustomer calls createCustomer and then reloads', () async {
    final mockService = MockCustomerApiService();
    final viewModel = CustomerViewModel(service: mockService, token: 'token');
    
    // Initial load
    await viewModel.load();
    expect(mockService.getCustomersCalled, true);
    
    // Reset flag to verify reload
    mockService.getCustomersCalled = false;

    final data = {'name': 'Test Customer'};
    final success = await viewModel.addCustomer(data);

    expect(success, true);
    expect(mockService.createCustomerCalled, true);
    expect(mockService.lastCreatedData, data);
    expect(mockService.getCustomersCalled, true); // Should reload after add
  });

  test('addCustomer returns false on error', () async {
     // Override to throw error
     // Since I can't easily override method on instance without mockito, 
     // I'll create a failing mock class
     final failingService = FailingCustomerApiService();
     final viewModel = CustomerViewModel(service: failingService, token: 'token');

     final success = await viewModel.addCustomer({'name': 'Fail'});
     expect(success, false);
     expect(viewModel.error, isNotNull);
  });
}

class FailingCustomerApiService extends MockCustomerApiService {
  @override
  Future<Customer> createCustomer(String token, Map<String, dynamic> data, {int? companyId}) async {
    throw Exception('Failed to create');
  }
}
