// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PointImpl _$$PointImplFromJson(Map<String, dynamic> json) => _$PointImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  content: json['content'] as String,
  location: const LocationCoordinateConverter().fromJson(
    json['geom'] as Map<String, dynamic>,
  ),
  maidenhead6char: json['maidenhead_6char'] as String,
  isActive: json['is_active'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$PointImplToJson(_$PointImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'content': instance.content,
      'geom': const LocationCoordinateConverter().toJson(instance.location),
      'maidenhead_6char': instance.maidenhead6char,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
    };
