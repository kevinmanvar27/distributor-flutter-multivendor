// Profile Controller
// 
// Manages user profile state and operations:
// - Load and display user information
// - Edit profile functionality
// - Update profile avatar
// - Change password
// - Delete account
// - Logout with confirmation

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' hide Response;
import 'package:image_picker/image_picker.dart';
import '../../models/user.dart';
import '../../core/services/api_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_theme.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _imagePicker = ImagePicker();

  // ══════════════════════════════════════════════════════════════════════════
  // Reactive State
  // ══════════════════════════════════════════════════════════════════════════

  // Store Customer and Vendor separately for proper data access
  final Rx<Customer?> customer = Rx<Customer?>(null);
  final Rx<Vendor?> vendor = Rx<Vendor?>(null);
  
  // Keep legacy user for backward compatibility
  final Rx<User?> user = Rx<User?>(null);
  
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploadingAvatar = false.obs;
  final RxBool isChangingPassword = false.obs;
  final RxBool isDeletingAccount = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Edit mode state
  final RxBool isEditMode = false.obs;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final mobileNumberController = TextEditingController();

  // Change password controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Delete account controllers
  final deletePasswordController = TextEditingController();
  final deleteReasonController = TextEditingController();

  // ══════════════════════════════════════════════════════════════════════════
  // Computed Properties
  // ══════════════════════════════════════════════════════════════════════════

  bool get isLoggedIn => customer.value != null;
  String get userName => customer.value?.name ?? 'Guest';
  String get userEmail => customer.value?.email ?? '';
  String get userPhone => customer.value?.mobileNumber ?? '';
  String get userAddress => customer.value?.address ?? '';
  String get userCity => customer.value?.city ?? '';
  String get userState => customer.value?.state ?? '';
  String get userPostalCode => customer.value?.postalCode ?? '';
  String get userDateOfBirth => ''; // Not in current API response
  String get userMobileNumber => customer.value?.mobileNumber ?? '';
  String? get userAvatarUrl => vendor.value?.storeLogoUrl;
  String get userRole => 'customer';
  String get discountPercentage => customer.value?.discountPercentage ?? '0';
  bool get isApproved => true; // Assuming approved if logged in
  
  // Vendor info getters
  String get storeName => vendor.value?.storeName ?? '';
  String get businessPhone => vendor.value?.businessPhone ?? '';
  String get businessEmail => vendor.value?.businessEmail ?? '';
  
  String get userInitials {
    final name = customer.value?.name;
    // Return default if name is null or empty
    if (name == null || name.trim().isEmpty) {
      return 'G';
    }
    final trimmedName = name.trim();
    final parts = trimmedName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    // Single name - take first 1 or 2 characters
    if (trimmedName.length >= 2) {
      return trimmedName.substring(0, 2).toUpperCase();
    }
    return trimmedName.substring(0, 1).toUpperCase();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Lifecycle
  // ══════════════════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dateOfBirthController.dispose();
    mobileNumberController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    deletePasswordController.dispose();
    deleteReasonController.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Profile Operations
  // ══════════════════════════════════════════════════════════════════════════

  /// Load user profile from storage or API
  Future<void> loadUserProfile() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // First, try to load from local storage (cached)
      final cachedUser = _loadUserFromStorage();
      if (cachedUser != null) {
        // Convert cached User to Customer for display
        customer.value = Customer(
          id: cachedUser.id,
          name: cachedUser.name,
          email: cachedUser.email,
          mobileNumber: cachedUser.mobileNumber,
          address: cachedUser.address,
          discountPercentage: cachedUser.discountPercentage,
        );
        user.value = cachedUser;
        _populateEditFields();
        debugPrint('Loaded user from cache: ${customer.value?.name}');
      }

      // Then fetch fresh data from API
      await _fetchUserFromApi();
    } catch (e) {
      debugPrint('loadUserProfile Error: $e');
      if (customer.value == null) {
        hasError.value = true;
        errorMessage.value = 'Failed to load profile: $e';
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile from /customer/profile API
  Future<void> _fetchUserFromApi() async {
    try {
      // Use customer profile API
      debugPrint('Fetching profile from API...');
      final response = await _apiService.get('/customer/profile');
      debugPrint('Profile API Response: ${response.statusCode}');
      debugPrint('Profile API Data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        // Parse using the new Userprofile model
        final userprofile = Userprofile.fromJson(response.data);
        debugPrint('Parsed Userprofile: success=${userprofile.success}, data=${userprofile.data != null}');
        
        if (userprofile.success && userprofile.data != null) {
          // Store customer and vendor separately
          customer.value = userprofile.data!.customer;
          vendor.value = userprofile.data!.vendor;
          
          debugPrint('Customer Loaded: ${customer.value?.name}, ${customer.value?.email}');
          debugPrint('Vendor Loaded: ${vendor.value?.storeName}');
          
          // Also update legacy user for backward compatibility
          if (customer.value != null) {
            user.value = User.fromCustomer(customer.value!);
            _populateEditFields();
            _saveUserToStorage(user.value!);
          }
        } else {
          debugPrint('Profile API returned success=false or data is null');
        }
      } else {
        debugPrint('Profile API failed: statusCode=${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('Profile API Error: $e');
      debugPrint('Stack trace: $stackTrace');
      // Silent fail if we have cached data
      if (customer.value == null) {
        rethrow;
      }
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Edit Profile
  // ══════════════════════════════════════════════════════════════════════════

  /// Enter edit mode
  void enterEditMode() {
    _populateEditFields();
    isEditMode.value = true;
  }

  /// Cancel edit mode
  void cancelEditMode() {
    _populateEditFields();
    isEditMode.value = false;
  }

  /// Populate edit fields with current user data
  void _populateEditFields() {
    nameController.text = customer.value?.name ?? '';
    emailController.text = customer.value?.email ?? '';
    phoneController.text = customer.value?.mobileNumber ?? '';
    addressController.text = customer.value?.address ?? '';
    dateOfBirthController.text = userDateOfBirth;
    mobileNumberController.text = customer.value?.mobileNumber ?? '';
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    if (!_validateEditFields()) return;

    isSaving.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final updateData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'date_of_birth': dateOfBirthController.text.trim(),
        'address': addressController.text.trim(),
        'mobile_number': mobileNumberController.text.trim(),
      };

      // Use customer profile API for update
      final response = await _apiService.put('/customer/profile', data: updateData);

      if (response.statusCode == 200) {
        // Exit edit mode first
        isEditMode.value = false;
        
        // Fetch fresh profile data from API to ensure consistency
        await _fetchUserFromApi();
        
        // Re-populate fields with updated data
        _populateEditFields();
        
        _showSnackbar('Profile Updated', 'Your profile has been updated successfully');
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to update profile. Please try again.';
      _showSnackbar('Update Failed', errorMessage.value, isError: true);
    } finally {
      isSaving.value = false;
    }
  }

  /// Validate edit fields
  bool _validateEditFields() {
    if (nameController.text.trim().isEmpty) {
      _showSnackbar('Validation Error', 'Name is required', isError: true);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showSnackbar('Validation Error', 'Email is required', isError: true);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showSnackbar('Validation Error', 'Please enter a valid email', isError: true);
      return false;
    }
    if (mobileNumberController.text.trim().isEmpty) {
      _showSnackbar('Validation Error', 'Mobile number is required', isError: true);
      return false;
    }
    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Avatar Operations
  // ══════════════════════════════════════════════════════════════════════════

  /// Pick and upload avatar image
  Future<void> pickAndUploadAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return;

      await uploadAvatar(File(image.path));
    } catch (e) {
      _showSnackbar('Error', 'Failed to pick image', isError: true);
    }
  }

  /// Take photo and upload avatar
  Future<void> takePhotoAndUploadAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return;

      await uploadAvatar(File(image.path));
    } catch (e) {
      _showSnackbar('Error', 'Failed to take photo', isError: true);
    }
  }

  /// Upload avatar to server
  Future<void> uploadAvatar(File imageFile) async {
    isUploadingAvatar.value = true;

    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // POST request with avatar field - token added automatically by interceptor
      final response = await _apiService.post(
        '/profile/avatar',
        data: formData,
        options: Options(
          headers: {},
        ),
      );

      if (response.statusCode == 200) {
        // Refresh profile to get updated avatar
        await _fetchUserFromApi();
        _showSnackbar('Success', 'Profile picture updated successfully');
      } else {
        throw Exception('Failed to upload avatar');
      }
    } catch (e) {
      _showSnackbar('Upload Failed', 'Failed to upload profile picture', isError: true);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  /// Remove avatar from server
  Future<void> removeAvatar() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isUploadingAvatar.value = true;

    try {
      // Get token from storage
      final token = _storageService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      // POST request with token field for deletion
      final response = await _apiService.post(
        '/profile/avatar',
        data: {
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        // Refresh profile to get updated data
        await _fetchUserFromApi();
        _showSnackbar('Success', 'Profile picture removed successfully');
      } else {
        throw Exception('Failed to remove avatar');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to remove profile picture', isError: true);
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  /// Show avatar options bottom sheet
  void showAvatarOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLG)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Profile Picture',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: AppTheme.spacingMD),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppTheme.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickAndUploadAvatar();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppTheme.primaryColor),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                takePhotoAndUploadAvatar();
              },
            ),
            if (userAvatarUrl != null) ...[
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                title: const Text('Remove Picture', style: TextStyle(color: AppTheme.errorColor)),
                onTap: () {
                  Get.back();
                  removeAvatar();
                },
              ),
            ],
            const SizedBox(height: AppTheme.spacingSM),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Change Password
  // ══════════════════════════════════════════════════════════════════════════

  /// Show change password dialog
  void showChangePasswordDialog() {
    // Clear previous values
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMD),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMD),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => TextButton(
            onPressed: isChangingPassword.value ? null : () => changePassword(),
            child: isChangingPassword.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Change'),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Change password
  Future<void> changePassword() async {
    // Validate
    if (currentPasswordController.text.isEmpty) {
      _showSnackbar('Validation Error', 'Current password is required', isError: true);
      return;
    }
    if (newPasswordController.text.isEmpty) {
      _showSnackbar('Validation Error', 'New password is required', isError: true);
      return;
    }
    if (newPasswordController.text.length < 6) {
      _showSnackbar('Validation Error', 'Password must be at least 6 characters', isError: true);
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      _showSnackbar('Validation Error', 'Passwords do not match', isError: true);
      return;
    }

    isChangingPassword.value = true;

    try {
      // Use customer change-password API
      final response = await _apiService.put(
        '/customer/change-password',
        data: {
          'current_password': currentPasswordController.text,
          'password': newPasswordController.text,
          'password_confirmation': confirmPasswordController.text,
        },
      );

      if (response.statusCode == 200) {
        Get.back(); // Close dialog
        _showSnackbar('Success', 'Password changed successfully');
        
        // Clear controllers
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to change password. Please check your current password.', isError: true);
    } finally {
      isChangingPassword.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Delete Account
  // ══════════════════════════════════════════════════════════════════════════

  /// Show delete account dialog
  void showDeleteAccountDialog() {
    // Clear previous values
    deletePasswordController.clear();
    deleteReasonController.clear();

    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.errorColor,
              size: 28,
            ),
            SizedBox(width: AppTheme.spacingSM),
            Text('Delete Account'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account? This action cannot be undone.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: AppTheme.spacingMD),
              Text(
                'The following data will be permanently deleted:',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSM),
              _buildDeleteDataItem('Your profile information'),
              _buildDeleteDataItem('Order history'),
              _buildDeleteDataItem('Saved addresses'),
              _buildDeleteDataItem('Wishlist items'),
              _buildDeleteDataItem('Payment methods'),
              const SizedBox(height: AppTheme.spacingMD),
              TextField(
                controller: deletePasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingMD),
              TextField(
                controller: deleteReasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for leaving (optional)',
                  prefixIcon: Icon(Icons.comment_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => TextButton(
            onPressed: isDeletingAccount.value ? null : () => deleteAccount(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: isDeletingAccount.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Delete Account'),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildDeleteDataItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.remove, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingSM),
          Text(text, style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  /// Delete account
  Future<void> deleteAccount() async {
    if (deletePasswordController.text.isEmpty) {
      _showSnackbar('Validation Error', 'Password is required', isError: true);
      return;
    }

    isDeletingAccount.value = true;

    try {
      final response = await _apiService.delete(
        '/customer/account',
        data: {
          'password': deletePasswordController.text,
          'reason': deleteReasonController.text,
        },
      );

      if (response.statusCode == 200) {
        Get.back(); // Close dialog
        await logout();
        _showSnackbar('Account Deleted', 'Your account has been permanently deleted');
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to delete account. Please check your password.', isError: true);
    } finally {
      isDeletingAccount.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Logout
  // ══════════════════════════════════════════════════════════════════════════

  /// Show logout confirmation dialog
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // Clear local data
      await _storageService.clearAll();
      customer.value = null;
      vendor.value = null;
      user.value = null;

      // Navigate to login
      Get.offAllNamed('/login');
    } catch (e) {
      _showSnackbar('Error', 'Failed to logout', isError: true);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Storage Operations
  // ══════════════════════════════════════════════════════════════════════════

  /// Load user from local storage
  User? _loadUserFromStorage() {
    try {
      final userJson = _storageService.getUser();
      if (userJson != null) {
        return User.fromJson(userJson);
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }
    return null;
  }

  /// Save user to local storage
  void _saveUserToStorage(User user) {
    try {
      _storageService.saveUser(user.toJson());
    } catch (e) {
      debugPrint('Error saving user to storage: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Helpers
  // ══════════════════════════════════════════════════════════════════════════

  /// Show snackbar message
  void _showSnackbar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      borderRadius: AppTheme.radiusMD,
      duration: const Duration(seconds: 3),
    );
  }
}
