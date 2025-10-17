// Create this as a separate file: services/profile_service.dart
abstract class ProfileService {
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> getCustomerOrders();
  Future<void> logout();
}