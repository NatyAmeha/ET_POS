import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hozmacore/exception/app_exception.dart';

abstract class IBarcodeService{
  Future<String> scanBarCode(String lineColor , bool showFlashLight);
}

class BarcodeService extends IBarcodeService{
  @override
  Future<String> scanBarCode(String lineColor, bool showFlashLight) async {
    try{
      var scanResponse = await FlutterBarcodeScanner.scanBarcode(lineColor , "Cancel" , showFlashLight , ScanMode.BARCODE);
      if (scanResponse == "-1") {
        return Future.error(AppException(message: "Unknown reponse"));
      }
      return scanResponse;
    } on PlatformException catch(ex){
      return Future.error(AppException(message: 'Failed to get platform version.'));
    } on FormatException catch(ex){
      return Future.error(AppException(message: 'Nothing captured, please try again'));
    } catch(otherException){
      log("${otherException.toString()}" , name: "barcode scan error");
      return Future.error(AppException(message: 'Unknown error occured while scanning barcode'));
    }
  }

}