import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('TimestampConverter', () {
    const TimestampConverter converter = TimestampConverter();

    test('should convert DateTime to Timestamp', () {
      final DateTime dateTime = DateTime(2024, 1, 15, 10, 30, 45);
      final Timestamp? timestamp = converter.toJson(dateTime);
      
      expect(timestamp, isNotNull);
      expect(timestamp!.toDate(), equals(dateTime));
    });

    test('should convert Timestamp to DateTime', () {
      final DateTime originalDateTime = DateTime(2024, 1, 15, 10, 30, 45);
      final Timestamp timestamp = Timestamp.fromDate(originalDateTime);
      final DateTime? convertedDateTime = converter.fromJson(timestamp);
      
      expect(convertedDateTime, isNotNull);
      expect(convertedDateTime, equals(originalDateTime));
    });

    test('should handle null DateTime', () {
      final Timestamp? timestamp = converter.toJson(null);
      expect(timestamp, isNull);
    });

    test('should handle null Timestamp', () {
      final DateTime? dateTime = converter.fromJson(null);
      expect(dateTime, isNull);
    });
  });

  group('DateYmdConverter', () {
    const DateYmdConverter converter = DateYmdConverter();

    test('should convert DateTime to YYYY-MM-DD string', () {
      final DateTime dateTime = DateTime(2024, 1, 15);
      final String? dateString = converter.toJson(dateTime);
      
      expect(dateString, equals('2024-01-15'));
    });

    test('should convert YYYY-MM-DD string to DateTime', () {
      const String dateString = '2024-01-15';
      final DateTime? dateTime = converter.fromJson(dateString);
      
      expect(dateTime, isNotNull);
      expect(dateTime!.year, equals(2024));
      expect(dateTime.month, equals(1));
      expect(dateTime.day, equals(15));
    });

    test('should handle null DateTime', () {
      final String? dateString = converter.toJson(null);
      expect(dateString, isNull);
    });

    test('should handle null string', () {
      final DateTime? dateTime = converter.fromJson(null);
      expect(dateTime, isNull);
    });

    test('should handle empty string', () {
      final DateTime? dateTime = converter.fromJson('');
      expect(dateTime, isNull);
    });

    test('should throw on invalid date format', () {
      expect(
        () => converter.fromJson('invalid-date'),
        throwsA(isA<FormatException>()),
      );
      
      expect(
        () => converter.fromJson('2024/01/15'),
        throwsA(isA<FormatException>()),
      );
      
      expect(
        () => converter.fromJson('2024-1-15'),
        throwsA(isA<FormatException>()),
      );
      
      expect(
        () => converter.fromJson('not-a-date'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Utility Functions', () {
    test('formatDateYmd should format DateTime correctly', () {
      final DateTime dateTime = DateTime(2024, 1, 15);
      final String formatted = formatDateYmd(dateTime);
      
      expect(formatted, equals('2024-01-15'));
    });

    test('formatDateYmd should pad single digits', () {
      final DateTime dateTime = DateTime(2024, 3, 5);
      final String formatted = formatDateYmd(dateTime);
      
      expect(formatted, equals('2024-03-05'));
    });

    test('parseDateYmd should parse date string correctly', () {
      final DateTime parsed = parseDateYmd('2024-01-15');
      
      expect(parsed.year, equals(2024));
      expect(parsed.month, equals(1));
      expect(parsed.day, equals(15));
    });

    test('parseDateYmd should throw on invalid format', () {
      expect(
        () => parseDateYmd('invalid-date'),
        throwsA(isA<FormatException>()),
      );
      
      expect(
        () => parseDateYmd('2024-1-15'),
        throwsA(isA<FormatException>()),
      );
      
      expect(
        () => parseDateYmd('not-a-date'),
        throwsA(isA<FormatException>()),
      );
    });

    test('getTodayYmd should return today\'s date', () {
      final DateTime now = DateTime.now();
      final String today = getTodayYmd();
      final String expected = formatDateYmd(now);
      
      expect(today, equals(expected));
    });

    test('isValidDateYmd should validate date strings correctly', () {
      expect(isValidDateYmd('2024-01-15'), isTrue);
      expect(isValidDateYmd('2024-12-31'), isTrue);
      expect(isValidDateYmd('2024-02-29'), isTrue); // Leap year
      
      expect(isValidDateYmd('invalid-date'), isFalse);
      expect(isValidDateYmd('2024-1-15'), isFalse);
      expect(isValidDateYmd('2024/01/15'), isFalse);
      expect(isValidDateYmd('2024-13-01'), isFalse);
      expect(isValidDateYmd('2024-01-32'), isFalse);
      expect(isValidDateYmd('2023-02-29'), isFalse); // Not a leap year
    });
  });
}
