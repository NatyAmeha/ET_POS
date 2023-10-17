
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';

part 'holdCartModel.g.dart';

@JsonSerializable()
class HoldCartModel{
  @JsonKey(name: "date")
  String? date;

  @JsonKey(name: "customer")
  Customer? customer;

  @JsonKey(name: "products")
  List<Product>? products;


  factory HoldCartModel.fromJson(Map<String, dynamic> json) =>
      _$HoldCartModelFromJson(json);

  Map<String, dynamic> toJson() => _$HoldCartModelToJson(this);

  HoldCartModel(this.date, this.customer, this.products);


  double getTotalAmountOfHoldCartTaxIncluded(List<Tax>? taxes) {
    double totalAmount = 0;
    if(this.products?.isNotEmpty == true){
      totalAmount = Product.getTotalAmountOfCartTaxIncluded(this.products!, taxes);
    }
    return totalAmount;
  }
}


