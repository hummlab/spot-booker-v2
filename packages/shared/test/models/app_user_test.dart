import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('AppUser', () {
    late AppUser testUser;
    late Map<String, dynamic> testJson;

    setUp(() {
      final DateTime now = DateTime.now();
      final DateTime loginTime = now.subtract(const Duration(hours: 2));
      
      testUser = AppUser(
        uid: 'test-uid-123',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        active: true,
        createdAt: now,
        lastLoginAt: loginTime,
      );

      testJson = <String, dynamic>{
        'uid': 'test-uid-123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'active': true,
        'createdAt': Timestamp.fromDate(now),
        'lastLoginAt': Timestamp.fromDate(loginTime),
      };
    });

    test('should serialize to JSON correctly', () {
      final Map<String, dynamic> json = testUser.toJson();
      
      expect(json['uid'], equals('test-uid-123'));
      expect(json['email'], equals('test@example.com'));
      expect(json['firstName'], equals('John'));
      expect(json['lastName'], equals('Doe'));
      expect(json['active'], equals(true));
      expect(json['createdAt'], isA<Timestamp>());
      expect(json['lastLoginAt'], isA<Timestamp>());
    });

    test('should deserialize from JSON correctly', () {
      final AppUser user = AppUser.fromJson(testJson);
      
      expect(user.uid, equals('test-uid-123'));
      expect(user.email, equals('test@example.com'));
      expect(user.firstName, equals('John'));
      expect(user.lastName, equals('Doe'));
      expect(user.active, equals(true));
      expect(user.createdAt, isNotNull);
      expect(user.lastLoginAt, isNotNull);
    });

    test('should handle null timestamps', () {
      final Map<String, dynamic> jsonWithNulls = <String, dynamic>{
        'uid': 'test-uid-123',
        'email': 'test@example.com',
        'firstName': 'John',
        'lastName': 'Doe',
        'active': true,
        'createdAt': null,
        'lastLoginAt': null,
      };

      final AppUser user = AppUser.fromJson(jsonWithNulls);
      
      expect(user.createdAt, isNull);
      expect(user.lastLoginAt, isNull);
    });

    test('should provide full name correctly', () {
      expect(testUser.fullName, equals('John Doe'));
    });

    test('should detect new user correctly', () {
      final DateTime now = DateTime.now();
      final AppUser newUser = testUser.copyWith(
        createdAt: now.subtract(const Duration(hours: 12)),
      );
      final AppUser oldUser = testUser.copyWith(
        createdAt: now.subtract(const Duration(days: 2)),
      );

      expect(newUser.isNewUser, isTrue);
      expect(oldUser.isNewUser, isFalse);
    });

    test('should detect recent login correctly', () {
      final DateTime now = DateTime.now();
      final AppUser recentUser = testUser.copyWith(
        lastLoginAt: now.subtract(const Duration(days: 3)),
      );
      final AppUser oldUser = testUser.copyWith(
        lastLoginAt: now.subtract(const Duration(days: 10)),
      );

      expect(recentUser.hasRecentLogin, isTrue);
      expect(oldUser.hasRecentLogin, isFalse);
    });

    test('should support copyWith', () {
      final AppUser updatedUser = testUser.copyWith(
        firstName: 'Jane',
        active: false,
      );

      expect(updatedUser.firstName, equals('Jane'));
      expect(updatedUser.active, isFalse);
      expect(updatedUser.uid, equals(testUser.uid));
      expect(updatedUser.email, equals(testUser.email));
    });
  });
}
