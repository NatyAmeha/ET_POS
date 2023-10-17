
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

part 'addCustomerResponse.g.dart';

@JsonSerializable()
class AddCustomerResponse extends BaseModel {

  @JsonKey(name: "partner_id")
  int? partnerId;

  factory AddCustomerResponse.fromJson(Map<String, dynamic> json) =>
      _$AddCustomerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AddCustomerResponseToJson(this);

  AddCustomerResponse(this.partnerId);
}
