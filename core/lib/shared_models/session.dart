
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';


part 'session.g.dart';

@JsonSerializable()
class Session extends BaseModel{

  @JsonKey(name: "session_id")
  int? session_id;

  @JsonKey(name: "login_number")
  int? login_number;

  @JsonKey(name: "config")
  Config config;


  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);

  Session(this.session_id, this.login_number, this.config);
}

@JsonSerializable()
class Config{
  @JsonKey(name: "to_invoice")
  bool? to_invoice;

  @JsonKey(name: "receipt_header")
  String? receipt_header;
  @JsonKey(name: "receipt_footer")
  String? receipt_footer;

  factory Config.fromJson(Map<String, dynamic> json) =>
      _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);

  Config(this.to_invoice, this.receipt_header, this.receipt_footer);
}