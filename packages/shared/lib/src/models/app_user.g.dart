// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      active: json['active'] as bool,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
      lastLoginAt: const TimestampConverter()
          .fromJson(json['lastLoginAt'] as Timestamp?),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'active': instance.active,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'lastLoginAt': const TimestampConverter().toJson(instance.lastLoginAt),
    };
