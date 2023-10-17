import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/esc_pos_utils_platform.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:image/image.dart' as img;

abstract class IPrintService {
  Stream<HTPrinter> scanPrinter({String? ipAddress});
  Future<bool> connect(HTPrinter printer, bool autoReconnect);
  Future<bool> print(dynamic data , HTPrinter selectedPrinter);
  Stream<Map<String, CustomPrinterConnectionStatus>> listenPrinterConnectinStatus();
  Future<bool> disconnect(HTPrinter printer);
}

generatePosCommandToPrint(HTPrinter printer ,  Uint8List receiptImage) async{
    PaperSize? size;
    List<int> data = [];
    var profile = await CapabilityProfile.load();
    if(printer.paperSize == PrintPaperSize.MM57.name){
       size = PaperSize.mm58;
    }
    else if(printer.paperSize == PrintPaperSize.MM80.name){
       size = PaperSize.mm80;
    }
    if(size !=null){
      var generator = Generator(size , profile);
      var imageBytes = await img.decodeImage(receiptImage);
      log("Printer protocol ${printer.protocol}");
      if(imageBytes != null){
        if(printer.protocol == HTPrinter.EPSON_PROTOCOL){
          data += generator.image(imageBytes);
        }
        else if(printer.protocol == HTPrinter.OBSOLETE_EPSON_PROTOCOL){
          data += generator.imageRaster(imageBytes);
        }
      }

      data += generator.feed(2);
      data += generator.cut();
    }
    return data;
  }


class BluetoothPrinter implements IPrintService {
  ISharedPrefRepository preferenceRepo;
  CustomPrinterConnectionStatus bluetoothPrinterStatus = CustomPrinterConnectionStatus.NOT_CONNECTED;

  BluetoothPrinter({this.preferenceRepo = const SharedPreferenceRepository()});

  @override
  Stream<HTPrinter> scanPrinter({String? ipAddress}) {
    try{
      return PrinterManager.instance.discovery(type: PrinterType.bluetooth , isBle: false).map((deviceInfo){
        return HTPrinter(
          deviceName: deviceInfo.name,
          address: deviceInfo.address,
          vendorId: deviceInfo.vendorId,
          productId: deviceInfo.productId,
          typePrinter: HTPrinterType.BLUTOOTH.name,
        );
      });
    } catch (ex) {
      return Stream.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }

  @override
  Future<bool> connect(HTPrinter printer, bool autoReconnect) async {
    try {
      var printerManager = PrinterManager.instance;
      var printerInfo = BluetoothPrinterInput(name: printer.deviceName,address: printer.address!,isBle: false,autoConnect: autoReconnect);
      var connectionStatus = await printerManager.connect(type: PrinterType.bluetooth, model: printerInfo);
      return connectionStatus;
    } catch (ex) {
      return Future.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }

  @override
  Stream<Map<String, CustomPrinterConnectionStatus>> listenPrinterConnectinStatus() {
    try{
      return PrinterManager.instance.stateBluetooth.map((event){
        if(event == BTStatus.connecting){
          bluetoothPrinterStatus =  CustomPrinterConnectionStatus.CONNECTING;
          return {"id" : bluetoothPrinterStatus};
        }
        if(event == BTStatus.connected){
          bluetoothPrinterStatus = CustomPrinterConnectionStatus.CONNECTED;
          return {"id" : bluetoothPrinterStatus};
        }
        else if(event == BTStatus.scanning){
          bluetoothPrinterStatus = CustomPrinterConnectionStatus.SCANNING;
          return {"id" : bluetoothPrinterStatus};
        }
        else if(event == BTStatus.stopScanning){
          bluetoothPrinterStatus = CustomPrinterConnectionStatus.STOP_SCANNING;
          return {"id" : bluetoothPrinterStatus};
        }
        else{
          bluetoothPrinterStatus = CustomPrinterConnectionStatus.NOT_CONNECTED;
          return {"id" : bluetoothPrinterStatus};
        }
      });
    }catch(ex){
      return Stream.error(AppException(message: "unable to listen bluetooth printer connection status" , type: AppException.PRINTER_EXCEPTION));
    }
  }

  @override
  Future<bool> print(dynamic data , HTPrinter selectedPrinter) async {
    try{
      var posCommand = await generatePosCommandToPrint(selectedPrinter, data);
      var printResult = await PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: posCommand);
      return printResult;
    }catch(ex){
      return Future.error(AppException(message: ex.toString() ?? "Unable to print data", type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Future<bool> disconnect(HTPrinter printer) async {
    try {
      var printerManager = PrinterManager.instance;
      var connectionStatus = await printerManager.disconnect(type: PrinterType.bluetooth);
      return connectionStatus;
    } catch (ex) {
      return Future.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }
}


// ------------------------------------- usb printer setup --------------------------------------------

class USBPRinter extends IPrintService{
  ISharedPrefRepository preferenceRepo;
  CustomPrinterConnectionStatus usbPrinterStatus = CustomPrinterConnectionStatus.NOT_CONNECTED;

  USBPRinter({this.preferenceRepo = const SharedPreferenceRepository()});

  @override
  Stream<HTPrinter> scanPrinter({String? ipAddress}) {
    try{
      return PrinterManager.instance.discovery(type: PrinterType.usb , isBle: false).map((deviceInfo){
        return HTPrinter(
          deviceName: deviceInfo.name,
          address: deviceInfo.address,
          vendorId: deviceInfo.vendorId,
          productId: deviceInfo.productId,
          typePrinter: HTPrinterType.USB.name,
        );
      });
    } catch (ex) {
      return Stream.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Future<bool> connect(HTPrinter printer, bool autoReconnect) async {
    try {
      var printerManager = PrinterManager.instance;
      var printerInfo = UsbPrinterInput(name: printer.deviceName,productId: printer.productId,vendorId: printer.vendorId);
      var connectionStatus = await printerManager.connect(type: PrinterType.usb, model: printerInfo);
      return connectionStatus;
    } catch (ex) {
      return Future.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Stream<Map<String, CustomPrinterConnectionStatus>> listenPrinterConnectinStatus() {
    try{
      return PrinterManager.instance.stateUSB.map((event){
        if(event == USBStatus.connecting){
          usbPrinterStatus =  CustomPrinterConnectionStatus.CONNECTING;
          return {"usbId" : usbPrinterStatus};
        }
        if(event == USBStatus.connected){
          usbPrinterStatus = CustomPrinterConnectionStatus.CONNECTED;
          return {"usbId" : usbPrinterStatus};
        }
        else{
          usbPrinterStatus = CustomPrinterConnectionStatus.NOT_CONNECTED;
          return {"usbId" : usbPrinterStatus};
        }
      });
    }catch(ex){
      return Stream.error(AppException(message: "unable to listen bluetooth printer connection status" , type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Future<bool> print(dynamic data, HTPrinter selectedPrinter) async {
    try{
      var posCommand = await generatePosCommandToPrint(selectedPrinter, data);
      var printResult = await PrinterManager.instance.send(type: PrinterType.usb, bytes: posCommand);
      return printResult;
    }catch(ex){
      return Future.error(AppException(message: ex.toString() ?? "Unable to print data", type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Future<bool> disconnect(HTPrinter printer) async {
    try {
      var printerManager = PrinterManager.instance;
      var connectionStatus = await printerManager.disconnect(type: PrinterType.usb);
      return connectionStatus;
    } catch (ex) {
      return Future.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }
}



// -------------------------------------------- Network printer setup -----------------------------------

class NetworkPrinter extends IPrintService{
  ISharedPrefRepository preferenceRepo;
  CustomPrinterConnectionStatus networkPrinterStatus = CustomPrinterConnectionStatus.NOT_CONNECTED;

  NetworkPrinter({this.preferenceRepo = const SharedPreferenceRepository()});
  Socket? socket;
   
  static Map<String,CustomPrinterConnectionStatus> connectedPrinters = {};
  static StreamController<Map<String,CustomPrinterConnectionStatus>> onlineNetworkPrinters = StreamController();

  @override
  Stream<HTPrinter> scanPrinter({String? ipAddress}) {
    try{
      return PrinterManager.instance.discovery(type: PrinterType.network , isBle: false , model: TcpPrinterInput(ipAddress: ipAddress!)).map((deviceInfo){
        return HTPrinter(
          deviceName: deviceInfo.name ?? deviceInfo.address,
          address: deviceInfo.address,
          vendorId: deviceInfo.vendorId,
          productId: deviceInfo.productId,
          typePrinter: HTPrinterType.NETWORK.name,
        );
      });
    } catch (ex) {
      log("printer scan exception ${ex.toString()}");
      return Stream.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Future<bool> connect(HTPrinter printer, bool autoReconnect) async {
    try {
      
      var printerManager = PrinterManager.instance;
      var printerInfo = TcpPrinterInput(ipAddress: printer.address! , port: printer.port != null ? int.parse(printer.port!) : 9100,);
      var connectionStatus =  await printerManager.tcpPrinterConnector.connectAndKeep(printerInfo);
      if(connectionStatus){
        socket = await Socket.connect(printer.address, printer.port != null ?int.parse(printer.port!) : 9100,);
        socket?.listen((dynamic message) {},
        onDone: () {
          socket?.destroy();
          connectedPrinters.removeWhere((key, value) => printer.deviceName == key);
          onlineNetworkPrinters.add(connectedPrinters);
        },
        onError: (error)  {
          socket?.destroy();
        });
        connectedPrinters.addIf(true,printer.deviceName!,   CustomPrinterConnectionStatus.CONNECTED);
        onlineNetworkPrinters?.add(connectedPrinters);
      }
      return connectionStatus;
    } catch (ex) {
      log('network printer exception ${ex.toString()}');
      return Future.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
    
  }
  
  @override
  Stream<Map<String, CustomPrinterConnectionStatus>> listenPrinterConnectinStatus() {
    try{
      return onlineNetworkPrinters.stream;
    }catch(ex){
      return Stream.error(AppException(message: "unable to listen bluetooth printer connection status" , type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Future<bool> print(dynamic data , HTPrinter selectedPrinter) async {
    try{ 
      var posCommand = await generatePosCommandToPrint(selectedPrinter, data);
      var printResult = await PrinterManager.instance.send(type: PrinterType.network, bytes: posCommand, );
      return printResult;
    }catch(ex){
      log("Network print exception ${ex.toString()}");
      return Future.error(AppException(message: "Unable to print data", type: AppException.PRINTER_EXCEPTION));
    }
  }
  
  @override
  Future<bool> disconnect(HTPrinter printer) async {
    try {
      connectedPrinters.removeWhere((key, value) => printer.deviceName == key);
      onlineNetworkPrinters.add(connectedPrinters);
      var printerManager = PrinterManager.instance;
      var connectionStatus = await printerManager.disconnect(type: PrinterType.network);
      return connectionStatus;
    } catch (ex) {
      return Future.error(AppException(message: ex.toString(), type: AppException.PRINTER_EXCEPTION));
    }
  }
}
