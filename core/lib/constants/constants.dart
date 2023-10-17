class Constant{

  static const String PRODUCT_TABLE = "products";
  static const DB_CONFLICT_ALOGRITHIM_TYPE = "db_conflict_algorithim";
  
  static const PAIRED_DEVICES = "Paired devices";
  static const AVAILABLE_DEVICES = "Available devices";

  static String? DEFAULT_CURRENCY_SYMBOL = "USD";
  static String? DEFAULT_CURRENCY_POSITION = "after";

}

enum DbConflictAlgorithim{
  REPLACE, IGNORE
}

enum NumberPadAction{
  QTY, DELETE, PRICE, DISCOUNT
}

enum MultiWindowMessage{
  CLOSE_WINDOW
}

