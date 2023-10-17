import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

part 'customerResponse.g.dart';

@JsonSerializable()
class CustomerResponse extends BaseModel {
  @JsonKey(name: "customers")
  List<Customer>? customers;

  @JsonKey(name: "customer_count")
  int? customer_count;

  factory CustomerResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerResponseToJson(this);

  CustomerResponse(this.customers, this.customer_count);
}

@JsonSerializable()
class Customer {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "street")
  String? street;

  @JsonKey(name: "state_id")
  dynamic state_id;
  @JsonKey(name: "city")
  String? city;
  @JsonKey(name: "vat")
  String? vat;

  @JsonKey(name: "country_id")
  dynamic country_id;
  @JsonKey(name: "property_product_pricelist")
  int? property_product_pricelist;
  @JsonKey(name: "phone")
  String? phone;

  @JsonKey(name: "zip")
  String? zip;
  @JsonKey(name: "property_account_position_id")
  dynamic property_account_position_id;
  @JsonKey(name: "email")
  String? email;

  @JsonKey(name: "barcode")
  String? barcode;
  @JsonKey(name: "mobile")
  String? mobile;
  @JsonKey(name: "write_date")
  String? write_date;
  @JsonKey(name: "sync_status")
  String? status;

  @JsonKey(name: "display_values", ignore: true)
  DisplayValues? display_values;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  Customer(
      this.id,
      this.name,
      this.street,
      this.state_id,
      this.city,
      this.vat,
      this.country_id,
      this.property_product_pricelist,
      this.phone,
      this.zip,
      this.property_account_position_id,
      this.email,
      this.barcode,
      this.mobile,
      this.write_date,
      this.status);
}

@JsonSerializable()
class DisplayValues {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "phone")
  String? phone;
  @JsonKey(name: "address")
  String? address;

  factory DisplayValues.fromJson(Map<String, dynamic> json) =>
      _$DisplayValuesFromJson(json);

  Map<String, dynamic> toJson() => _$DisplayValuesToJson(this);

  DisplayValues(this.name, this.phone, this.address);
}
