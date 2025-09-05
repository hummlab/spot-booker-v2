// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_day_lock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserDayLock _$UserDayLockFromJson(Map<String, dynamic> json) {
  return _UserDayLock.fromJson(json);
}

/// @nodoc
mixin _$UserDayLock {
  /// Unique lock identifier in format: userId_YYYY-MM-DD
  String get id => throw _privateConstructorUsedError;

  /// ID of the user being locked
  String get userId => throw _privateConstructorUsedError;

  /// Date of the lock in YYYY-MM-DD format
  String get date => throw _privateConstructorUsedError;

  /// ID of the reservation that created this lock
  String get reservationId => throw _privateConstructorUsedError;

  /// ID of the desk being reserved
  String get deskId => throw _privateConstructorUsedError;

  /// When the lock was created
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserDayLock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDayLock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDayLockCopyWith<UserDayLock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDayLockCopyWith<$Res> {
  factory $UserDayLockCopyWith(
          UserDayLock value, $Res Function(UserDayLock) then) =
      _$UserDayLockCopyWithImpl<$Res, UserDayLock>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String date,
      String reservationId,
      String deskId,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$UserDayLockCopyWithImpl<$Res, $Val extends UserDayLock>
    implements $UserDayLockCopyWith<$Res> {
  _$UserDayLockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDayLock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? reservationId = null,
    Object? deskId = null,
    Object? createdAt = freezed,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      reservationId: null == reservationId
          ? _value.reservationId
          : reservationId // ignore: cast_nullable_to_non_nullable
              as String,
      deskId: null == deskId
          ? _value.deskId
          : deskId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserDayLockImplCopyWith<$Res>
    implements $UserDayLockCopyWith<$Res> {
  factory _$$UserDayLockImplCopyWith(
          _$UserDayLockImpl value, $Res Function(_$UserDayLockImpl) then) =
      __$$UserDayLockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String date,
      String reservationId,
      String deskId,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$UserDayLockImplCopyWithImpl<$Res>
    extends _$UserDayLockCopyWithImpl<$Res, _$UserDayLockImpl>
    implements _$$UserDayLockImplCopyWith<$Res> {
  __$$UserDayLockImplCopyWithImpl(
      _$UserDayLockImpl _value, $Res Function(_$UserDayLockImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDayLock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? reservationId = null,
    Object? deskId = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$UserDayLockImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      reservationId: null == reservationId
          ? _value.reservationId
          : reservationId // ignore: cast_nullable_to_non_nullable
              as String,
      deskId: null == deskId
          ? _value.deskId
          : deskId // ignore: cast_nullable_to_non_nullable
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
class _$UserDayLockImpl implements _UserDayLock {
  const _$UserDayLockImpl(
      {required this.id,
      required this.userId,
      required this.date,
      required this.reservationId,
      required this.deskId,
      @TimestampConverter() this.createdAt});

  factory _$UserDayLockImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDayLockImplFromJson(json);

  /// Unique lock identifier in format: userId_YYYY-MM-DD
  @override
  final String id;

  /// ID of the user being locked
  @override
  final String userId;

  /// Date of the lock in YYYY-MM-DD format
  @override
  final String date;

  /// ID of the reservation that created this lock
  @override
  final String reservationId;

  /// ID of the desk being reserved
  @override
  final String deskId;

  /// When the lock was created
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserDayLock(id: $id, userId: $userId, date: $date, reservationId: $reservationId, deskId: $deskId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDayLockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.reservationId, reservationId) ||
                other.reservationId == reservationId) &&
            (identical(other.deskId, deskId) || other.deskId == deskId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, date, reservationId, deskId, createdAt);

  /// Create a copy of UserDayLock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDayLockImplCopyWith<_$UserDayLockImpl> get copyWith =>
      __$$UserDayLockImplCopyWithImpl<_$UserDayLockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDayLockImplToJson(
      this,
    );
  }
}

abstract class _UserDayLock implements UserDayLock {
  const factory _UserDayLock(
      {required final String id,
      required final String userId,
      required final String date,
      required final String reservationId,
      required final String deskId,
      @TimestampConverter() final DateTime? createdAt}) = _$UserDayLockImpl;

  factory _UserDayLock.fromJson(Map<String, dynamic> json) =
      _$UserDayLockImpl.fromJson;

  /// Unique lock identifier in format: userId_YYYY-MM-DD
  @override
  String get id;

  /// ID of the user being locked
  @override
  String get userId;

  /// Date of the lock in YYYY-MM-DD format
  @override
  String get date;

  /// ID of the reservation that created this lock
  @override
  String get reservationId;

  /// ID of the desk being reserved
  @override
  String get deskId;

  /// When the lock was created
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of UserDayLock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDayLockImplCopyWith<_$UserDayLockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
