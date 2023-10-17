import 'package:hozmacore/constants/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';
import 'package:hozmacore/shared_models/currency.dart';


part 'loginResponse.g.dart';

@JsonSerializable()
class LoginResponse extends BaseModel {

  @JsonKey(name: "user_id")
  int? user_id;
  @JsonKey(name: "agent_id")
  int? agent_id;
  @JsonKey(name: "agentProfileImage")
  String? agentProfileImage;

  @JsonKey(name: "agent_name")
  String? agent_name;
  @JsonKey(name: "agent_email")
  String? agent_email;

  @JsonKey(name: "agent_lang")
  String? agent_lang;
  @JsonKey(name: "agent_timezone")
  String? agent_timezone;

  @JsonKey(name: "pos_config")
  List<POSConfig>? pos_config;



  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  LoginResponse(
      this.user_id,
      this.agent_id,
      this.agentProfileImage,
      this.agent_name,
      this.agent_email,
      this.agent_lang,
      this.agent_timezone,
      this.pos_config,
   );
}

@JsonSerializable()
class POSConfig {
  String? status;

  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "display_button_new")
  bool? display_button_new;

  @JsonKey(name: "display_button_resume")
  bool? display_button_resume;

  @JsonKey(name: "display_button_close")
  bool? display_button_close;

  @JsonKey(name: "currency")
  List<Currency> currency;

  POSConfig(this.id, this.name, this.display_button_new,
      this.display_button_resume, this.display_button_close, this.currency);

  factory POSConfig.fromJson(Map<String, dynamic> json) =>
      _$POSConfigFromJson(json);

  Map<String, dynamic> toJson() => _$POSConfigToJson(this);

  String getPriceStringWithConfiguration(double price){
    var  currencyPosition = this.currency.firstOrNull?.position ?? Constant.DEFAULT_CURRENCY_POSITION;
    var  currencySymbol = this.currency.firstOrNull?.symbol ?? Constant.DEFAULT_CURRENCY_SYMBOL;
    return currencyPosition == "before"
                    ? "$currencySymbol ${price.toStringAsFixed(2)}"
                    : "${price.toStringAsFixed(2)} $currencySymbol";
  }
}
