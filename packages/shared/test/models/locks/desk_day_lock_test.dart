import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('DeskDayLock', () {
    late DeskDayLock testLock;
    late Map<String, dynamic> testJson;

    setUp(() {
      final DateTime now = DateTime.now();
      
      testLock = DeskDayLock(
        id: 'desk-123_2024-01-15',
        deskId: 'desk-123',
        date: '2024-01-15',
        reservationId: 'reservation-456',
        userId: 'user-789',
        createdAt: now,
      );

      testJson = <String, dynamic>{
        'id': 'desk-123_2024-01-15',
        'deskId': 'desk-123',
        'date': '2024-01-15',
        'reservationId': 'reservation-456',
        'userId': 'user-789',
        'createdAt': Timestamp.fromDate(now),
      };
    });

    test('should serialize to JSON correctly', () {
      final Map<String, dynamic> json = testLock.toJson();
      
      expect(json['id'], equals('desk-123_2024-01-15'));
      expect(json['deskId'], equals('desk-123'));
      expect(json['date'], equals('2024-01-15'));
      expect(json['reservationId'], equals('reservation-456'));
      expect(json['userId'], equals('user-789'));
      expect(json['createdAt'], isA<Timestamp>());
    });

    test('should deserialize from JSON correctly', () {
      final DeskDayLock lock = DeskDayLock.fromJson(testJson);
      
      expect(lock.id, equals('desk-123_2024-01-15'));
      expect(lock.deskId, equals('desk-123'));
      expect(lock.date, equals('2024-01-15'));
      expect(lock.reservationId, equals('reservation-456'));
      expect(lock.userId, equals('user-789'));
      expect(lock.createdAt, isNotNull);
    });

    test('should handle null createdAt', () {
      final Map<String, dynamic> jsonWithNull = <String, dynamic>{
        'id': 'desk-123_2024-01-15',
        'deskId': 'desk-123',
        'date': '2024-01-15',
        'reservationId': 'reservation-456',
        'userId': 'user-789',
        'createdAt': null,
      };

      final DeskDayLock lock = DeskDayLock.fromJson(jsonWithNull);
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
      
      final DeskDayLock todayLock = testLock.copyWith(
        id: 'desk-123_$todayDate',
        date: todayDate,
      );
      
      expect(todayLock.isToday, isTrue);
      expect(testLock.isToday, isFalse);
    });

    test('should detect past and future correctly', () {
      final DateTime now = DateTime.now();
      final String pastDate = formatDateYmd(now.subtract(const Duration(days: 1)));
      final String futureDate = formatDateYmd(now.add(const Duration(days: 1)));
      
      final DeskDayLock pastLock = testLock.copyWith(
        id: 'desk-123_$pastDate',
        date: pastDate,
      );
      final DeskDayLock futureLock = testLock.copyWith(
        id: 'desk-123_$futureDate',
        date: futureDate,
      );
      
      expect(pastLock.isPast, isTrue);
      expect(pastLock.isFuture, isFalse);
      expect(futureLock.isPast, isFalse);
      expect(futureLock.isFuture, isTrue);
    });

    test('should validate ID correctly', () {
      final DeskDayLock validLock = testLock;
      final DeskDayLock invalidLock = testLock.copyWith(
        id: 'invalid-id-format',
      );
      
      expect(validLock.hasValidId, isTrue);
      expect(invalidLock.hasValidId, isFalse);
    });

    test('should create lock with generated ID', () {
      const String deskId = 'desk-456';
      const String date = '2024-02-20';
      const String reservationId = 'reservation-789';
      const String userId = 'user-123';
      
      final String generatedId = LockIdHelpers.generateDeskDayLockId(deskId, date);
      final DeskDayLock generatedLock = DeskDayLock(
        id: generatedId,
        deskId: deskId,
        date: date,
        reservationId: reservationId,
        userId: userId,
        createdAt: DateTime.now(),
      );
      
      expect(generatedLock.id, equals('desk-456_2024-02-20'));
      expect(generatedLock.deskId, equals('desk-456'));
      expect(generatedLock.date, equals('2024-02-20'));
      expect(generatedLock.reservationId, equals('reservation-789'));
      expect(generatedLock.userId, equals('user-123'));
      expect(generatedLock.createdAt, isNotNull);
      expect(generatedLock.hasValidId, isTrue);
    });

    test('should support copyWith', () {
      final DeskDayLock updatedLock = testLock.copyWith(
        reservationId: 'new-reservation-123',
        userId: 'new-user-456',
      );

      expect(updatedLock.reservationId, equals('new-reservation-123'));
      expect(updatedLock.userId, equals('new-user-456'));
      expect(updatedLock.id, equals(testLock.id));
      expect(updatedLock.deskId, equals(testLock.deskId));
      expect(updatedLock.date, equals(testLock.date));
    });
  });
}
