import 'package:json_annotation/json_annotation.dart';

part 'BaseModel.g.dart';

@JsonSerializable()
class BaseModel {
  @JsonKey(name: "message")
  String? message;

  @JsonKey(name: "success")
  bool? success;

  @JsonKey(name: "responseCode")
  int? responseCode;



  BaseModel({this.message, this.success,this.responseCode});

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BaseModelToJson(this);
}
