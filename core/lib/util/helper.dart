import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/shared_services/connectivity_service.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:pdf/pdf.dart';


class Helper{

  IConnectivityService? connectivityService;

  Helper({this.connectivityService});


  Stream<String> getNetworkConnectivity() {
    return connectivityService!.getConnectivityStatus();
  }

  static Future<R?> getDataFromPreference<R>(String name) async{
    try {
      var prefRepo = SharedPreferenceRepository();
      var result = await prefRepo.get<R>(name);
      return result;
    } on AppException catch (ex) {
      return Future.error(ex);
    }
  }

  static Future<bool> setDataToPreference<T>(String name , T data) async{
    try {
      var prefRepo = SharedPreferenceRepository();
      var result = await prefRepo.create<bool , T>(name , data);
      return result;
    } on AppException catch (ex) {
      return Future.error(ex);
    }
  }



  static ScaffoldMessengerState showSnackbar(BuildContext context , String message , {Color? color = Colors.green , IconData? prefixIcon = Icons.check_circle , Duration duration = const Duration(seconds: 1)}){
    var snackbar =  ScaffoldMessenger.of(context);
    snackbar.removeCurrentSnackBar();
    snackbar.showSnackBar(SnackBar(
      backgroundColor: color ?? Colors.green,
      duration: duration,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(prefixIcon , color: Colors.white),
          const SizedBox(width: 16),
          Flexible(child: Text(message)) 
        ],
      ), 
      margin: EdgeInsets.symmetric(vertical: 70 , horizontal:  Helper.isTablet(context) ? 80 : 24),
    ));
    return snackbar;
  }

  

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape && MediaQuery.of(context).size.height > 600; 
  }
}