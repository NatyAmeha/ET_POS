import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';

part 'cashOpen.g.dart';

@JsonSerializable()
class CashOpen extends LoginResponse {
  @JsonKey(name: "openingCash")
  double? openingCash;
  @JsonKey(name: "notes")
  String? notes;
  @JsonKey(name: "available_coins")
  List<AvailableCoin>? availableCoins;

  CashOpen(
      int? user_id,
      int? agent_id,
      String? agentProfileImage,
      String? agent_name,
      String? agent_email,
      String? agent_lang,
      String? agent_timezone,
      List<POSConfig>? pos_config,
      this.notes,
      this.availableCoins,
      this.openingCash)
      : super(user_id, agent_id, agentProfileImage, agent_name, agent_email,
            agent_lang, agent_timezone, pos_config);

  factory CashOpen.fromJson(Map<String, dynamic> json) =>
      _$CashOpenFromJson(json);

  Map<String, dynamic> toJson() => _$CashOpenToJson(this);
}

@JsonSerializable()
class AvailableCoin {
  AvailableCoin(this.id, this.value, this.name);

  int? id;
  double value;
  String? name;
  int? initialValue = 0;

  factory AvailableCoin.fromJson(Map<String, dynamic> json) =>
      _$AvailableCoinFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableCoinToJson(this);
}
