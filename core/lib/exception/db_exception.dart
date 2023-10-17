import 'package:hozmacore/exception/app_exception.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBException extends AppException{
  @override
  AppException handleError(Object obj) {
    if(obj.runtimeType == DatabaseException){
      var dbException = obj as DatabaseException;
      return AppException(type: AppException.DATABASE_EXCEPTION , message: dbException.toString());
    }
    return super.handleError(obj);
  }
}