import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Reservation', () {
    late Reservation testReservation;
    late Map<String, dynamic> testJson;

    setUp(() {
      final DateTime now = DateTime.now();
      final DateTime start = DateTime(2024, 1, 15, 9, 0);
      final DateTime end = DateTime(2024, 1, 15, 17, 0);
      
      testReservation = Reservation(
        id: 'reservation-123',
        userId: 'user-456',
        deskId: 'desk-789',
        date: '2024-01-15',
        start: start,
        end: end,
        status: ReservationStatus.active,
        createdAt: now,
        cancelledAt: null,
        notes: 'Important meeting day',
      );

      testJson = <String, dynamic>{
        'id': 'reservation-123',
        'userId': 'user-456',
        'deskId': 'desk-789',
        'date': '2024-01-15',
        'start': Timestamp.fromDate(start),
        'end': Timestamp.fromDate(end),
        'status': 'active',
        'createdAt': Timestamp.fromDate(now),
        'cancelledAt': null,
        'notes': 'Important meeting day',
      };
    });

    test('should serialize to JSON correctly', () {
      final Map<String, dynamic> json = testReservation.toJson();
      
      expect(json['id'], equals('reservation-123'));
      expect(json['userId'], equals('user-456'));
      expect(json['deskId'], equals('desk-789'));
      expect(json['date'], equals('2024-01-15'));
      expect(json['start'], isA<Timestamp>());
      expect(json['end'], isA<Timestamp>());
      expect(json['status'], equals('active'));
      expect(json['createdAt'], isA<Timestamp>());
      expect(json['cancelledAt'], isNull);
      expect(json['notes'], equals('Important meeting day'));
    });

    test('should deserialize from JSON correctly', () {
      final Reservation reservation = Reservation.fromJson(testJson);
      
      expect(reservation.id, equals('reservation-123'));
      expect(reservation.userId, equals('user-456'));
      expect(reservation.deskId, equals('desk-789'));
      expect(reservation.date, equals('2024-01-15'));
      expect(reservation.start, isNotNull);
      expect(reservation.end, isNotNull);
      expect(reservation.status, equals(ReservationStatus.active));
      expect(reservation.createdAt, isNotNull);
      expect(reservation.cancelledAt, isNull);
      expect(reservation.notes, equals('Important meeting day'));
    });

    test('should handle null optional fields', () {
      final Map<String, dynamic> jsonWithNulls = <String, dynamic>{
        'id': 'reservation-123',
        'userId': 'user-456',
        'deskId': 'desk-789',
        'date': '2024-01-15',
        'start': null,
        'end': null,
        'status': 'active',
        'createdAt': null,
        'cancelledAt': null,
        'notes': null,
      };

      final Reservation reservation = Reservation.fromJson(jsonWithNulls);
      
      expect(reservation.start, isNull);
      expect(reservation.end, isNull);
      expect(reservation.createdAt, isNull);
      expect(reservation.cancelledAt, isNull);
      expect(reservation.notes, isNull);
    });

    test('should handle cancelled status', () {
      final Map<String, dynamic> cancelledJson = <String, dynamic>{
        ...testJson,
        'status': 'cancelled',
        'cancelledAt': Timestamp.fromDate(DateTime.now()),
      };

      final Reservation reservation = Reservation.fromJson(cancelledJson);
      expect(reservation.status, equals(ReservationStatus.cancelled));
      expect(reservation.cancelledAt, isNotNull);
    });

    test('should check status correctly', () {
      final Reservation activeReservation = testReservation;
      final Reservation cancelledReservation = testReservation.copyWith(
        status: ReservationStatus.cancelled,
      );

      expect(activeReservation.isActive, isTrue);
      expect(activeReservation.isCancelled, isFalse);
      expect(cancelledReservation.isActive, isFalse);
      expect(cancelledReservation.isCancelled, isTrue);
    });

    test('should detect time range correctly', () {
      final Reservation withTimeRange = testReservation;
      final Reservation withoutTimeRange = testReservation.copyWith(
        start: null,
        end: null,
      );

      expect(withTimeRange.hasTimeRange, isTrue);
      expect(withoutTimeRange.hasTimeRange, isFalse);
    });

    test('should calculate duration correctly', () {
      final Duration? duration = testReservation.duration;
      expect(duration, isNotNull);
      expect(duration!.inHours, equals(8));
    });

    test('should detect notes correctly', () {
      final Reservation withNotes = testReservation;
      final Reservation withoutNotes = testReservation.copyWith(notes: null);
      final Reservation withEmptyNotes = testReservation.copyWith(notes: '');

      expect(withNotes.hasNotes, isTrue);
      expect(withoutNotes.hasNotes, isFalse);
      expect(withEmptyNotes.hasNotes, isFalse);
    });

    test('should parse date correctly', () {
      final DateTime parsedDate = testReservation.dateAsDateTime;
      expect(parsedDate.year, equals(2024));
      expect(parsedDate.month, equals(1));
      expect(parsedDate.day, equals(15));
    });

    test('should detect today correctly', () {
      final DateTime now = DateTime.now();
      final String todayDate = formatDateYmd(now);
      
      final Reservation todayReservation = testReservation.copyWith(
        date: todayDate,
      );
      
      expect(todayReservation.isToday, isTrue);
      expect(testReservation.isToday, isFalse);
    });

    test('should detect past and future correctly', () {
      final DateTime now = DateTime.now();
      final String pastDate = formatDateYmd(now.subtract(const Duration(days: 1)));
      final String futureDate = formatDateYmd(now.add(const Duration(days: 1)));
      
      final Reservation pastReservation = testReservation.copyWith(date: pastDate);
      final Reservation futureReservation = testReservation.copyWith(date: futureDate);
      
      expect(pastReservation.isPast, isTrue);
      expect(pastReservation.isFuture, isFalse);
      expect(futureReservation.isPast, isFalse);
      expect(futureReservation.isFuture, isTrue);
    });

    test('should support copyWith', () {
      final Reservation updatedReservation = testReservation.copyWith(
        status: ReservationStatus.cancelled,
        cancelledAt: DateTime.now(),
        notes: 'Cancelled due to illness',
      );

      expect(updatedReservation.status, equals(ReservationStatus.cancelled));
      expect(updatedReservation.cancelledAt, isNotNull);
      expect(updatedReservation.notes, equals('Cancelled due to illness'));
      expect(updatedReservation.id, equals(testReservation.id));
    });
  });
}
