import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('CollectionNames', () {
    test('should have correct collection names', () {
      expect(CollectionNames.users, equals('users'));
      expect(CollectionNames.desks, equals('desks'));
      expect(CollectionNames.reservations, equals('reservations'));
      expect(CollectionNames.deskDayLocks, equals('deskDayLocks'));
      expect(CollectionNames.userDayLocks, equals('userDayLocks'));
    });
  });

  group('LockIdHelpers', () {
    group('generateDeskDayLockId', () {
      test('should generate correct desk day lock ID', () {
        const String deskId = 'desk-123';
        const String date = '2024-01-15';
        
        final String lockId = LockIdHelpers.generateDeskDayLockId(deskId, date);
        
        expect(lockId, equals('desk-123_2024-01-15'));
      });

      test('should handle desk IDs with underscores', () {
        const String deskId = 'desk_with_underscores';
        const String date = '2024-01-15';
        
        final String lockId = LockIdHelpers.generateDeskDayLockId(deskId, date);
        
        expect(lockId, equals('desk_with_underscores_2024-01-15'));
      });
    });

    group('generateUserDayLockId', () {
      test('should generate correct user day lock ID', () {
        const String userId = 'user-456';
        const String date = '2024-01-15';
        
        final String lockId = LockIdHelpers.generateUserDayLockId(userId, date);
        
        expect(lockId, equals('user-456_2024-01-15'));
      });

      test('should handle user IDs with underscores', () {
        const String userId = 'user_with_underscores';
        const String date = '2024-01-15';
        
        final String lockId = LockIdHelpers.generateUserDayLockId(userId, date);
        
        expect(lockId, equals('user_with_underscores_2024-01-15'));
      });
    });

    group('parseDeskDayLockId', () {
      test('should parse simple desk day lock ID', () {
        const String lockId = 'desk-123_2024-01-15';
        
        final ({String deskId, String date}) parsed = 
            LockIdHelpers.parseDeskDayLockId(lockId);
        
        expect(parsed.deskId, equals('desk-123'));
        expect(parsed.date, equals('2024-01-15'));
      });

      test('should parse desk day lock ID with underscores in desk ID', () {
        const String lockId = 'desk_with_underscores_2024-01-15';
        
        final ({String deskId, String date}) parsed = 
            LockIdHelpers.parseDeskDayLockId(lockId);
        
        expect(parsed.deskId, equals('desk_with_underscores'));
        expect(parsed.date, equals('2024-01-15'));
      });

      test('should throw on invalid format', () {
        expect(
          () => LockIdHelpers.parseDeskDayLockId('invalid-format'),
          throwsA(isA<FormatException>()),
        );
        
        expect(
          () => LockIdHelpers.parseDeskDayLockId(''),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('parseUserDayLockId', () {
      test('should parse simple user day lock ID', () {
        const String lockId = 'user-456_2024-01-15';
        
        final ({String userId, String date}) parsed = 
            LockIdHelpers.parseUserDayLockId(lockId);
        
        expect(parsed.userId, equals('user-456'));
        expect(parsed.date, equals('2024-01-15'));
      });

      test('should parse user day lock ID with underscores in user ID', () {
        const String lockId = 'user_with_underscores_2024-01-15';
        
        final ({String userId, String date}) parsed = 
            LockIdHelpers.parseUserDayLockId(lockId);
        
        expect(parsed.userId, equals('user_with_underscores'));
        expect(parsed.date, equals('2024-01-15'));
      });

      test('should throw on invalid format', () {
        expect(
          () => LockIdHelpers.parseUserDayLockId('invalid-format'),
          throwsA(isA<FormatException>()),
        );
        
        expect(
          () => LockIdHelpers.parseUserDayLockId(''),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('isValidLockDate', () {
      test('should validate correct date formats', () {
        expect(LockIdHelpers.isValidLockDate('2024-01-15'), isTrue);
        expect(LockIdHelpers.isValidLockDate('2024-12-31'), isTrue);
        expect(LockIdHelpers.isValidLockDate('2000-02-29'), isTrue); // Leap year
        expect(LockIdHelpers.isValidLockDate('1999-12-25'), isTrue);
      });

      test('should reject invalid date formats', () {
        expect(LockIdHelpers.isValidLockDate('2024-1-15'), isFalse);
        expect(LockIdHelpers.isValidLockDate('2024/01/15'), isFalse);
        expect(LockIdHelpers.isValidLockDate('invalid-date'), isFalse);
        expect(LockIdHelpers.isValidLockDate(''), isFalse);
      });

      test('should reject invalid dates', () {
        expect(LockIdHelpers.isValidLockDate('2024-13-01'), isFalse); // Invalid month
        expect(LockIdHelpers.isValidLockDate('2024-01-32'), isFalse); // Invalid day
        expect(LockIdHelpers.isValidLockDate('2023-02-29'), isFalse); // Not a leap year
        expect(LockIdHelpers.isValidLockDate('1899-01-01'), isFalse); // Year too old
        expect(LockIdHelpers.isValidLockDate('2101-01-01'), isFalse); // Year too far
      });

      test('should handle edge cases', () {
        expect(LockIdHelpers.isValidLockDate('2024-02-29'), isTrue); // Leap year
        expect(LockIdHelpers.isValidLockDate('2024-04-31'), isFalse); // April has 30 days
        expect(LockIdHelpers.isValidLockDate('2024-11-31'), isFalse); // November has 30 days
      });
    });

    group('Round-trip tests', () {
      test('should generate and parse desk day lock ID correctly', () {
        const String deskId = 'desk-123';
        const String date = '2024-01-15';
        
        final String lockId = LockIdHelpers.generateDeskDayLockId(deskId, date);
        final ({String deskId, String date}) parsed = 
            LockIdHelpers.parseDeskDayLockId(lockId);
        
        expect(parsed.deskId, equals(deskId));
        expect(parsed.date, equals(date));
      });

      test('should generate and parse user day lock ID correctly', () {
        const String userId = 'user-456';
        const String date = '2024-01-15';
        
        final String lockId = LockIdHelpers.generateUserDayLockId(userId, date);
        final ({String userId, String date}) parsed = 
            LockIdHelpers.parseUserDayLockId(lockId);
        
        expect(parsed.userId, equals(userId));
        expect(parsed.date, equals(date));
      });

      test('should handle complex IDs with underscores', () {
        const String deskId = 'complex_desk_id_with_underscores';
        const String userId = 'complex_user_id_with_underscores';
        const String date = '2024-12-25';
        
        final String deskLockId = LockIdHelpers.generateDeskDayLockId(deskId, date);
        final String userLockId = LockIdHelpers.generateUserDayLockId(userId, date);
        
        final ({String deskId, String date}) deskParsed = 
            LockIdHelpers.parseDeskDayLockId(deskLockId);
        final ({String userId, String date}) userParsed = 
            LockIdHelpers.parseUserDayLockId(userLockId);
        
        expect(deskParsed.deskId, equals(deskId));
        expect(deskParsed.date, equals(date));
        expect(userParsed.userId, equals(userId));
        expect(userParsed.date, equals(date));
      });
    });
  });
}
