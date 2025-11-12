// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LikeImpl _$$LikeImplFromJson(Map<String, dynamic> json) => _$LikeImpl(
  pointId: json['point_id'] as String,
  userId: json['user_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$LikeImplToJson(_$LikeImpl instance) =>
    <String, dynamic>{
      'point_id': instance.pointId,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
    };
