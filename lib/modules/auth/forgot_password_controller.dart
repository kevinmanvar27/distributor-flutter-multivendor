// Forgot Password Controller
//
// Handles the forgot password flow:
// - Send OTP to email
// - Verify OTP
// - Reset password
// - Resend OTP

import 'package:get/get.dart';
import '../../core/services/api_service.dart';

class ForgotPasswordController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Observable state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  
  // Store email and token across screens
  final RxString email = ''.obs;
  final RxString resetToken = ''.obs;
  
  // Resend OTP cooldown
  final RxInt resendCooldown = 0.obs;
  final RxBool canResendOtp = true.obs;

  /// Send OTP to email (Forgot Password)
  Future<bool> sendOtp(String userEmail) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      
      final response = await _apiService.post(
        '/forgot-password',
        data: {'email': userEmail},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        email.value = userEmail;
        successMessage.value = response.data?['message'] ?? 'OTP sent to your email';
        _startResendCooldown();
        return true;
      } else {
        errorMessage.value = response.data?['message'] ?? 'Failed to send OTP';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      
      final response = await _apiService.post(
        '/verify-otp',
        data: {
          'email': email.value,
          'otp': otp,
        },
      );
      
      // Debug: Print full response to see structure
      print('Verify OTP Response: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Check status field if present
        if (data['status'] == false) {
          errorMessage.value = data['message'] ?? 'Invalid OTP';
          return false;
        }
        
        // Extract token from response - check all possible locations
        String? token;
        if (data['token'] != null) {
          token = data['token'].toString();
        } else if (data['data']?['token'] != null) {
          token = data['data']['token'].toString();
        } else if (data['reset_token'] != null) {
          token = data['reset_token'].toString();
        } else if (data['data']?['reset_token'] != null) {
          token = data['data']['reset_token'].toString();
        } else if (data['password_reset_token'] != null) {
          token = data['password_reset_token'].toString();
        }
        
        print('Extracted token: $token');
        
        if (token != null && token.isNotEmpty) {
          resetToken.value = token;
          successMessage.value = data['message'] ?? 'OTP verified successfully';
          return true;
        } else {
          // If API returns success status but no token, proceed anyway
          // The token might be managed server-side
          if (data['status'] == true || data['success'] == true) {
            // Use OTP as fallback token identifier
            resetToken.value = otp;
            successMessage.value = data['message'] ?? 'OTP verified successfully';
            return true;
          }
          errorMessage.value = data['message'] ?? 'Invalid response from server';
          return false;
        }
      } else {
        errorMessage.value = response.data?['message'] ?? 'OTP verification failed';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      
      final response = await _apiService.post(
        '/reset-password',
        data: {
          'email': email.value,
          'token': resetToken.value,
          'password': newPassword,
          'password_confirmation': confirmPassword,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Check status field if present
        if (data['status'] == false) {
          errorMessage.value = data['message'] ?? 'Failed to reset password';
          return false;
        }
        
        successMessage.value = data['message'] ?? 'Password reset successfully';
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
          errorMessage.value = response.data?['message'] ?? 'Failed to reset password';
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

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (!canResendOtp.value) {
      errorMessage.value = 'Please wait ${resendCooldown.value} seconds before resending';
      return false;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      
      final response = await _apiService.post(
        '/resend-otp',
        data: {'email': email.value},
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage.value = response.data?['message'] ?? 'OTP resent successfully';
        _startResendCooldown();
        return true;
      } else {
        errorMessage.value = response.data?['message'] ?? 'Failed to resend OTP';
        return false;
      }
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Start resend cooldown timer (60 seconds)
  void _startResendCooldown() {
    canResendOtp.value = false;
    resendCooldown.value = 60;
    
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendCooldown.value--;
      
      if (resendCooldown.value <= 0) {
        canResendOtp.value = true;
        return false; // Stop the loop
      }
      return true; // Continue the loop
    });
  }

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Clear success message
  void clearSuccess() {
    successMessage.value = '';
  }

  /// Clear all messages
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Reset controller state
  void resetState() {
    email.value = '';
    resetToken.value = '';
    errorMessage.value = '';
    successMessage.value = '';
    resendCooldown.value = 0;
    canResendOtp.value = true;
  }
}
