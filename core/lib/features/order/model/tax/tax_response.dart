import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';

part 'tax_response.g.dart';

@JsonSerializable(explicitToJson: true)
class TaxResponse {
  bool? success;
  int? code;
  String? message;
  dynamic addons;
  int? user_id;
  String? agentProfileImage;
  int? agent_id;
  String? agent_name;
  String? agent_email;
  String? agent_lang;
  String? agent_timezone;
  List<Tax>? taxes;

  TaxResponse({
    this.success,
    this.code,
    this.message,
    this.addons,
    this.user_id,
    this.agentProfileImage,
    this.agent_id,
    this.agent_name,
    this.agent_email,
    this.agent_lang,
    this.agent_timezone,
    this.taxes,
  });

  factory TaxResponse.fromJson(Map<String, dynamic> json) =>
      _$TaxResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TaxResponseToJson(this);
}
