import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

part 'payment.g.dart';

@JsonSerializable()
class PaymentResponse extends BaseModel {
  @JsonKey(name: "payments")
  List<Payment>? payments;

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);

  PaymentResponse(this.payments);
}

@JsonSerializable()
class Payment {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "type")
  String? type;

  @JsonKey(name: "amountTendered")
  String? amountTendered;

  @JsonKey(name: "amountReturned")
  String? amountReturned;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  Payment(
      this.id, this.name, this.type, this.amountTendered, this.amountReturned);
}
