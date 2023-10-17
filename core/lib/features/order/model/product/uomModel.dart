

import 'package:json_annotation/json_annotation.dart';

part 'uomModel.g.dart';

@JsonSerializable()
class UOMModel{
  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "name")
  String? name;



  factory UOMModel.fromJson(Map<String, dynamic> json) =>
      _$UOMModelFromJson(json);

  Map<String, dynamic> toJson() => _$UOMModelToJson(this);

  UOMModel(this.id, this.name);
}