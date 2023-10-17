class AppConstant{
  static const String APP_NAME = "hozma.tech.";
  static const String DB_PREFIX_NAME = "Restaurant_Profile";
  static String? DEFAULT_CURRENCY_SYMBOL = "USD";
  static String? DEFAULT_CURRENCY_POSITION = "after";

  static String SELECTED_LANGUAGE_PREF_KEY = "SELECTED_LANGUAGE";

  static const  int MAX_TIME_FOR_INACTIVITY_IN_SECOND = 180; // 3 MIN
  static const int TIME_TO_SHOW_INACTIVITY_DIALOG = 60; 
}


enum LanguageEnum{
  ENGLISH, ARABIC
}

enum OrderOptionType{
  TAKE_AWAY, EAT_IN
}

enum ReceiptOptions{
  SMS,EMAIL, PRINTED
}