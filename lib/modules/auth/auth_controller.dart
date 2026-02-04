// Auth Controller - Multi-Vendor Customer Authentication
// 
// Handles customer authentication for multi-vendor system:
// - Customer login with vendor context
// - Logout
// - Token management
// - Customer & Vendor data storage

import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../models/customer.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  // Current customer data
  final Rx<Customer?> currentCustomer = Rx<Customer?>(null);
  
  // Current vendor data
  final Rx<Vendor?> currentVendor = Rx<Vendor?>(null);
  
  // Loading & error states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadStoredData();
  }
  
  /// Load stored customer and vendor data
  void _loadStoredData() {
    currentCustomer.value = _storageService.getCustomer();
    currentVendor.value = _storageService.getVendor();
  }
  
  /// Customer Login - Multi-Vendor API
  /// POST /api/v1/customer/login
  Future<bool> login(String email, String password, {String? vendorSlug}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final requestData = {
        'email': email,
        'password': password,
      };
      
      // Add vendor_slug if provided (optional)
      if (vendorSlug != null && vendorSlug.isNotEmpty) {
        requestData['vendor_slug'] = vendorSlug;
      }
      
      final response = await _apiService.post(
        '/customer/login',
        data: requestData,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final loginResponse = CustomerLoginResponse.fromJson(response.data);
        
        if (loginResponse.success && loginResponse.token != null) {
          // Save token
          await _storageService.saveToken(loginResponse.token!);
          
          // Save customer data
          if (loginResponse.customer != null) {
            await _storageService.saveCustomer(loginResponse.customer!);
            currentCustomer.value = loginResponse.customer;
          }
          
          // Save vendor data
          if (loginResponse.vendor != null) {
            await _storageService.saveVendor(loginResponse.vendor!);
            currentVendor.value = loginResponse.vendor;
          }
          
          debugPrint('AuthController: Login successful for ${loginResponse.customer?.name}');
          debugPrint('AuthController: Vendor: ${loginResponse.vendor?.storeName}');
          debugPrint('AuthController: Discount: ${loginResponse.customer?.discountPercentage}%');
          
          return true;
        } else {
          errorMessage.value = loginResponse.message.isNotEmpty 
              ? loginResponse.message 
              : 'Login failed';
          return false;
        }
      } else {
        errorMessage.value = response.data?['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      debugPrint('AuthController: Login error: $e');
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Register - Not available for customers (vendors create customers)
  /// Customers cannot self-register in multi-vendor system
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    errorMessage.value = 'Customer registration is not available. Please contact your vendor.';
    return false;
  }
  
  /// Register Staff - Not available in customer app
  Future<bool> registerStaff({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String vendorEmail,
  }) async {
    errorMessage.value = 'Staff registration is not available in customer app.';
    return false;
  }
  
  /// Fetch customer profile from API
  /// GET /api/v1/customer/profile
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      
      final response = await _apiService.get('/customer/profile');
      
      if (response.statusCode == 200 && response.data != null) {
        final profileResponse = CustomerProfileResponse.fromJson(response.data);
        
        if (profileResponse.success) {
          // Update customer data
          if (profileResponse.customer != null) {
            await _storageService.saveCustomer(profileResponse.customer!);
            currentCustomer.value = profileResponse.customer;
          }
          
          // Update vendor data
          if (profileResponse.vendor != null) {
            await _storageService.saveVendor(profileResponse.vendor!);
            currentVendor.value = profileResponse.vendor;
          }
        }
      }
    } catch (e) {
      debugPrint('AuthController: Failed to fetch profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update customer profile
  /// PUT /api/v1/customer/profile
  Future<bool> updateProfile({
    String? name,
    String? mobileNumber,
    String? address,
    String? city,
    String? state,
    String? postalCode,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (mobileNumber != null) data['mobile_number'] = mobileNumber;
      if (address != null) data['address'] = address;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (postalCode != null) data['postal_code'] = postalCode;
      
      final response = await _apiService.put('/customer/profile', data: data);
      
      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['success'] ?? false;
        if (success) {
          // Refresh profile data
          await fetchProfile();
          return true;
        } else {
          errorMessage.value = response.data['message'] ?? 'Update failed';
          return false;
        }
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Change customer password
  /// PUT /api/v1/customer/change-password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _apiService.put(
        '/customer/change-password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final success = response.data['success'] ?? false;
        if (success) {
          Get.snackbar(
            'Success',
            'Password changed successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          errorMessage.value = response.data['message'] ?? 'Password change failed';
          return false;
        }
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Logout customer
  /// POST /api/v1/customer/logout
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Try to logout on server
      try {
        await _apiService.post('/customer/logout');
      } catch (e) {
        debugPrint('AuthController: Server logout failed: $e');
      }
      
      // Clear local data
      await _storageService.clearAuthData();
      currentCustomer.value = null;
      currentVendor.value = null;
      
      // Navigate to login
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Check if customer is authenticated
  bool get isAuthenticated => _storageService.isAuthenticated();
  
  /// Get customer's discount percentage
  double get customerDiscount => currentCustomer.value?.discountPercentage ?? 0;
  
  /// Get vendor store name
  String get vendorStoreName => currentVendor.value?.storeName ?? 'Store';
  
  /// Get vendor logo URL
  String? get vendorLogoUrl => currentVendor.value?.storeLogoUrl;
  
  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
