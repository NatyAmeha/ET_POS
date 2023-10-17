import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

import 'country.dart';

part 'splashResponse.g.dart';

@JsonSerializable()
class SplashResponse extends BaseModel {
  @JsonKey(name: "countries")
  List<Country>? allCountries;

  @JsonKey(name: "users")
  List<User>? users;

  @JsonKey(name: "order_prefix")
  String? order_prefix;

  @JsonKey(name: "syc_order_limit")
  int? syc_order_limit;

  factory SplashResponse.fromJson(Map<String, dynamic> json) =>
      _$SplashResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SplashResponseToJson(this);

  SplashResponse(
      this.allCountries, this.order_prefix, this.syc_order_limit, this.users);
}

@JsonSerializable()
class User {
  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "pos_security_pin")
  dynamic pos_security_pin;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  User(this.id, this.name, this.pos_security_pin);
}
