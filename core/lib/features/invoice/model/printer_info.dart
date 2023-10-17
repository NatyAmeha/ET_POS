import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:hozmacore/constants/constants.dart';
part 'printer_info.g.dart';

@JsonSerializable()
class HTPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  String? protocol;
  String? typePrinter;
  bool? state;
  String? printFormat;   // Image or pdf
  String? printType;
  String? paperSize;
  @JsonKey(includeFromJson: false, includeToJson: false)
  Uint8List? testData; // this is for simplfying nested callback, it's not important field, it's just to carry test data through navigations
  HTPrinter({
    this.deviceName,
    this.address,
    this.port,
    this.state,
    this.vendorId,
    this.productId,
    this.protocol = "Epson Protocol", // can't use protocol enum value as initial value b/c enum value is not constant
    this.typePrinter = "BLUETOOTH",
    this.printFormat = "Image",
    this.printType,
    this.paperSize = "MM57",
    this.testData,
  });
  
  @override
  bool operator ==(Object other) {
    return other is HTPrinter && other.hashCode == hashCode;
  }

  @override
  int get hashCode => Object.hash(deviceName, address, port, state, vendorId, productId , protocol, typePrinter, printFormat, printType, paperSize);

  factory HTPrinter.fromJson(Map<String, dynamic> json) =>
      _$HTPrinterFromJson(json);

  Map<String, dynamic> toJson() => _$HTPrinterToJson(this);

  static GlobalKey<NavigatorState> PrinterSetupNavigationKey =  GlobalKey();
  static const printerSetupRoute = "/printer_setup";
  static const printerSetupConfirmationRoute = "/printer_setup_confirmation";

  static const EPSON_PROTOCOL = "Epson Protocol";
  static const OBSOLETE_EPSON_PROTOCOL = "Obsolete Epson Protocol";
}

enum PrinterAction{
  Connect, Disconnect, Info, Remove, TestPrint
}

enum PrintFormat{
  Image, Pdf
}
enum PrintType{
  Invoice , Order
}

enum PrintPaperSize{
  MM57,  
  MM80, 
  A4  
}

enum HTPrinterType{
  BLUTOOTH, USB , NETWORK
}

// used in network_printer_scanner dialog to determine whether the dialog used for scanning network printers or connect to network printer with ip and port
enum NetworkPrinterAction{
  SCAN, CONNECT
}





enum CustomPrinterConnectionStatus {NOT_CONNECTED, CONNECTING, CONNECTED, SCANNING, STOP_SCANNING }