// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reservation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Reservation _$ReservationFromJson(Map<String, dynamic> json) {
  return _Reservation.fromJson(json);
}

/// @nodoc
mixin _$Reservation {
  /// Unique reservation identifier
  String get id => throw _privateConstructorUsedError;

  /// ID of the user who made the reservation
  String get userId => throw _privateConstructorUsedError;

  /// ID of the desk being reserved
  String get deskId => throw _privateConstructorUsedError;

  /// Date of the reservation in YYYY-MM-DD format
  String get date => throw _privateConstructorUsedError;

  /// Optional start time for the reservation
  @TimestampConverter()
  DateTime? get start => throw _privateConstructorUsedError;

  /// Optional end time for the reservation
  @TimestampConverter()
  DateTime? get end => throw _privateConstructorUsedError;

  /// Status of the reservation
  ReservationStatus get status => throw _privateConstructorUsedError;

  /// When the reservation was created
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When the reservation was cancelled (if applicable)
  @TimestampConverter()
  DateTime? get cancelledAt => throw _privateConstructorUsedError;

  /// Optional notes about the reservation
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Reservation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReservationCopyWith<Reservation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReservationCopyWith<$Res> {
  factory $ReservationCopyWith(
          Reservation value, $Res Function(Reservation) then) =
      _$ReservationCopyWithImpl<$Res, Reservation>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String deskId,
      String date,
      @TimestampConverter() DateTime? start,
      @TimestampConverter() DateTime? end,
      ReservationStatus status,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? cancelledAt,
      String? notes});
}

/// @nodoc
class _$ReservationCopyWithImpl<$Res, $Val extends Reservation>
    implements $ReservationCopyWith<$Res> {
  _$ReservationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deskId = null,
    Object? date = null,
    Object? start = freezed,
    Object? end = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? cancelledAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deskId: null == deskId
          ? _value.deskId
          : deskId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      end: freezed == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReservationStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReservationImplCopyWith<$Res>
    implements $ReservationCopyWith<$Res> {
  factory _$$ReservationImplCopyWith(
          _$ReservationImpl value, $Res Function(_$ReservationImpl) then) =
      __$$ReservationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String deskId,
      String date,
      @TimestampConverter() DateTime? start,
      @TimestampConverter() DateTime? end,
      ReservationStatus status,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? cancelledAt,
      String? notes});
}

/// @nodoc
class __$$ReservationImplCopyWithImpl<$Res>
    extends _$ReservationCopyWithImpl<$Res, _$ReservationImpl>
    implements _$$ReservationImplCopyWith<$Res> {
  __$$ReservationImplCopyWithImpl(
      _$ReservationImpl _value, $Res Function(_$ReservationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? deskId = null,
    Object? date = null,
    Object? start = freezed,
    Object? end = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? cancelledAt = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$ReservationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deskId: null == deskId
          ? _value.deskId
          : deskId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      end: freezed == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReservationStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      cancelledAt: freezed == cancelledAt
          ? _value.cancelledAt
          : cancelledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReservationImpl implements _Reservation {
  const _$ReservationImpl(
      {required this.id,
      required this.userId,
      required this.deskId,
      required this.date,
      @TimestampConverter() this.start,
      @TimestampConverter() this.end,
      this.status = ReservationStatus.active,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.cancelledAt,
      this.notes});

  factory _$ReservationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReservationImplFromJson(json);

  /// Unique reservation identifier
  @override
  final String id;

  /// ID of the user who made the reservation
  @override
  final String userId;

  /// ID of the desk being reserved
  @override
  final String deskId;

  /// Date of the reservation in YYYY-MM-DD format
  @override
  final String date;

  /// Optional start time for the reservation
  @override
  @TimestampConverter()
  final DateTime? start;

  /// Optional end time for the reservation
  @override
  @TimestampConverter()
  final DateTime? end;

  /// Status of the reservation
  @override
  @JsonKey()
  final ReservationStatus status;

  /// When the reservation was created
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  /// When the reservation was cancelled (if applicable)
  @override
  @TimestampConverter()
  final DateTime? cancelledAt;

  /// Optional notes about the reservation
  @override
  final String? notes;

  @override
  String toString() {
    return 'Reservation(id: $id, userId: $userId, deskId: $deskId, date: $date, start: $start, end: $end, status: $status, createdAt: $createdAt, cancelledAt: $cancelledAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReservationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deskId, deskId) || other.deskId == deskId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.cancelledAt, cancelledAt) ||
                other.cancelledAt == cancelledAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, deskId, date, start,
      end, status, createdAt, cancelledAt, notes);

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReservationImplCopyWith<_$ReservationImpl> get copyWith =>
      __$$ReservationImplCopyWithImpl<_$ReservationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReservationImplToJson(
      this,
    );
  }
}

abstract class _Reservation implements Reservation {
  const factory _Reservation(
      {required final String id,
      required final String userId,
      required final String deskId,
      required final String date,
      @TimestampConverter() final DateTime? start,
      @TimestampConverter() final DateTime? end,
      final ReservationStatus status,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? cancelledAt,
      final String? notes}) = _$ReservationImpl;

  factory _Reservation.fromJson(Map<String, dynamic> json) =
      _$ReservationImpl.fromJson;

  /// Unique reservation identifier
  @override
  String get id;

  /// ID of the user who made the reservation
  @override
  String get userId;

  /// ID of the desk being reserved
  @override
  String get deskId;

  /// Date of the reservation in YYYY-MM-DD format
  @override
  String get date;

  /// Optional start time for the reservation
  @override
  @TimestampConverter()
  DateTime? get start;

  /// Optional end time for the reservation
  @override
  @TimestampConverter()
  DateTime? get end;

  /// Status of the reservation
  @override
  ReservationStatus get status;

  /// When the reservation was created
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// When the reservation was cancelled (if applicable)
  @override
  @TimestampConverter()
  DateTime? get cancelledAt;

  /// Optional notes about the reservation
  @override
  String? get notes;

  /// Create a copy of Reservation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReservationImplCopyWith<_$ReservationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
