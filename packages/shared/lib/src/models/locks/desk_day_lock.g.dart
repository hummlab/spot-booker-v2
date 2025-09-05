// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desk_day_lock.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeskDayLockImpl _$$DeskDayLockImplFromJson(Map<String, dynamic> json) =>
    _$DeskDayLockImpl(
      id: json['id'] as String,
      deskId: json['deskId'] as String,
      date: json['date'] as String,
      reservationId: json['reservationId'] as String,
      userId: json['userId'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
    );

Map<String, dynamic> _$$DeskDayLockImplToJson(_$DeskDayLockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deskId': instance.deskId,
      'date': instance.date,
      'reservationId': instance.reservationId,
      'userId': instance.userId,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
