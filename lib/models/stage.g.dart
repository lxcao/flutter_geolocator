// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stage.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Stage _$StageFromJson(Map<String, dynamic> json) {
  return Stage(
    stage: json['stage'] as int,
    startPoint: json['startPoint'] as List,
    endPoint: json['endPoint'] as List,
    km: (json['km'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$StageToJson(Stage instance) => <String, dynamic>{
      'stage': instance.stage,
      'startPoint': instance.startPoint,
      'endPoint': instance.endPoint,
      'km': instance.km,
    };
