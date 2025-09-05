// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeskImpl _$$DeskImplFromJson(Map<String, dynamic> json) => _$DeskImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      enabled: json['enabled'] as bool,
      notes: json['notes'] as String?,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
      updatedAt:
          const TimestampConverter().fromJson(json['updatedAt'] as Timestamp?),
    );

Map<String, dynamic> _$$DeskImplToJson(_$DeskImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'enabled': instance.enabled,
      'notes': instance.notes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
