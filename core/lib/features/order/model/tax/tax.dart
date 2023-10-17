import 'package:json_annotation/json_annotation.dart';

part 'tax.g.dart';

@JsonSerializable()
class Tax {
  int? id;
  String? name;
  double? amount;
  bool? price_include;
  bool? include_base_amount;
  String? amount_type;


  Tax({
    this.id,
    this.name,
    this.amount,
    this.price_include,
    this.include_base_amount,
    this.amount_type,
  });

  factory Tax.fromJson(Map<String, dynamic> json) =>
      _$TaxFromJson(json);

  Map<String, dynamic> toJson() => _$TaxToJson(this);
}

enum TaxType{
  percent
}
