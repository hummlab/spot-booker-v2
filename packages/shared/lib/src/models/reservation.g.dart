// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReservationImpl _$$ReservationImplFromJson(Map<String, dynamic> json) =>
    _$ReservationImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      deskId: json['deskId'] as String,
      date: json['date'] as String,
      start: const TimestampConverter().fromJson(json['start'] as Timestamp?),
      end: const TimestampConverter().fromJson(json['end'] as Timestamp?),
      status: $enumDecodeNullable(_$ReservationStatusEnumMap, json['status']) ??
          ReservationStatus.active,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
      cancelledAt: const TimestampConverter()
          .fromJson(json['cancelledAt'] as Timestamp?),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ReservationImplToJson(_$ReservationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'deskId': instance.deskId,
      'date': instance.date,
      'start': const TimestampConverter().toJson(instance.start),
      'end': const TimestampConverter().toJson(instance.end),
      'status': _$ReservationStatusEnumMap[instance.status]!,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'cancelledAt': const TimestampConverter().toJson(instance.cancelledAt),
      'notes': instance.notes,
    };

const _$ReservationStatusEnumMap = {
  ReservationStatus.active: 'active',
  ReservationStatus.cancelled: 'cancelled',
};
