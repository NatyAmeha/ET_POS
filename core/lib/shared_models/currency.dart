
import 'package:json_annotation/json_annotation.dart';

part 'currency.g.dart';

@JsonSerializable()
class Currency {

  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "symbol")
  String? symbol;

  @JsonKey(name: "position")
  String? position;

  @JsonKey(name: "decimal_places")
  int? decimal_places;

  Currency(this.id, this.symbol, this.position, this.decimal_places);


  factory Currency.fromJson(Map<String, dynamic> json) =>
      _$CurrencyFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyToJson(this);
}