import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';

import 'cashOpen.dart';

part 'cashClose.g.dart';

@JsonSerializable()
class CashClose extends LoginResponse {
  @JsonKey(name: "payment_input")
  Map<String, PaymentInput> paymentInput;
  @JsonKey(name: "orders_details")
  OrdersDetails ordersDetails;
  @JsonKey(name: "payments_amount")
  double paymentsAmount;
  @JsonKey(name: "pay_later_amount")
  double payLaterAmount;
  @JsonKey(name: "opening_notes")
  String? openingNotes;
  @JsonKey(name: "default_cash_details")
  DefaultCashDetails defaultCashDetails;
  @JsonKey(name: "other_payment_methods")
  List<OtherPaymentMethod> otherPaymentMethods;
  @JsonKey(name: "is_manager")
  bool? isManager;
  @JsonKey(name: "amount_authorized_diff")
  dynamic amountAuthorizedDiff;

  CashClose(
      int? user_id,
      int? agent_id,
      String? agentProfileImage,
      String? agent_name,
      String? agent_email,
      String? agent_lang,
      String? agent_timezone,
      List<POSConfig>? pos_config,
      this.amountAuthorizedDiff,
      this.defaultCashDetails,
      this.isManager,
      this.openingNotes,
      this.ordersDetails,
      this.otherPaymentMethods,
      this.payLaterAmount,
      this.paymentInput,
      this.paymentsAmount)
      : super(user_id, agent_id, agentProfileImage, agent_name, agent_email,
            agent_lang, agent_timezone, pos_config);

  factory CashClose.fromJson(Map<String, dynamic> json) =>
      _$CashCloseFromJson(json);

  Map<String, dynamic> toJson() => _$CashCloseToJson(this);
}

@JsonSerializable()
class OrdersDetails {
  OrdersDetails({
    this.quantity,
    this.amount,
  });

  int? quantity;
  double? amount;

  factory OrdersDetails.fromJson(Map<String, dynamic> json) =>
      _$OrdersDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$OrdersDetailsToJson(this);
}

@JsonSerializable()
class OtherPaymentMethod {
  OtherPaymentMethod({
    this.name,
    this.amount,
    this.number,
    this.id,
    this.type,
  });

  String? name;
  double? amount;
  int? number;
  int? id;
  String? type;

  factory OtherPaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$OtherPaymentMethodFromJson(json);

  Map<String, dynamic> toJson() => _$OtherPaymentMethodToJson(this);
}

@JsonSerializable()
class DefaultCashDetails {
  DefaultCashDetails({
    this.name,
    this.amount,
    this.opening,
    this.paymentAmount,
    this.moves,
    this.id,
  });

  String? name;
  double? amount;
  double? opening;
  @JsonKey(name: "payment_amount")
  double? paymentAmount;
  List<dynamic>? moves;
  int? id;

  factory DefaultCashDetails.fromJson(Map<String, dynamic> json) =>
      _$DefaultCashDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$DefaultCashDetailsToJson(this);
}

@JsonSerializable()
class PaymentInput {
  PaymentInput({
    this.counted,
    this.difference,
    this.number,
    this.availableCoins,
  });

  double? counted;
  double? difference;
  int? number;
  @JsonKey(name: "available_coins")
  List<AvailableCoin>? availableCoins;

  factory PaymentInput.fromJson(Map<String, dynamic> json) =>
      _$PaymentInputFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentInputToJson(this);
}
