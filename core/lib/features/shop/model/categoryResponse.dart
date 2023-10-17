import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

part 'categoryResponse.g.dart';

@JsonSerializable()
class CategoryResponse extends BaseModel {
  @JsonKey(name: "category_count")
  int? category_count;

  @JsonKey(name: "pos_categories")
  List<Category>? pos_categories;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);

  CategoryResponse(this.category_count, this.pos_categories);
}

@JsonSerializable()
class Category {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "parent_id")
  dynamic parent_id;

  @JsonKey(name: "product_count")
  int? product_count;

  // @JsonKey(name: "child_id")
  // List<String> child_id;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  Category(this.id, this.name, this.parent_id, this.product_count);
}
