// Auth Controller
// 
// Handles authentication logic:
// - Login with email/password
// - Register new user
// - Register staff with vendor verification
// - Logout
// - Token management
// - User data fetching

import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../models/user.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }
  
  void _loadCurrentUser() {
    final userData = _storageService.getUser();
    if (userData != null) {
      currentUser.value = User.fromJson(userData);
    }
  }
  
  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _apiService.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Extract token from response
        // API may return token in different formats
        String? token;
        if (data['token'] != null) {
          token = data['token'];
        } else if (data['access_token'] != null) {
          token = data['access_token'];
        } else if (data['data']?['token'] != null) {
          token = data['data']['token'];
        }
        
        if (token != null) {
          // Save token
          await _storageService.saveToken(token);
          
          // Fetch user data
          await _fetchAndSaveUser();
          
          return true;
        } else {
          errorMessage.value = 'Invalid response from server';
          return false;
        }
      } else {
        errorMessage.value = response.data?['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _apiService.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (phone != null) 'phone': phone,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Some APIs auto-login after registration
        String? token;
        if (data['token'] != null) {
          token = data['token'];
        } else if (data['access_token'] != null) {
          token = data['access_token'];
        } else if (data['data']?['token'] != null) {
          token = data['data']['token'];
        }
        
        if (token != null) {
          await _storageService.saveToken(token);
          await _fetchAndSaveUser();
          return true;
        }
        
        // If no token, registration successful but needs login
        Get.snackbar(
          'Success',
          'Registration successful. Please login.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        // Handle validation errors
        if (response.data?['errors'] != null) {
          final errors = response.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          errorMessage.value = firstError is List 
              ? firstError.first.toString() 
              : firstError.toString();
        } else {
          errorMessage.value = response.data?['message'] ?? 'Registration failed';
        }
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Register a new staff member with vendor verification
  Future<bool> registerStaff({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String vendorEmail,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // First, verify vendor email exists
      final verifyResponse = await _apiService.post(
        '/verify-vendor',
        data: {
          'vendor_email': vendorEmail,
        },
      );
      
      // Check if vendor verification failed
      if (verifyResponse.statusCode != 200 || verifyResponse.data?['success'] != true) {
        errorMessage.value = 'Vendor email not found or invalid. Please check with your vendor.';
        return false;
      }
      
      // Get vendor ID from verification response
      final vendorId = verifyResponse.data?['vendor_id'] ?? 
                       verifyResponse.data?['data']?['vendor_id'];
      
      if (vendorId == null) {
        errorMessage.value = 'Could not retrieve vendor information. Please try again.';
        return false;
      }
      
      // Register staff with vendor ID
      final response = await _apiService.post(
        '/register-staff',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'vendor_id': vendorId,
          'vendor_email': vendorEmail,
          'user_role': 'staff',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Extract token if auto-login after registration
        String? token;
        if (data['token'] != null) {
          token = data['token'];
        } else if (data['access_token'] != null) {
          token = data['access_token'];
        } else if (data['data']?['token'] != null) {
          token = data['data']['token'];
        }
        
        if (token != null) {
          await _storageService.saveToken(token);
          await _fetchAndSaveUser();
          
          Get.snackbar(
            'Success',
            'Staff registration successful!',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        }
        
        // If no token, registration successful but needs login
        Get.snackbar(
          'Success',
          'Staff registration successful. Please login.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        // Handle validation errors
        if (response.data?['errors'] != null) {
          final errors = response.data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          errorMessage.value = firstError is List 
              ? firstError.first.toString() 
              : firstError.toString();
        } else {
          errorMessage.value = response.data?['message'] ?? 'Staff registration failed';
        }
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Fetch current user data from API
  Future<void> _fetchAndSaveUser() async {
    try {
      final response = await _apiService.get('/user');
      
      if (response.statusCode == 200 && response.data != null) {
        // Handle different response formats
        final userData = response.data['data'] ?? response.data['user'] ?? response.data;
        final user = User.fromJson(userData);
        await _storageService.saveUser(user.toJson());
        currentUser.value = user;
      }
    } catch (e) {
      // User fetch failed, but login was successful
      // User can continue using the app
      debugPrint('Failed to fetch user: $e');
    }
  }
  
  /// Logout current user
  Future<void> logout() async {
    try {
      isLoading.value = true;
      
      // Try to logout on server
      try {
        await _apiService.post('/logout');
      } catch (e) {
        // Server logout failed, but continue with local logout
        debugPrint('Server logout failed: $e');
      }
      
      // Clear local data
      await _storageService.clearAuthData();
      currentUser.value = null;
      
      // Navigate to login
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Check if user is authenticated
  bool get isAuthenticated => _storageService.isAuthenticated();
  
  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}
