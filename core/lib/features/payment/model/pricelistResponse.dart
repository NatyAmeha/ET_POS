import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

part 'pricelistResponse.g.dart';

@JsonSerializable()
class PriceListResponse extends BaseModel {
  @JsonKey(name: "pricelists")
  List<PriceListItem>? pricelists;

  factory PriceListResponse.fromJson(Map<String, dynamic> json) =>
      _$PriceListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PriceListResponseToJson(this);

  PriceListResponse(this.pricelists);
}

@JsonSerializable(explicitToJson: true)
class PriceListItem {
  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "data")
  List<PricelistData>? data;
  factory PriceListItem.fromJson(Map<String, dynamic> json) =>
      _$PriceListItemFromJson(json);

  Map<String, dynamic> toJson() => _$PriceListItemToJson(this);

  PriceListItem(this.id, this.name, this.data);
}

@JsonSerializable()
class PricelistData {
  @JsonKey(name: "productId")
  int? productId;

  @JsonKey(name: "price")
  double price;

  factory PricelistData.fromJson(Map<String, dynamic> json) =>
      _$PricelistDataFromJson(json);

  Map<String, dynamic> toJson() => _$PricelistDataToJson(this);

  PricelistData(this.productId, this.price);
}
