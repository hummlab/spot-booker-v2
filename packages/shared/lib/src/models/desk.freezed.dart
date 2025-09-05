// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'desk.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Desk _$DeskFromJson(Map<String, dynamic> json) {
  return _Desk.fromJson(json);
}

/// @nodoc
mixin _$Desk {
  /// Unique desk identifier
  String get id => throw _privateConstructorUsedError;

  /// Display name of the desk
  String get name => throw _privateConstructorUsedError;

  /// Short code for the desk (e.g., "A1", "B2")
  String get code => throw _privateConstructorUsedError;

  /// Whether the desk is available for booking
  bool get enabled => throw _privateConstructorUsedError;

  /// Optional notes about the desk
  String? get notes => throw _privateConstructorUsedError;

  /// When the desk was created
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// When the desk was last updated
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Desk to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Desk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeskCopyWith<Desk> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeskCopyWith<$Res> {
  factory $DeskCopyWith(Desk value, $Res Function(Desk) then) =
      _$DeskCopyWithImpl<$Res, Desk>;
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      bool enabled,
      String? notes,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$DeskCopyWithImpl<$Res, $Val extends Desk>
    implements $DeskCopyWith<$Res> {
  _$DeskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Desk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? enabled = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeskImplCopyWith<$Res> implements $DeskCopyWith<$Res> {
  factory _$$DeskImplCopyWith(
          _$DeskImpl value, $Res Function(_$DeskImpl) then) =
      __$$DeskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String code,
      bool enabled,
      String? notes,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$DeskImplCopyWithImpl<$Res>
    extends _$DeskCopyWithImpl<$Res, _$DeskImpl>
    implements _$$DeskImplCopyWith<$Res> {
  __$$DeskImplCopyWithImpl(_$DeskImpl _value, $Res Function(_$DeskImpl) _then)
      : super(_value, _then);

  /// Create a copy of Desk
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? enabled = null,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DeskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeskImpl implements _Desk {
  const _$DeskImpl(
      {required this.id,
      required this.name,
      required this.code,
      required this.enabled,
      this.notes,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt});

  factory _$DeskImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeskImplFromJson(json);

  /// Unique desk identifier
  @override
  final String id;

  /// Display name of the desk
  @override
  final String name;

  /// Short code for the desk (e.g., "A1", "B2")
  @override
  final String code;

  /// Whether the desk is available for booking
  @override
  final bool enabled;

  /// Optional notes about the desk
  @override
  final String? notes;

  /// When the desk was created
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  /// When the desk was last updated
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Desk(id: $id, name: $name, code: $code, enabled: $enabled, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.enabled, enabled) || other.enabled == enabled) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, code, enabled, notes, createdAt, updatedAt);

  /// Create a copy of Desk
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeskImplCopyWith<_$DeskImpl> get copyWith =>
      __$$DeskImplCopyWithImpl<_$DeskImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeskImplToJson(
      this,
    );
  }
}

abstract class _Desk implements Desk {
  const factory _Desk(
      {required final String id,
      required final String name,
      required final String code,
      required final bool enabled,
      final String? notes,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$DeskImpl;

  factory _Desk.fromJson(Map<String, dynamic> json) = _$DeskImpl.fromJson;

  /// Unique desk identifier
  @override
  String get id;

  /// Display name of the desk
  @override
  String get name;

  /// Short code for the desk (e.g., "A1", "B2")
  @override
  String get code;

  /// Whether the desk is available for booking
  @override
  bool get enabled;

  /// Optional notes about the desk
  @override
  String? get notes;

  /// When the desk was created
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// When the desk was last updated
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of Desk
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeskImplCopyWith<_$DeskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
