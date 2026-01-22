// Form Validators
// 
// Contains all form validation functions used across the app.
// Each validator returns null if valid, or an error message string if invalid.
// 
// TODO: Add more validators as needed
// TODO: Customize error messages for your app

class Validators {
  // Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  // Phone regex pattern (basic international format)
  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9]{10,15}$',
  );
  
  // Password requirements
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  
  /// Validate email address
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  /// Validate password
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    if (value.length > maxPasswordLength) {
      return 'Password must be less than $maxPasswordLength characters';
    }
    return null;
  }
  
  /// Validate password confirmation
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    };
  }
  
  /// Validate required field
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validate name (letters, spaces, hyphens only)
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Name must be less than 100 characters';
    }
    return null;
  }
  
  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!_phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }
  
  /// Validate optional phone number
  static String? optionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return phone(value);
  }
  
  /// Validate minimum length
  static String? Function(String?) minLength(int length, [String fieldName = 'This field']) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '$fieldName is required';
      }
      if (value.length < length) {
        return '$fieldName must be at least $length characters';
      }
      return null;
    };
  }
  
  /// Validate maximum length
  static String? Function(String?) maxLength(int length, [String fieldName = 'This field']) {
    return (String? value) {
      if (value != null && value.length > length) {
        return '$fieldName must be less than $length characters';
      }
      return null;
    };
  }
  
  /// Validate numeric value
  static String? numeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return '$fieldName must be a valid number';
    }
    return null;
  }
  
  /// Validate positive number
  static String? positiveNumber(String? value, [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName must be a valid number';
    }
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }
    return null;
  }
  
  /// Validate quantity (positive integer)
  static String? quantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantity is required';
    }
    final number = int.tryParse(value);
    if (number == null) {
      return 'Quantity must be a whole number';
    }
    if (number < 1) {
      return 'Quantity must be at least 1';
    }
    if (number > 9999) {
      return 'Quantity cannot exceed 9999';
    }
    return null;
  }
  
  /// Combine multiple validators
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
