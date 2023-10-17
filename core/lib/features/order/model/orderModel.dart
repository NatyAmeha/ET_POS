import 'package:collection/collection.dart';
import 'package:darq/darq.dart';
import 'package:get/get.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';

part 'orderModel.g.dart';

@JsonSerializable()
class OrderModel {
  @JsonKey(name: "config_id")
  String? config_id;

  @JsonKey(name: "session_id")
  int? session_id;

  @JsonKey(name: "orders")
  List<Order> orders;

  @JsonKey(name: "customer")
  Customer? customer;

  @JsonKey(name: "sync_status")
  String? syncStatus;

  OrderModel(this.config_id, this.session_id, this.orders, this.customer,this.syncStatus);

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
  
}

@JsonSerializable()
class Order {
  // @JsonKey(name: "payment_ids")
  // List<PaymentIds> payment_ids;

  @JsonKey(name: "payment_method_id")
  List<PaymentIds> payment_method_id;

  @JsonKey(name: "paymentName")
  String? paymentName;

  @JsonKey(name: "username")
  String? username;


  @JsonKey(name: "lines")
  List<Line> lines;

  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "amount_paid")
  double amount_paid;

  @JsonKey(name: "amount_total")
  String? amount_total;

  @JsonKey(name: "partner_id")
  dynamic partner_id;

  @JsonKey(name: "creation_date")
  String? creation_date;

  @JsonKey(name: "amount_return")
  double amount_return;
  @JsonKey(name: "config_id")
  String? config_id;

  @JsonKey(name: "state")
  String? state;


  Order(
      // this.payment_ids,
      this.lines,
      this.id,
      this.name,
      this.amount_paid,
      this.amount_total,
      this.partner_id,
      this.creation_date,
      this.amount_return,
      this.config_id,
      this.payment_method_id,
      this.paymentName,
      this.state,
      this.username
      );

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);

  getSubtotal() {
    return this.lines.sum((e) {
      return (double.parse(e.price_unit!) * (e.qty ?? 1)) - e.discountAmount;
    });
  }

  double getTotalVat(List<Product>? products, List<Tax>? taxes) {
    var total = 0.0;
    this.lines.forEach((item) {
      var vat = item.getVatAmount(products, taxes);
      total += vat;
    });
    return total.toPrecision(2);
  }
}

@JsonSerializable()
class PaymentIds {
  @JsonKey(name: "amount")
  double amount;

  @JsonKey(name: "payment_id")
  int? payment_id;

  factory PaymentIds.fromJson(Map<String, dynamic> json) =>
      _$PaymentIdsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentIdsToJson(this);

  PaymentIds(this.amount, this.payment_id);
}

@JsonSerializable()
class Line {
  @JsonKey(name: "display_name")
  String? display_name;

  @JsonKey(name: "product_id")
  int? product_id;

  @JsonKey(name: "price_unit")
  String? price_unit;

  @JsonKey(name: "price_subtotal")
  double price_subtotal;

  @JsonKey(name: "refunded_qty")
  double? refunded_qty;

  @JsonKey(name: "price_subtotal_incl")
  double price_subtotal_incl;

  @JsonKey(name: "qty")
  int? qty;

  @JsonKey(name: "discount")
  double discount;

  @JsonKey(name: "discountAmount")
  double discountAmount;

  @JsonKey(name: "id")
  String? id;

  factory Line.fromJson(Map<String, dynamic> json) => _$LineFromJson(json);

  Map<String, dynamic> toJson() => _$LineToJson(this);

  Line(this.display_name, this.product_id, this.price_unit, this.refunded_qty, this.price_subtotal,
      this.price_subtotal_incl, this.qty, this.discountAmount, this.id,this.discount);
  
  String itemQtyWithPriceInfo(){
    return "${this.qty} * ${this.price_unit}";
  }

  String refundInfo(){
    return "To refund ${this.refunded_qty}";
  }

  String discountInfo() {
    return "with ${this.discount}% discount";
  }

  double getTotalAmount(List<Product>? products, List<Tax>? taxes){
    var selectedProduct = products?.firstWhereOrNull((product) => product.id == this.product_id);
    var totalTaxAmount = 0.0;
    var totalPriceTaxExcluded = double.parse(this.price_unit!);
    // calculate tax
    if(selectedProduct != null){
      totalTaxAmount = getVatAmount(products, taxes);
      if(this.discount > 0){
        var discount = (totalPriceTaxExcluded * this.discount) / 100; 
        totalPriceTaxExcluded -= discount;
      }
      return ((totalPriceTaxExcluded * (this.qty ?? 1)) + totalTaxAmount);
    } else {
      return totalPriceTaxExcluded;
    }    
  }

  double getVatAmount(List<Product>? products, List<Tax>? taxes){
    var selectedProduct = products?.firstWhereOrNull((product) => product.id == this.product_id);
    var totalTaxAmount = 0.0;
    if(selectedProduct != null){
      var taxesAppliedOnTheProduct = taxes?.where((tax) => selectedProduct.taxes_id?.contains(tax.id) == true);
      if (taxesAppliedOnTheProduct?.isNotEmpty == true) {
        taxesAppliedOnTheProduct!.forEach((productTax) {
          if (productTax.amount_type == TaxType.percent.name) {
            totalTaxAmount += (((double.parse(this.price_unit!)) * productTax.amount!) / 100);
            if(this.discount > 0){
              var discount = (totalTaxAmount * this.discount) / 100; 
              totalTaxAmount -= discount;
            }
          }
        }); 
      }
    }
    return totalTaxAmount * (this.qty ?? 1);
  }

}
