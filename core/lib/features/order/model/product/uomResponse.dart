import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/order/model/product/uomModel.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

part 'uomResponse.g.dart';

@JsonSerializable()
class UOMResponse extends BaseModel {
  @JsonKey(name: "uom")
  List<UOMModel>? uomList;

  factory UOMResponse.fromJson(Map<String, dynamic> json) =>
      _$UOMResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UOMResponseToJson(this);

  UOMResponse(this.uomList);
}
