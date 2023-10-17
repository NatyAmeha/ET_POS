
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

part 'productResponse.g.dart';

@JsonSerializable()
class ProductResponse extends BaseModel {
  @JsonKey(name: "products")
  List<Product> products;
  @JsonKey(name: "product_count")
  int? product_count;


  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);

  ProductResponse(this.products,this.product_count);
}
