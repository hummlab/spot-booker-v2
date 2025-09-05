import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserDayLock', () {
    late UserDayLock testLock;
    late Map<String, dynamic> testJson;

    setUp(() {
      final DateTime now = DateTime.now();
      
      testLock = UserDayLock(
        id: 'user-789_2024-01-15',
        userId: 'user-789',
        date: '2024-01-15',
        reservationId: 'reservation-456',
        deskId: 'desk-123',
        createdAt: now,
      );

      testJson = <String, dynamic>{
        'id': 'user-789_2024-01-15',
        'userId': 'user-789',
        'date': '2024-01-15',
        'reservationId': 'reservation-456',
        'deskId': 'desk-123',
        'createdAt': Timestamp.fromDate(now),
      };
    });

    test('should serialize to JSON correctly', () {
      final Map<String, dynamic> json = testLock.toJson();
      
      expect(json['id'], equals('user-789_2024-01-15'));
      expect(json['userId'], equals('user-789'));
      expect(json['date'], equals('2024-01-15'));
      expect(json['reservationId'], equals('reservation-456'));
      expect(json['deskId'], equals('desk-123'));
      expect(json['createdAt'], isA<Timestamp>());
    });

    test('should deserialize from JSON correctly', () {
      final UserDayLock lock = UserDayLock.fromJson(testJson);
      
      expect(lock.id, equals('user-789_2024-01-15'));
      expect(lock.userId, equals('user-789'));
      expect(lock.date, equals('2024-01-15'));
      expect(lock.reservationId, equals('reservation-456'));
      expect(lock.deskId, equals('desk-123'));
      expect(lock.createdAt, isNotNull);
    });

    test('should handle null createdAt', () {
      final Map<String, dynamic> jsonWithNull = <String, dynamic>{
        'id': 'user-789_2024-01-15',
        'userId': 'user-789',
        'date': '2024-01-15',
        'reservationId': 'reservation-456',
        'deskId': 'desk-123',
        'createdAt': null,
      };

      final UserDayLock lock = UserDayLock.fromJson(jsonWithNull);
      expect(lock.createdAt, isNull);
    });

    test('should parse date correctly', () {
      final DateTime parsedDate = testLock.dateAsDateTime;
      expect(parsedDate.year, equals(2024));
      expect(parsedDate.month, equals(1));
      expect(parsedDate.day, equals(15));
    });

    test('should detect today correctly', () {
      final DateTime now = DateTime.now();
      final String todayDate = formatDateYmd(now);
      
      final UserDayLock todayLock = testLock.copyWith(
        id: 'user-789_$todayDate',
        date: todayDate,
      );
      
      expect(todayLock.isToday, isTrue);
      expect(testLock.isToday, isFalse);
    });

    test('should detect past and future correctly', () {
      final DateTime now = DateTime.now();
      final String pastDate = formatDateYmd(now.subtract(const Duration(days: 1)));
      final String futureDate = formatDateYmd(now.add(const Duration(days: 1)));
      
      final UserDayLock pastLock = testLock.copyWith(
        id: 'user-789_$pastDate',
        date: pastDate,
      );
      final UserDayLock futureLock = testLock.copyWith(
        id: 'user-789_$futureDate',
        date: futureDate,
      );
      
      expect(pastLock.isPast, isTrue);
      expect(pastLock.isFuture, isFalse);
      expect(futureLock.isPast, isFalse);
      expect(futureLock.isFuture, isTrue);
    });

    test('should validate ID correctly', () {
      final UserDayLock validLock = testLock;
      final UserDayLock invalidLock = testLock.copyWith(
        id: 'invalid-id-format',
      );
      
      expect(validLock.hasValidId, isTrue);
      expect(invalidLock.hasValidId, isFalse);
    });

    test('should create lock with generated ID', () {
      const String userId = 'user-456';
      const String date = '2024-02-20';
      const String reservationId = 'reservation-789';
      const String deskId = 'desk-123';
      
      final String generatedId = LockIdHelpers.generateUserDayLockId(userId, date);
      final UserDayLock generatedLock = UserDayLock(
        id: generatedId,
        userId: userId,
        date: date,
        reservationId: reservationId,
        deskId: deskId,
        createdAt: DateTime.now(),
      );
      
      expect(generatedLock.id, equals('user-456_2024-02-20'));
      expect(generatedLock.userId, equals('user-456'));
      expect(generatedLock.date, equals('2024-02-20'));
      expect(generatedLock.reservationId, equals('reservation-789'));
      expect(generatedLock.deskId, equals('desk-123'));
      expect(generatedLock.createdAt, isNotNull);
      expect(generatedLock.hasValidId, isTrue);
    });

    test('should support copyWith', () {
      final UserDayLock updatedLock = testLock.copyWith(
        reservationId: 'new-reservation-123',
        deskId: 'new-desk-456',
      );

      expect(updatedLock.reservationId, equals('new-reservation-123'));
      expect(updatedLock.deskId, equals('new-desk-456'));
      expect(updatedLock.id, equals(testLock.id));
      expect(updatedLock.userId, equals(testLock.userId));
      expect(updatedLock.date, equals(testLock.date));
    });
  });
}
