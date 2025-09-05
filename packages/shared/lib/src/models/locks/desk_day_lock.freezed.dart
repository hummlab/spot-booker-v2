// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'desk_day_lock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeskDayLock _$DeskDayLockFromJson(Map<String, dynamic> json) {
  return _DeskDayLock.fromJson(json);
}

/// @nodoc
mixin _$DeskDayLock {
  /// Unique lock identifier in format: deskId_YYYY-MM-DD
  String get id => throw _privateConstructorUsedError;

  /// ID of the desk being locked
  String get deskId => throw _privateConstructorUsedError;

  /// Date of the lock in YYYY-MM-DD format
  String get date => throw _privateConstructorUsedError;

  /// ID of the reservation that created this lock
  String get reservationId => throw _privateConstructorUsedError;

  /// ID of the user who made the reservation
  String get userId => throw _privateConstructorUsedError;

  /// When the lock was created
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this DeskDayLock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeskDayLock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeskDayLockCopyWith<DeskDayLock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeskDayLockCopyWith<$Res> {
  factory $DeskDayLockCopyWith(
          DeskDayLock value, $Res Function(DeskDayLock) then) =
      _$DeskDayLockCopyWithImpl<$Res, DeskDayLock>;
  @useResult
  $Res call(
      {String id,
      String deskId,
      String date,
      String reservationId,
      String userId,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$DeskDayLockCopyWithImpl<$Res, $Val extends DeskDayLock>
    implements $DeskDayLockCopyWith<$Res> {
  _$DeskDayLockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeskDayLock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deskId = null,
    Object? date = null,
    Object? reservationId = null,
    Object? userId = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deskId: null == deskId
          ? _value.deskId
          : deskId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      reservationId: null == reservationId
          ? _value.reservationId
          : reservationId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeskDayLockImplCopyWith<$Res>
    implements $DeskDayLockCopyWith<$Res> {
  factory _$$DeskDayLockImplCopyWith(
          _$DeskDayLockImpl value, $Res Function(_$DeskDayLockImpl) then) =
      __$$DeskDayLockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String deskId,
      String date,
      String reservationId,
      String userId,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$DeskDayLockImplCopyWithImpl<$Res>
    extends _$DeskDayLockCopyWithImpl<$Res, _$DeskDayLockImpl>
    implements _$$DeskDayLockImplCopyWith<$Res> {
  __$$DeskDayLockImplCopyWithImpl(
      _$DeskDayLockImpl _value, $Res Function(_$DeskDayLockImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeskDayLock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? deskId = null,
    Object? date = null,
    Object? reservationId = null,
    Object? userId = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$DeskDayLockImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      deskId: null == deskId
          ? _value.deskId
          : deskId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      reservationId: null == reservationId
          ? _value.reservationId
          : reservationId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeskDayLockImpl implements _DeskDayLock {
  const _$DeskDayLockImpl(
      {required this.id,
      required this.deskId,
      required this.date,
      required this.reservationId,
      required this.userId,
      @TimestampConverter() this.createdAt});

  factory _$DeskDayLockImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeskDayLockImplFromJson(json);

  /// Unique lock identifier in format: deskId_YYYY-MM-DD
  @override
  final String id;

  /// ID of the desk being locked
  @override
  final String deskId;

  /// Date of the lock in YYYY-MM-DD format
  @override
  final String date;

  /// ID of the reservation that created this lock
  @override
  final String reservationId;

  /// ID of the user who made the reservation
  @override
  final String userId;

  /// When the lock was created
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'DeskDayLock(id: $id, deskId: $deskId, date: $date, reservationId: $reservationId, userId: $userId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeskDayLockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.deskId, deskId) || other.deskId == deskId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.reservationId, reservationId) ||
                other.reservationId == reservationId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, deskId, date, reservationId, userId, createdAt);

  /// Create a copy of DeskDayLock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeskDayLockImplCopyWith<_$DeskDayLockImpl> get copyWith =>
      __$$DeskDayLockImplCopyWithImpl<_$DeskDayLockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeskDayLockImplToJson(
      this,
    );
  }
}

abstract class _DeskDayLock implements DeskDayLock {
  const factory _DeskDayLock(
      {required final String id,
      required final String deskId,
      required final String date,
      required final String reservationId,
      required final String userId,
      @TimestampConverter() final DateTime? createdAt}) = _$DeskDayLockImpl;

  factory _DeskDayLock.fromJson(Map<String, dynamic> json) =
      _$DeskDayLockImpl.fromJson;

  /// Unique lock identifier in format: deskId_YYYY-MM-DD
  @override
  String get id;

  /// ID of the desk being locked
  @override
  String get deskId;

  /// Date of the lock in YYYY-MM-DD format
  @override
  String get date;

  /// ID of the reservation that created this lock
  @override
  String get reservationId;

  /// ID of the user who made the reservation
  @override
  String get userId;

  /// When the lock was created
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of DeskDayLock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeskDayLockImplCopyWith<_$DeskDayLockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
