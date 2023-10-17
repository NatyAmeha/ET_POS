import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/features/payment/payment_repository.dart';
import 'package:hozmacore/features/order/repo/product_repoisitory.dart';
import 'package:hozmacore/features/invoice/services/pdf_service.dart';
import 'package:hozmacore/features/invoice/services/print_service.dart';
import 'package:hozmacore/features/invoice/printer_usecase.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:hozmacore/shared_models/Response.dart' as AppResponse;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PrinterController extends GetxController {
  var appController = Get.find<AppController>();
  var isLoading = false.obs;  // track loading widget for async operation

  var printintInfo = AppResponse.Response<PrintingInfo>.loading(null).obs;

  bool isInConnectedPrinter(HTPrinter printer){
    var index = appController.connectedPrinters.indexWhere((element) => element.deviceName == printer.deviceName);
    return index > -1;
  }

  getPrintingInfo() async{
    final info = await Printing.info();
    printintInfo.value = AppResponse.Response.completed(info);
  }

  Future<List<StreamSubscription<HTPrinter>>?> scanAllPrinterDevices(BuildContext context) async {
    try {
      isLoading(true);
      var streamSubscriptionController = <StreamSubscription<HTPrinter>>[];
      var usbPrinterUsecase = PrinterUsecase(printerService: USBPRinter());
      var bluetoothPrinterUsecase = PrinterUsecase(printerService: BluetoothPrinter());
      var networkPrinterUsecase = PrinterUsecase(printerService: NetworkPrinter());
      var usbSubscription = await usbPrinterUsecase.scanPrinter().listen((newPrinterInfo) { 
        appController.addPrinterToScannedPrinters(newPrinterInfo);
      });
      streamSubscriptionController.add(usbSubscription);
      var bluetoothSubscription = await bluetoothPrinterUsecase.scanPrinter().listen((newPrinterInfo) { 
        appController.addPrinterToScannedPrinters(newPrinterInfo);
      });
      streamSubscriptionController.add(bluetoothSubscription);
      // find ip address of the network and scan printers on that network
      await Future.forEach(appController.connectedNetworkIpAddresses, (ip) async {
        var networkSubscription = await networkPrinterUsecase.scanPrinter(ipAddress: ip).listen((newPrinterInfo) { 
        appController.addPrinterToScannedPrinters(newPrinterInfo);
      });
      streamSubscriptionController.add(networkSubscription);
      });
      return streamSubscriptionController;
     
    } catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_scan_printer);
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<void> scanNetworkPrinter(BuildContext context ,  String ipAddress) async {
    var newPrinters = <HTPrinter>[];
    try {
      isLoading(true);
      var networkPrinterUsecase = PrinterUsecase(printerService: NetworkPrinter());
      var networkSubscription = await networkPrinterUsecase.scanPrinter(ipAddress: ipAddress).listen((newPrinterInfo) { 
        newPrinters.add(newPrinterInfo);
      }).asFuture();
      
      if(newPrinters.isNotEmpty){
        newPrinters.forEach((printer) { 
          appController.addPrinterToScannedPrinters(printer);
        });
        Helper.showSnackbar(context, "${newPrinters.length} ${AppLocalizations.of(context)!.new_printer_found}");
      } else {
        Helper.showSnackbar(context, AppLocalizations.of(context)!.no_new_printer , color: Colors.redAccent, prefixIcon: Icons.hourglass_empty);
      }
      networkSubscription?.cancel();
      
    } catch (e) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_scan_network_printer,  color: Colors.redAccent , prefixIcon: Icons.error_outline);
    }
    finally{
      isLoading(false);
    }
  }

  Future<StreamSubscription<Map<String, CustomPrinterConnectionStatus>>?> listenPrinterconnectinStatus(BuildContext context ,  HTPrinterType printerType) async {
    try{
      IPrintService? printerServce;
      if(printerType == HTPrinterType.BLUTOOTH){
        printerServce = BluetoothPrinter();
      }
      else if(printerType == HTPrinterType.USB){
        printerServce = USBPRinter();
      }
      else if(printerType == HTPrinterType.NETWORK){
        printerServce = NetworkPrinter();
      }
      if(printerServce != null){
        var printerUsecase = PrinterUsecase(printerService: printerServce);
         var subscription = await printerUsecase.listConnectionStatus().listen((printerStatusesWithId)  async { 
          appController.listenPrinterStatusAndUpdateConnectedPrintersList(printerType.name, printerStatusesWithId);
         });
         return subscription;
      }
      return null;
    }catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_scan_printer);
    }
  }

  

  Future<void> printOrderReceipt(BuildContext context, Order order, Customer? customer) async {
    try {
      isLoading(true);
      if (appController.connectedPrinters.isNotEmpty) {
        var dbRepo = DBRepository(DbName: appController.dbName!);
        var paymentRepo = PaymentRepository(dbRepository: dbRepo);
        var productRepo = ProductRepository(dbRepository: dbRepo);
        var pdfService = PdfService(paymentRepo: paymentRepo , productRepo: productRepo);
        await Future.forEach(appController.connectedPrinters, (printer) async {
          IPrintService? printerServce;
          if (printer.typePrinter == HTPrinterType.BLUTOOTH.name) {
            printerServce = BluetoothPrinter();
          } else if (printer.typePrinter == HTPrinterType.USB.name) {
            printerServce = USBPRinter();
          } else if (printer.typePrinter == HTPrinterType.NETWORK.name) {
            printerServce = NetworkPrinter();
          }
          if (printerServce != null) {
            var printerUsecase = PrinterUsecase(printerService: printerServce, pdfService: pdfService);
            // select paper/ pdf page format based on printer paper size configuration
            PdfPageFormat selectedPageFormat;
            if (printer.paperSize == PrintPaperSize.MM80.name) {
              selectedPageFormat = PdfPageFormat.roll80;
            } else {
              selectedPageFormat = PdfPageFormat.roll57;
            }
            var orderReceiptPdf = await printerUsecase.generateInvoicePdf(selectedPageFormat, order, customer, appController.allProducts, appController.taxes, appController.companResponse, appController.selectedPosConfig);
            var orderReceiptImage = await pdfService.convertPdfToImages(orderReceiptPdf, 125);
            // selecting image of the first page of the pdf since the pdf package support multiple page
            if (orderReceiptImage.firstOrNull != null) {
              var result =
                  await printerUsecase.print(printer, orderReceiptImage.first);
            }
          }
        });
      } else {
        Helper.showSnackbar(context, AppLocalizations.of(context)!.connect_to_printer_first);
      }
    } on AppException catch (ex) {
      print("order receipt print exception ${ex.message}");
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_print_order_receipt);
    } finally {
      isLoading(false);
    }
  }

  Future<void> printTestReceipt(BuildContext context, HTPrinter printer) async {
    try {
      // isLoading(true);
      var printersName = appController.connectedPrinters.map((prntr) => prntr.deviceName);
      if (printersName.contains(printer.deviceName)) {
        var pdfService = PdfService();
        IPrintService? printerServce;
        if (printer.typePrinter == HTPrinterType.BLUTOOTH.name) {
          printerServce = BluetoothPrinter();
        } else if (printer.typePrinter == HTPrinterType.USB.name) {
          printerServce = USBPRinter();
        } else if (printer.typePrinter == HTPrinterType.NETWORK.name) {
          printerServce = NetworkPrinter();
        }
        if (printerServce != null) {
          var printerUsecase = PrinterUsecase(printerService: printerServce);
          // select paper/ pdf page format based on printer paper size configuration
          PdfPageFormat selectedPageFormat;
          if (printer.paperSize == PrintPaperSize.MM80.name) {
            selectedPageFormat = PdfPageFormat.roll80;
          } else {
            selectedPageFormat = PdfPageFormat.roll57;
          }
          var testReceiptPdf =
          await pdfService.buildTestReceipt(selectedPageFormat);
          var testReceiptImage =
            await pdfService.convertPdfToImages(testReceiptPdf, 125);
          // selecting image of the first page of the pdf since the pdf package support multiple page
          if (testReceiptImage.firstOrNull != null) {
            var result = await printerUsecase.print(printer, testReceiptImage.first);
          }
        }
      } else {
        Helper.showSnackbar(context, AppLocalizations.of(context)!.connect_to_printer_first);
      }
    } on AppException catch (ex) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_print_test_receipt);
    } finally {
      isLoading(false);
    }
  }

  Future<bool> connectPrinter(BuildContext context, HTPrinter selectedPrinter) async {
    try{
      isLoading(true);
      IPrintService? printerServce;
      if(selectedPrinter.typePrinter == HTPrinterType.BLUTOOTH.name){
        printerServce = BluetoothPrinter();
      }
      else if(selectedPrinter.typePrinter == HTPrinterType.USB.name){
        printerServce = USBPRinter();
      }
      else if(selectedPrinter.typePrinter == HTPrinterType.NETWORK.name){
        printerServce = NetworkPrinter();
      }
      if(printerServce != null) {
        var printerUsecase = PrinterUsecase(printerService: printerServce);
        var isConnected = await printerUsecase.connectPrinter(selectedPrinter, true);
        if(isConnected){
          appController.addPrinterToConnectedPrinters(selectedPrinter);
          return isConnected;
        } else {
          Helper.showSnackbar(context, AppLocalizations.of(context)!.printer_is_offline, color: Colors.redAccent);
          return false;
        }
      }
      else {
        Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_connect_to_selected_printer , color: Colors.redAccent , prefixIcon: Icons.error_outline);
        return false;
      }
    } on AppException catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_connect_to_selected_printer , color: Colors.redAccent , prefixIcon: Icons.error_outline);
      return false;
    } finally {
      isLoading(false);
    }
  }

  Future<void> addPrinterToPairedPrinterList(BuildContext context ,  HTPrinter printer) async {
    try {
      isLoading(true);
      var printerUsecase = PrinterUsecase();
      var saveResult = await printerUsecase.saveNewPairedPrintersToPreference(printer);
      if(saveResult){
        appController.addPrinterToPairedPrinter(printer);
      }
      
    } catch (ex) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_add_to_paired_printers , color: Colors.redAccent , prefixIcon: Icons.error_outline);
    } finally{
      isLoading(false);
    }
  }

  Future<void> connectToPairedPrinters() async {
    try {
      var printerUsecase = PrinterUsecase();
      var pairedPrintersResult = await printerUsecase.getPairedPrintersFromPreference();
      if(pairedPrintersResult.isNotEmpty){
        appController.setPairedPrinters(pairedPrintersResult);
        await Future.forEach(appController.pairedPrinters, (printer) async{
          IPrintService? printerServce;
          if(printer.typePrinter == HTPrinterType.BLUTOOTH.name){
            printerServce = BluetoothPrinter();
          }
          else if(printer.typePrinter == HTPrinterType.USB.name){
            printerServce = USBPRinter();
          }
          else if(printer.typePrinter == HTPrinterType.NETWORK.name){
            printerServce = NetworkPrinter();
          }
          if(printerServce != null){
            printerUsecase.printerService = printerServce;
            try{
              var isConnected = await printerUsecase.connectPrinter(printer, false);
              if(isConnected){
                appController.addPrinterToConnectedPrinters(printer);
              }
            } on AppException catch(ex){
              appController.removePrinterFromConnectedPrinters(printer);
            }
          }
        });
      }
    } on AppException catch (ex) {
      print("paired printer connection exception ${ex.message}"); 
    }
  }

  Future<void> disconnectPrinter(BuildContext context , HTPrinter printer) async {
    try{
      isLoading(true);
      IPrintService? printerServce;
      if(printer.typePrinter == HTPrinterType.BLUTOOTH.name){
        printerServce = BluetoothPrinter();
      }
      else if(printer.typePrinter == HTPrinterType.USB.name){
        printerServce = USBPRinter();
      }
      else if(printer.typePrinter == HTPrinterType.NETWORK.name){
        printerServce = NetworkPrinter();
      }
      if(printerServce != null){
        var printerUsecase = PrinterUsecase(printerService: printerServce);
        var result = await printerUsecase.disconnectPrinter(printer);
        appController.removePrinterFromConnectedPrinters(printer);
      }
    } catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_connect_to_selected_printer);
    } finally {
      isLoading(false);
    }
  }

  Future<void> removePrinterFromPairedDevice(BuildContext context , HTPrinter printer) async {
    try{
      isLoading(true);
      IPrintService? printerServce;
      if(printer.typePrinter == HTPrinterType.BLUTOOTH.name){
        printerServce = BluetoothPrinter();
      }
      else if(printer.typePrinter == HTPrinterType.USB.name){
        printerServce = USBPRinter();
      }
      else if(printer.typePrinter == HTPrinterType.NETWORK.name){
        printerServce = NetworkPrinter();
      }
      if(printerServce != null) {
        var printerUsecase = PrinterUsecase(printerService: printerServce);
        // disconnect if there is any other printer
        if (appController.connectedPrinters.isNotEmpty && isInConnectedPrinter(printer)) {
          await printerUsecase.disconnectPrinter(printer);
          appController.removePrinterFromConnectedPrinters(printer);
        }
        // remove printer info from paired devices list in preference
        var removeResult = await printerUsecase.removePairedPrinterFromPreference(printer);
        if(removeResult){
          appController.removePrinterFromPairedPrinters(printer);
        }
      }
    } catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_remove_from_paired_printers);
    } finally {
      isLoading(false);
    }
  }

  

  Future<Uint8List> buildInvoicePdf(BuildContext context ,  PdfPageFormat pageFormat , Order order , Customer? customer) async {
    try{
      isLoading(true);
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var paymentRepo = PaymentRepository(dbRepository: dbRepo);
      var productRepo = ProductRepository(dbRepository: dbRepo);
      var printerUsecase = PrinterUsecase(pdfService: PdfService( paymentRepo: paymentRepo, productRepo: productRepo));
      var result = await printerUsecase.generateInvoicePdf(pageFormat, order, customer, appController.allProducts, appController.taxes, appController.companResponse, appController.selectedPosConfig);
      return result;
    }catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_generate_invoice_pdf);
      return Future.error("");
    } finally {
      isLoading(false);
    }
  }
}
