

import 'package:darq/darq.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';

part 'product.g.dart';

@JsonSerializable()
class Product{
  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "uom_id")
  int? uom_id;

  @JsonKey(name: "unit_count")
  int? unitCount =1;

  @JsonKey(name: "discount")
  String? discount;

  @JsonKey(name: "uom_name")
  String? uom_name;

  @JsonKey(name: "to_weight")
  dynamic to_weight;
  @JsonKey(name: "barcode")
  String? barcode;


  @JsonKey(name: "pos_categ_id")
  dynamic pos_categ_id;
  @JsonKey(name: "image_url")
  String? image_url;


  @JsonKey(name: "price_tax_inclusive")
  String? price_tax_inclusive;
  @JsonKey(name: "price_tax_exclusive")
  String? price_tax_exclusive;

  String? unitTax;

  @JsonKey(name: "unit_price")
  String? unit_price;
  @JsonKey(name: "lst_price")
  String? lst_price;


  @JsonKey(name: "display_name")
  String? display_name;
  
  List<int>? taxes_id;



  Product(
      this.uom_id,
      this.uom_name,
      this.to_weight,
      this.barcode,
      this.pos_categ_id,
      this.image_url,
      this.price_tax_inclusive,
      this.price_tax_exclusive,
      this.unit_price,
      this.lst_price,
      this.display_name,
      this.unitTax,
      this.id,
      {this.unitCount=1,
      this.discount,
      this.taxes_id,
    }
  );

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  String priceWithQtyAndUom(){
    return "${this.unitCount} * ${this.unit_price} ${this.uom_name != null ? "/" + this.uom_name! : ""}";
  }

  String getUnitPriceWithConfiguration(String currencyPosition, String currencySymbol){
     return currencyPosition == "before"
                    ? "$currencySymbol ${double.parse(this.unit_price!).toStringAsFixed(2)}"
                    : "${double.parse(this.unit_price!).toStringAsFixed(2)} $currencySymbol";

  }

  String discountInfo(){
    return "with ${this.discount}% discount";
  }

  double calculateFinalPriceTaxIncluded(List<Tax>? taxes) {
    var taxwithDiscount = calculateTaxWithDiscountApplied(taxes);
    var productPrice = (double.parse(this.unit_price!) * this.unitCount!);
    if (this.discount == null || this.discount!.isEmpty || productPrice == 0) {
      return productPrice + taxwithDiscount;
    } else {
      var disAmount = (productPrice * double.parse(this.discount!)) / 100;
      var finalAmount = productPrice - disAmount;
      return finalAmount + taxwithDiscount;
    }
  }

  double calculateUnitPriceTaxIncluded(List<Tax>? taxes) {
    var taxwithDiscount = calculateTaxWithDiscountApplied(taxes);
    var productPrice = (double.parse(this.unit_price!) * this.unitCount!);
    if (this.discount == null || this.discount!.isEmpty || productPrice == 0) {
      return (productPrice + taxwithDiscount) / this.unitCount!;
    } else {
      var disAmount = (productPrice * double.parse(this.discount!)) / 100;
      var finalAmount = productPrice - disAmount;
      return (finalAmount + taxwithDiscount)/unitCount!;
    }
  }

  double calculateFinalPriceTaxExcluded() {
    var totalAmount =
        (double.parse(this.unit_price!) * this.unitCount!);
    if (this.discount == null || this.discount!.isEmpty || totalAmount == 0) {
      return totalAmount;
    } else {
      var disAmount = (totalAmount * double.parse(this.discount!)) / 100;
      var finalAmount = totalAmount - disAmount;
      return finalAmount;
    }
  }

  double calculateTaxWithDiscountApplied(List<Tax>? taxes) {
    var totalTaxAmount = 0.0;
    var taxesAppliedOnTheProduct = taxes?.where((tax) => this.taxes_id?.contains(tax.id) == true);
    if(taxesAppliedOnTheProduct?.isNotEmpty == true){
      taxesAppliedOnTheProduct!.forEach((productTax) {
        if(productTax.amount_type == TaxType.percent.name){
          totalTaxAmount += ((double.parse(this.unit_price!) * productTax.amount!) / 100) * (this.unitCount ?? 1); 
        }
      });
      if (this.discount == null || this.discount?.isEmpty == true) {
        return totalTaxAmount;
      } else {
        var discount = (totalTaxAmount * double.parse(this.discount!)) / 100;
        var finalTaxAmountAfterDiscount = totalTaxAmount - discount;
        return finalTaxAmountAfterDiscount;
      }
    } else{
      return totalTaxAmount;
    }
  }

  static double calculateDiscount(Product element) {
    return element.discount == null
        ? 0
        : ((double.parse(element.unit_price!) * element.unitCount!) *double.parse(element.discount!)) / 100;
  }

  static double calculateTotalAmountOfCartTaxExcluded(List<Product> cartProducts) {
    double totalAmount = 0;
    cartProducts.forEach((element) {
      totalAmount = totalAmount + element. calculateFinalPriceTaxExcluded();
    });
    return totalAmount;
  }


  // will be moved to cart model
  static double calculateTotalTaxAmountofCart(List<Product> cartProducts, List<Tax>? taxes) {
    var tax = 0.0;
    cartProducts.forEach((element) {
      tax = tax + element.calculateTaxWithDiscountApplied(taxes);
    });
    return tax;
  }
  // will be moved to cart model
  static double getTotalAmountOfCartTaxIncluded(List<Product> cartProducts, List<Tax>? taxes) {
    double totalAmount = 0;
    totalAmount =  calculateTotalAmountOfCartTaxExcluded(cartProducts) + calculateTotalTaxAmountofCart(cartProducts, taxes);
    return totalAmount;
  }
}