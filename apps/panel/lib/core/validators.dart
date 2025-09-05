/// Validation utilities for form inputs
class Validators {
  /// Email validation regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Date format regex pattern (YYYY-MM-DD)
  static final RegExp _dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  /// Validates required text fields
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    
    return null;
  }

  /// Validates name fields (first name, last name)
  static String? validateName(String? value, {String? fieldName}) {
    final String? requiredCheck = validateRequired(value, fieldName: fieldName);
    if (requiredCheck != null) return requiredCheck;
    
    if (value!.trim().length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters long';
    }
    
    if (value.trim().length > 50) {
      return '${fieldName ?? 'Name'} must not exceed 50 characters';
    }
    
    return null;
  }

  /// Validates desk code format
  static String? validateDeskCode(String? value) {
    final String? requiredCheck = validateRequired(value, fieldName: 'Desk code');
    if (requiredCheck != null) return requiredCheck;
    
    final String trimmed = value!.trim().toUpperCase();
    
    if (trimmed.length < 1 || trimmed.length > 10) {
      return 'Desk code must be between 1 and 10 characters';
    }
    
    // Allow alphanumeric characters and basic punctuation
    if (!RegExp(r'^[A-Z0-9\-_]+$').hasMatch(trimmed)) {
      return 'Desk code can only contain letters, numbers, hyphens, and underscores';
    }
    
    return null;
  }

  /// Validates desk name
  static String? validateDeskName(String? value) {
    final String? requiredCheck = validateRequired(value, fieldName: 'Desk name');
    if (requiredCheck != null) return requiredCheck;
    
    if (value!.trim().length > 100) {
      return 'Desk name must not exceed 100 characters';
    }
    
    return null;
  }

  /// Validates date in YYYY-MM-DD format
  static String? validateDate(String? value, {String? fieldName}) {
    final String? requiredCheck = validateRequired(value, fieldName: fieldName ?? 'Date');
    if (requiredCheck != null) return requiredCheck;
    
    if (!_dateRegex.hasMatch(value!.trim())) {
      return '${fieldName ?? 'Date'} must be in YYYY-MM-DD format';
    }
    
    try {
      final List<String> parts = value.trim().split('-');
      final int year = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int day = int.parse(parts[2]);
      
      // Basic range validation
      if (year < 2020 || year > 2030) {
        return 'Year must be between 2020 and 2030';
      }
      
      if (month < 1 || month > 12) {
        return 'Month must be between 01 and 12';
      }
      
      if (day < 1 || day > 31) {
        return 'Day must be between 01 and 31';
      }
      
      // Validate the date is actually valid using DateTime
      final DateTime parsedDate = DateTime(year, month, day);
      if (parsedDate.year != year || 
          parsedDate.month != month || 
          parsedDate.day != day) {
        return 'Please enter a valid date';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date in YYYY-MM-DD format';
    }
  }

  /// Validates notes field (optional but with length limit)
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes are optional
    }
    
    if (value.trim().length > 500) {
      return 'Notes must not exceed 500 characters';
    }
    
    return null;
  }

  /// Validates that a date is not in the past
  static String? validateFutureDate(String? value, {String? fieldName}) {
    final String? dateCheck = validateDate(value, fieldName: fieldName);
    if (dateCheck != null) return dateCheck;
    
    try {
      final List<String> parts = value!.trim().split('-');
      final DateTime date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      
      final DateTime today = DateTime.now();
      final DateTime todayDate = DateTime(today.year, today.month, today.day);
      
      if (date.isBefore(todayDate)) {
        return '${fieldName ?? 'Date'} cannot be in the past';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validates that a date is today or in the future
  static String? validateTodayOrFutureDate(String? value, {String? fieldName}) {
    final String? dateCheck = validateDate(value, fieldName: fieldName);
    if (dateCheck != null) return dateCheck;
    
    try {
      final List<String> parts = value!.trim().split('-');
      final DateTime date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      
      final DateTime today = DateTime.now();
      final DateTime todayDate = DateTime(today.year, today.month, today.day);
      
      if (date.isBefore(todayDate)) {
        return '${fieldName ?? 'Date'} must be today or in the future';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }
}
