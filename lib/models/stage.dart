import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stage.g.dart';

@JsonSerializable()
class Stage {
  final int stage;
  final List startPoint;
  final List endPoint;
  double km;

  Stage({
    @required this.stage,
    @required this.startPoint,
    @required this.endPoint,
    this.km = 0.0,
  });

  factory Stage.fromJson(Map<String, dynamic> json) => _$StageFromJson(json);

  Map<String, dynamic> toJson() => _$StageToJson(this);
}
