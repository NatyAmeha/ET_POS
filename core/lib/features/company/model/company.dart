import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  int? id;
  String? name;
  String? vat;
  String? company_registry;
  String? address;
  String? address2;
  String? zip;
  String? city;
  String? country;
  String? email;
  String? website;
  String? primary_color;
  String? secondary_color;
  String? favicon;
  String? logo;
  String? logo_web;

  Company({
    this.id,
    this.name,
    this.vat,
    this.company_registry,
    this.address,
    this.address2,
    this.zip,
    this.city,
    this.country,
    this.email,
    this.website,
    this.primary_color,
    this.secondary_color,
    this.favicon,
    this.logo,
    this.logo_web,
  });

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);

  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}
