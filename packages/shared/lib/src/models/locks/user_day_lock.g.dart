// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_day_lock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDayLockImpl _$$UserDayLockImplFromJson(Map<String, dynamic> json) =>
    _$UserDayLockImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: json['date'] as String,
      reservationId: json['reservationId'] as String,
      deskId: json['deskId'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
    );

Map<String, dynamic> _$$UserDayLockImplToJson(_$UserDayLockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date,
      'reservationId': instance.reservationId,
      'deskId': instance.deskId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
