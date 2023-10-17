import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hozmacore/constants/api_constants.dart';

import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';

// this custom api client built with retrofit and dio. this class eventually replace customDio.dart class
class CustomApiClient {
  static Dio? _dioClient;
  

  static Future<APIEndPoint> getClient() async {
    String? workSpace = await SharedPreferenceRepository().get<String>(SharedPreferenceRepository.WORK_SPACE_URL);
    var baseUrl = 'https://' + (workSpace ?? "workspace");
    if (_dioClient == null) {
      var options = BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: 5000,
          receiveTimeout: 3000,
          validateStatus: (status) {
            return status! < 500;
          });

      _dioClient = Dio(options);
      //  String? loginKey = null;
      Map<String, String?> headers = <String, String?>{
        'Authorization': ApiConstants.BASIC_AUTH_KEY,
        'Accept': 'application/json',
        'content-type': 'text/plain',
      };
      

      _dioClient!.options.headers = headers;
      addInterceptors();
    }

    return APIEndPoint(_dioClient!, baseUrl: baseUrl);
  }

  static void addInterceptors() {
    _dioClient!.interceptors.clear();
    _dioClient!.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      
      //insert the updated login  key in the header for each request
      var sharedPrefernceStorage = SharedPreferenceRepository();
      var loginKey = await sharedPrefernceStorage.get<String>(SharedPreferenceRepository.LOGIN_KEY);
      if(loginKey != null){
         options.headers["Login"]= loginKey;
      }

      // This solves an issue where workspace is not loaded for the first login
      // TODO: We may need to defer calling getClient() until we get the workspace value
      var workSpace = await sharedPrefernceStorage.get<String>(SharedPreferenceRepository.WORK_SPACE_URL);
      options.baseUrl = 'https://' + workSpace!;
      
      debugPrint(
          "--> ${ options.method.toUpperCase()} ${"" + options.baseUrl + options.path}");
      print("Headers:");

      options.headers.forEach((k, v) => print('$k: $v'));
      if (options.queryParameters != null) {
        print("queryParameters:");
        options.queryParameters.forEach((k, v) => print('$k: $v'));
      }
      if (options.data != null) {
        print("Body: ${options.data}");
      }
      print(
          "--> END ${options.method != null ? options.method.toUpperCase() : 'METHOD'}");
      return handler.next(options);
    }, onResponse: (Response response, ResponseInterceptorHandler handler) {
      debugPrint(response.statusCode.toString() +
          "--> ${response.requestOptions != null ? response.requestOptions.method.toUpperCase() : 'METHOD'} ${"" + (response.requestOptions.baseUrl ?? "") + (response.requestOptions.path ?? "")}");

      if (response.data != null) {
        log("api response: ->${response.data.toString()} ${response.statusCode}");
      }
      handler.next(response);
    }));
  }
}
