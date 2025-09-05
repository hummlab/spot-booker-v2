import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converter for Firestore Timestamp to/from DateTime
class TimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? dateTime) {
    return dateTime != null ? Timestamp.fromDate(dateTime) : null;
  }
}

/// Converter for date strings in YYYY-MM-DD format to/from DateTime (date only)
class DateYmdConverter implements JsonConverter<DateTime?, String?> {
  const DateYmdConverter();

  @override
  DateTime? fromJson(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    
    // Strict format validation: must be exactly YYYY-MM-DD
    final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(dateString)) {
      throw FormatException('Invalid date format: $dateString. Expected YYYY-MM-DD');
    }
    
    try {
      final List<String> parts = dateString.split('-');
      final int year = int.parse(parts[0]);
      final int month = int.parse(parts[1]);
      final int day = int.parse(parts[2]);
      
      // Validate the date is actually valid
      final DateTime parsedDate = DateTime(year, month, day);
      if (parsedDate.year != year || parsedDate.month != month || parsedDate.day != day) {
        throw FormatException('Invalid date: $dateString');
      }
      
      return parsedDate;
    } catch (e) {
      if (e is FormatException) rethrow;
      throw FormatException('Invalid date format: $dateString');
    }
  }

  @override
  String? toJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }
    
    final String year = dateTime.year.toString().padLeft(4, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    
    return '$year-$month-$day';
  }
}

/// Utility function to format DateTime to YYYY-MM-DD string
String formatDateYmd(DateTime date) {
  final String year = date.year.toString().padLeft(4, '0');
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  
  return '$year-$month-$day';
}

/// Utility function to parse YYYY-MM-DD string to DateTime
DateTime parseDateYmd(String dateString) {
  // Strict format validation: must be exactly YYYY-MM-DD
  final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!dateRegex.hasMatch(dateString)) {
    throw FormatException('Invalid date format: $dateString. Expected YYYY-MM-DD');
  }
  
  final List<String> parts = dateString.split('-');
  final int year = int.parse(parts[0]);
  final int month = int.parse(parts[1]);
  final int day = int.parse(parts[2]);
  
  // Validate the date is actually valid
  final DateTime parsedDate = DateTime(year, month, day);
  if (parsedDate.year != year || parsedDate.month != month || parsedDate.day != day) {
    throw FormatException('Invalid date: $dateString');
  }
  
  return parsedDate;
}

/// Utility function to get today's date in YYYY-MM-DD format
String getTodayYmd() {
  return formatDateYmd(DateTime.now());
}

/// Utility function to check if a date string is valid YYYY-MM-DD format
bool isValidDateYmd(String dateString) {
  // Strict format validation: must be exactly YYYY-MM-DD
  final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  if (!dateRegex.hasMatch(dateString)) {
    return false;
  }
  
  try {
    final List<String> parts = dateString.split('-');
    final int year = int.parse(parts[0]);
    final int month = int.parse(parts[1]);
    final int day = int.parse(parts[2]);
    
    // Basic range validation
    if (year < 1900 || year > 2100) return false;
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    
    // Validate the date is actually valid using DateTime
    final DateTime parsedDate = DateTime(year, month, day);
    return parsedDate.year == year &&
        parsedDate.month == month &&
        parsedDate.day == day;
  } catch (e) {
    return false;
  }
}
