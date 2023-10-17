import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';

class PreferenceHelper{
  static Future<R?> getDataFromPreference<R>(String name) async {
    try {
      var prefRepo = SharedPreferenceRepository();
      var result = await prefRepo.get<R>(name);
      return result;
    } on AppException catch (ex) {
      return Future.error(ex);
    }
  }

  static Future<bool> setDataToPreference<T>(String name, T data) async {
    try {
      var prefRepo = SharedPreferenceRepository();
      var result = await prefRepo.create<bool, T>(name, data);
      return result;
    } on AppException catch (ex) {
      return Future.error(ex);
    }
  }
}