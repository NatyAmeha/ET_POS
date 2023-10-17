import 'package:flutter/material.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/utils/preference_helper.dart';

class AppConfigHelper{
  static Future<String> getSelectedLanguageFromPreference() async{
    var result = await PreferenceHelper.getDataFromPreference<String>(AppConstant.SELECTED_LANGUAGE_PREF_KEY) ?? LanguageEnum.ENGLISH.name;
    return result;
  }

  static Future<bool> saveSelectedLanguageToPreference(String selectedLanguage) async {
    var result =  await PreferenceHelper.setDataToPreference(AppConstant.SELECTED_LANGUAGE_PREF_KEY, selectedLanguage);
    return result;
  }

  static Locale getSelectedLocal(String selectedLanguage){
     if(selectedLanguage == LanguageEnum.ARABIC.name){
      return Locale('ar', '');
     }
     else{
      return Locale('en', '');
     }
  }

  

}