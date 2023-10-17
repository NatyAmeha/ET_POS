import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/datasource/irepository.dart';

import 'package:shared_preferences/shared_preferences.dart';

abstract class ISharedPrefRepository<T> extends IRepository<T> {
  Future<bool> removeAllDataFromPreference();
}

class SharedPreferenceRepository<T> implements ISharedPrefRepository<T> {
  static String TAG = "MySharedPref";
  static String ID = "";
  static String LOGIN_KEY = "LOGIN_KEY";
  static String LANG_KEY = "LANG_KEY";
  static String FCM_KEY = "FCM_KEY";
  static String DEVICE_ID_KEY = "DEVICE_KEY";

  static String D_ID = "D_ID";
  static String D_NAME = "D_NAME";
  static String D_IMAGE = "D_IMAGE";
  static String D_IS_LOGGED = "D_IS_LOGGED";
  static String NOTIFICATION_COUNT = "NOTIFICATION_COUNT";
  static String ORDER_PREFIX = "ORDER_PREFIX";
  static String ORDER_LIMIT = "ORDER_LIMIT";

  static String USER_ID = "USER_ID";
  static String AGENT_ID = "AGENT_ID";
  static String AGEBNT_PROFILE_IMAGE = "AGEBNT_PROFILE_IMAGE";
  static String AGENT_NAME = "AGENT_NAME";
  static String AGENT_EMAIL = "AGENT_EMAIL";
  static String AGENT_LANG = "AGENT_LANG";
  static String SHOP_NAME = "SHOP_NAME";
  static String SHOP_ID = "SHOP_ID";

  static String CURRENCY_SYMBOL = "CURRENCY_SYMBOL";
  static String CURRENCY_POSTION = "CURRENCY_POSTION";
  static String PRICE_DECIMAL = "PRICE_DECIMAL";

  static String PRODUCT_DATA_SAVED = "PRODUCT_DATA_SAVED";
  static String CUSTOMER_DATA_SAVED = "CUSTOMER_DATA_SAVED";

  static String SESSION_ID = "SESSION_ID";
  static String LAST_ORDER_ID = "LAST_ORDER_ID";

  static String LOGIN_NUMBER = "LOGIN_NUMBER";
  static String APP_OPENED = "APP_OPENED";
  static String CONFIG_ID = "CONFIG_ID";
  static String OPENING_BALANCE = "OPENING_BALANCE";
  static String OPENING_BALANCE_NOTE = "OPENING_BALANCE_NOTE";
  static String TOTAL_CASH = "TOTAL_CASH";
  static String TOTAL_BANK = "TOTAL_BANK";

  static String WORK_SPACE_URL = "WORK_SPACE_URL";
  static String PRINTER_REFERENCE = "PRINTER_REFERENCE_";
  static String PAIRED_PRINTERS = "PAIRED_PRINTERS";

  const SharedPreferenceRepository();
  @override
  Future<R> create<R, S>(String path, S body,
      {Map<String, dynamic>? queryParameters}) async {
    var sharedPref = await SharedPreferences.getInstance();
    print("pref type ${S.toString()}");
    try {
      switch (S) {
        case String:
          var result = await sharedPref.setString(path, body as String);
          print(result);
          return result as R;

        case int:
          var result = await sharedPref.setInt(path, body as int);
          return result as R;

        case bool:
          var result = await sharedPref.setBool(path, body as bool);
          return result as R;
        case const (List<String>):
          var result =
              await sharedPref.setStringList(path, body as List<String>);
          return result as R;
        default:
          return Future.error(AppException(
              message: "Trying to save unsupported type to preference"));
      }
    } catch (e) {
      print(e.toString());
      return Future.error(AppException(
          type: AppException.PREFERENCE_STORAGE_EXCEPTION,
          message: e.toString()));
    }
  }

  @override
  Future<List<R>> getAll<R>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      switch (R) {
        case String:
          var result= await sharedPref.getStringList(path);
          if(result == null || result.isEmpty == true){
            return [];
          }
          else{
            return result as List<R>;
          }
        default:
          return [];
      }
    } catch (ex) {
      return Future.error(AppException(
          type: AppException.PREFERENCE_STORAGE_EXCEPTION,
          message: ex.toString()));
    }
  }

  @override
  Future<R?> get<R>(String path,
      {Map<String, dynamic>? queryParameters}) async {
    var sharedPref = await SharedPreferences.getInstance();
    try {
      switch (R) {
        case String:
          if (sharedPref.containsKey(path)) {
            var result = sharedPref.getString(path);
            return result as R?;
          } else {
            return null;
          }

        case int:
          if (sharedPref.containsKey(path)) {
            var result = sharedPref.getInt(path);
            return result as R?;
          } else {
            return null;
          }

        case bool:
          var rr = sharedPref.containsKey(path);
          print("get result $rr");
          if (sharedPref.containsKey(path)) {
            var result = sharedPref.getBool(path);
            return result as R?;
          } else {
            return null;
          }

        case const (List<String>):
          if (sharedPref.containsKey(path)) {
            var result = sharedPref.getStringList(path);
            return result as R?;
          } else {
            return null;
          }

        default:
          return null;
      }
    } catch (e) {
      print(e.toString());
      return Future.error(AppException(
          type: AppException.PREFERENCE_STORAGE_EXCEPTION,
          message: e.toString()));
    }
  }

  @override
  Future<R> update<R, S>(String path,
      {S? body, Map<String, dynamic>? queryParameters}) async {
    try {
      return true as R;
    } catch (ex) {
      return Future.error(AppException(
          type: AppException.PREFERENCE_STORAGE_EXCEPTION,
          message: "trying to remove non existent key from preference"));
    }
  }

  @override
  Future<bool> delete(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      var result = await sharedPref.remove(path);
      return result;
    } catch (ex) {
      print(ex);
      return Future.error(AppException(
          type: AppException.PREFERENCE_STORAGE_EXCEPTION,
          message: "trying to remove non existent key from preference"));
    }
  }
  
  @override
  Future<bool> removeAllDataFromPreference() async {
    try {
      var sharedPref = await SharedPreferences.getInstance();
      var result =await sharedPref.clear();
      return result;
    } catch (ex) {
      return Future.error(AppException(
          type: AppException.PREFERENCE_STORAGE_EXCEPTION,
          message: "Unable to remove all data from preference"));
    }
  }

  
}
