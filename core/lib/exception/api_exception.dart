import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hozmacore/exception/app_exception.dart';

class ApiException extends AppException{
 

  @override
  AppException handleError(Object obj) {
    
    if(obj.runtimeType == DioError){
       var exception = obj as DioError;
       switch (exception.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        return AppException(
          type: AppException.TIMEOUT_EXCEPTION, message: "Unable to connect to the server",
        );

      case DioErrorType.response:
        switch (exception.response?.statusCode) {
          case 401:
            return AppException(
                type: AppException.UNAUTORIZED_EXCEPTION, message: exception.message , statusCode: 401);
          case 404:
            return AppException(type: AppException.NOT_FOUND_EXCEPTION, message: exception.message ,  statusCode: 404);
          case 500:
            return AppException(type: AppException.SERVER_EXCEPTION, message: exception.message , statusCode: 500);
          case 400:
            var exceptionResponse = exception.response?.data;
            return AppException(
                type: AppException.BAD_REQUEST_EXCEPTION,
                message: exceptionResponse["message"].toString(), statusCode: 400);

          default:
            return AppException(type: AppException.UNKNOWN_API__EXCEPTION, message: exception.message );
        }

      case DioErrorType.cancel:
        return AppException(
            type: AppException.CANCEL_EXCEPTION, message: exception.message);

      case DioErrorType.other:
        log(exception.error.toString() , name: "unkown api error");
        return AppException(
            type: AppException.UNKNOWN_EXCEPTION,
            message: "Unable to connect to server");

      default:
        return AppException(
            type: AppException.UNKNOWN_API__EXCEPTION, message: exception.message);
    }
    }
    else{
      return super.handleError(obj);
    }
  }

}