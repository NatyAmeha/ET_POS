import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hozmacore/exception/api_exception.dart';
import 'package:hozmacore/exception/db_exception.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppException implements Exception {
  final String? message;
  final int? statusCode;
  final int? type;
  final String? url;

  AppException({this.message, this.statusCode, this.url, this.type});

  static const TIMEOUT_EXCEPTION = 1;
  static const NETWORK_EXCEPTION = 2;
  static const UNAUTORIZED_EXCEPTION = 3;
  static const NOT_FOUND_EXCEPTION = 4;
  static const SERVER_EXCEPTION = 5;
  static const BAD_REQUEST_EXCEPTION = 6;
  static const CANCEL_EXCEPTION = 7;
  static const UNKNOWN_API__EXCEPTION = 8;
  static const UNKNOWN_EXCEPTION = 9;
  static const PREFERENCE_STORAGE_EXCEPTION = 10;
  static const DATABASE_EXCEPTION = 11;
  static const SESSION_ALREADY_OPENED = 12;
  static const  PRINTER_EXCEPTION = 13;

  

  AppException handleError(Object obj) {
    return AppException(message: "Error occured", type: UNKNOWN_EXCEPTION);
  }

  // identify wheather the exception is api exception, db exception, Shared preference exception or other exception
  // other exception can be added to if else statement
  AppException identifyErrorType(Object obj) {

    switch (obj.runtimeType) {
      case DioError:
        return ApiException().handleError(obj);
      case DatabaseException:
        return DBException().handleError(obj);
      case AppException:
        var ex = obj as AppException;
        return AppException(message: ex.message , statusCode: ex.statusCode, url: ex.url, type: ex.type);
      default:
        return handleError(obj);
    }
  }
}
