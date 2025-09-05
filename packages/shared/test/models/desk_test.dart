import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Desk', () {
    late Desk testDesk;
    late Map<String, dynamic> testJson;

    setUp(() {
      final DateTime now = DateTime.now();
      final DateTime updatedTime = now.subtract(const Duration(minutes: 30));
      
      testDesk = Desk(
        id: 'desk-123',
        name: 'Desk A1',
        code: 'A1',
        enabled: true,
        notes: 'Corner desk with window view',
        createdAt: now,
        updatedAt: updatedTime,
      );

      testJson = <String, dynamic>{
        'id': 'desk-123',
        'name': 'Desk A1',
        'code': 'A1',
        'enabled': true,
        'notes': 'Corner desk with window view',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(updatedTime),
      };
    });

    test('should serialize to JSON correctly', () {
      final Map<String, dynamic> json = testDesk.toJson();
      
      expect(json['id'], equals('desk-123'));
      expect(json['name'], equals('Desk A1'));
      expect(json['code'], equals('A1'));
      expect(json['enabled'], equals(true));
      expect(json['notes'], equals('Corner desk with window view'));
      expect(json['createdAt'], isA<Timestamp>());
      expect(json['updatedAt'], isA<Timestamp>());
    });

    test('should deserialize from JSON correctly', () {
      final Desk desk = Desk.fromJson(testJson);
      
      expect(desk.id, equals('desk-123'));
      expect(desk.name, equals('Desk A1'));
      expect(desk.code, equals('A1'));
      expect(desk.enabled, equals(true));
      expect(desk.notes, equals('Corner desk with window view'));
      expect(desk.createdAt, isNotNull);
      expect(desk.updatedAt, isNotNull);
    });

    test('should handle null optional fields', () {
      final Map<String, dynamic> jsonWithNulls = <String, dynamic>{
        'id': 'desk-123',
        'name': 'Desk A1',
        'code': 'A1',
        'enabled': true,
        'notes': null,
        'createdAt': null,
        'updatedAt': null,
      };

      final Desk desk = Desk.fromJson(jsonWithNulls);
      
      expect(desk.notes, isNull);
      expect(desk.createdAt, isNull);
      expect(desk.updatedAt, isNull);
    });

    test('should provide display name correctly', () {
      expect(testDesk.displayName, equals('Desk A1 (A1)'));
    });

    test('should check availability correctly', () {
      final Desk enabledDesk = testDesk.copyWith(enabled: true);
      final Desk disabledDesk = testDesk.copyWith(enabled: false);

      expect(enabledDesk.isAvailable, isTrue);
      expect(disabledDesk.isAvailable, isFalse);
    });

    test('should detect notes correctly', () {
      final Desk deskWithNotes = testDesk.copyWith(notes: 'Has notes');
      final Desk deskWithoutNotes = testDesk.copyWith(notes: null);
      final Desk deskWithEmptyNotes = testDesk.copyWith(notes: '');

      expect(deskWithNotes.hasNotes, isTrue);
      expect(deskWithoutNotes.hasNotes, isFalse);
      expect(deskWithEmptyNotes.hasNotes, isFalse);
    });

    test('should support copyWith', () {
      final Desk updatedDesk = testDesk.copyWith(
        name: 'Desk B2',
        code: 'B2',
        enabled: false,
      );

      expect(updatedDesk.name, equals('Desk B2'));
      expect(updatedDesk.code, equals('B2'));
      expect(updatedDesk.enabled, isFalse);
      expect(updatedDesk.id, equals(testDesk.id));
      expect(updatedDesk.notes, equals(testDesk.notes));
    });
  });
}
