import 'dart:convert';
import 'dart:typed_data';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/company/model/company.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:hozmacore/features/invoice/services/pdf_service.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/invoice/services/print_service.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:pdf/pdf.dart';

class PrinterUsecase{
  ISharedPrefRepository sharedPrefRepo;
  IPrintService? printerService;
  IPdfservice? pdfService;

  PrinterUsecase({
    this.pdfService, 
    this.printerService, 
    this.sharedPrefRepo = const SharedPreferenceRepository()});

  Future<HTPrinterType?> getPrinterType() async {
    var savedPrinterInfo = await getPrinterInfoFromPreference();
    if(savedPrinterInfo.typePrinter == null){
      return null;
    }
    switch (savedPrinterInfo.typePrinter!) {
      case "NETWORK":
        return HTPrinterType.NETWORK;
      case "USB":
        return HTPrinterType.USB;
      case "BLUTOOTH":
        return HTPrinterType.BLUTOOTH;
      default:
        return null;
    }
  }

  Stream<HTPrinter> scanPrinter({String? ipAddress})  {
    return printerService!.scanPrinter(ipAddress: ipAddress);
  }

  Stream<Map<String, CustomPrinterConnectionStatus>> listConnectionStatus()  {
    return printerService!.listenPrinterConnectinStatus();
  }


  Future<bool> connectPrinter(HTPrinter selectedPrinter , bool autoReconnect) async {
    var printerConnectResult = await printerService!.connect(selectedPrinter, autoReconnect);
    return printerConnectResult;
  }

  Future<bool> disconnectPrinter(HTPrinter printer) async {
    var result = await printerService!.disconnect(printer);
    return result;
  }

  Future<bool> print(HTPrinter selectedPrinter, List<int> data) async {
    var result = await printerService!.print(data, selectedPrinter);
    return result;
  }


  Future<HTPrinter> getPrinterInfoFromPreference() async {
    String? deviceName = await sharedPrefRepo.get<String>("${SharedPreferenceRepository.PRINTER_REFERENCE}deviceName");
    String? address =  await sharedPrefRepo.get<String>("${SharedPreferenceRepository.PRINTER_REFERENCE}address");
    String? port = await sharedPrefRepo.get<String>("${SharedPreferenceRepository.PRINTER_REFERENCE}port");
    String? vendorId = await sharedPrefRepo.get<String>("${SharedPreferenceRepository.PRINTER_REFERENCE}vendorId");
    String? productId = await sharedPrefRepo.get<String>("${SharedPreferenceRepository.PRINTER_REFERENCE}productId");
    int? printerId = await sharedPrefRepo.get<int>("${SharedPreferenceRepository.PRINTER_REFERENCE}id");
    bool? isBle = await sharedPrefRepo.get<bool>("${SharedPreferenceRepository.PRINTER_REFERENCE}isBle");
    bool? state = await sharedPrefRepo.get<bool>("${SharedPreferenceRepository.PRINTER_REFERENCE}state");
    String? printerType  = await sharedPrefRepo.get<String>("${SharedPreferenceRepository.PRINTER_REFERENCE}typePrinter");

    return HTPrinter(
        address: address,
        deviceName: deviceName,
        port: port,
        productId: productId,
        state: state,
        typePrinter: printerType,
        vendorId: vendorId);
  }

  Future<List<HTPrinter>> getPairedPrintersFromPreference() async {
    var encodedPrintersResults = await sharedPrefRepo.getAll<String>(SharedPreferenceRepository.PAIRED_PRINTERS);
    var pairedPrinters = encodedPrintersResults.map((e) => HTPrinter.fromJson(json.decode(e))).toList();
    return pairedPrinters;
  }

  Future<bool> saveNewPairedPrintersToPreference(HTPrinter printer) async {
     var previouslyPairedPrinters = await getPairedPrintersFromPreference();
     var printerNames = previouslyPairedPrinters.map((e) => e.deviceName);
     if(!printerNames.contains(printer.deviceName)){
      previouslyPairedPrinters.add(printer);
      var encodedPrintersInfo = previouslyPairedPrinters.map((e) => json.encode(e.toJson())).toList();
      var result = await sharedPrefRepo.create<bool,  List<String>>(SharedPreferenceRepository.PAIRED_PRINTERS, encodedPrintersInfo);
      return result;
     }
     return false;
  }

  Future<bool> removePairedPrinterFromPreference(HTPrinter printer) async{
     var previouslyPairedPrinters = await getPairedPrintersFromPreference();
     var printerNames = previouslyPairedPrinters.map((e) => e.deviceName);
     if(printerNames.contains(printer.deviceName)){
      previouslyPairedPrinters.removeWhere((pr) => pr.deviceName == printer.deviceName);      
      var encodedPrintersInfo = previouslyPairedPrinters.map((e) => json.encode(e.toJson())).toList();
      var result = await sharedPrefRepo.create<bool,  List<String>>(SharedPreferenceRepository.PAIRED_PRINTERS, encodedPrintersInfo);
      return result;
     }
     return false;
  }

  savePrinterInfoToPreference(HTPrinter printer) async {
    if (printer.id != null) {
      await sharedPrefRepo.create<bool , int>("${SharedPreferenceRepository.PRINTER_REFERENCE}id", printer.id!);
    }
    if (printer.deviceName != null) {
      await sharedPrefRepo.create<bool , String>("${SharedPreferenceRepository.PRINTER_REFERENCE}deviceName", printer.deviceName!);
    }
    if (printer.address != null) {
      await sharedPrefRepo.create<bool , String>("${SharedPreferenceRepository.PRINTER_REFERENCE}address", printer.address!);
    }

    if (printer.port != null) {
      await sharedPrefRepo.create<bool , String>("${SharedPreferenceRepository.PRINTER_REFERENCE}port", printer.port!);
    }

    if (printer.vendorId != null) {
      await sharedPrefRepo.create<bool , String>("${SharedPreferenceRepository.PRINTER_REFERENCE}vendorId", printer.vendorId!);      
    }

    if (printer.productId != null) {
      await sharedPrefRepo.create<bool , String>("${SharedPreferenceRepository.PRINTER_REFERENCE}productId", printer.productId!);
    }
    if (printer.state != null) {
      await sharedPrefRepo.create<bool , bool>("${SharedPreferenceRepository.PRINTER_REFERENCE}state", printer.state!);
    }
    await sharedPrefRepo.create<bool , String>("${SharedPreferenceRepository.PRINTER_REFERENCE}typePrinter", printer.typePrinter!);
  }

  Future<Uint8List> generateInvoicePdf(PdfPageFormat pageFormat, Order order , Customer? customer,  List<Product>? products, List<Tax>? taxes, Company? companyInfo , POSConfig? posConfig) async {
     var result = await pdfService!.buildInvoicePdf(pageFormat, order, customer, products, taxes, companyInfo, posConfig);
     return result;
  }
}