import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/datasource/api/custom_api_client.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/company/model/company.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/features/order/repo/product_repoisitory.dart';
import 'package:hozmacore/features/invoice/services/pdf_service.dart';
import 'package:hozmacore/features/customer/customer_usecase.dart';
import 'package:hozmacore/features/order/usecase/product_usecase.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/AppConfiguration.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';

import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/shop/shop_repository.dart';
import 'package:hozmacore/shared_services/connectivity_service.dart';
import 'package:hozmacore/features/invoice/services/print_service.dart';
import 'package:hozmacore/features/invoice/printer_usecase.dart';
import 'package:hozmacore/features/shop/shop_usecase.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/shared_models/Response.dart' as AppResponse;
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:odoo_pos/ui/screens/account/login_screen.dart';
import 'package:odoo_pos/ui/screens/shop_selection_screen.dart';
import 'package:pdf/pdf.dart';

import 'package:hozmacore/features/customer/services/multi_window_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppController extends GetxController {
  // app level api client configured once
  APIEndPoint? apiClient;
  var isSplashApiCalled = false;

  // initialized when shop is selected
  String? dbName;

  // info fetched from splash api response
  var _splashInfo = AppResponse.Response<SplashResponse>.loading(null).obs;
  SplashResponse? get splashResponse => _splashInfo.value.data;
  AppResponse.Status get splashResponseStatus => _splashInfo.value.status;
  String get splashResponseErrorMessage => _splashInfo.value.message ?? "";
  setSplashScreenToLoadingState() {
    _splashInfo.value = AppResponse.Response.loading(null);
  }

  POSConfig? selectedPosConfig;
  String get currencyPosition => selectedPosConfig?.currency.firstOrNull?.position ?? Configuration.DEFAULT_CURRENCY_POSITION;
  String get currencySymbol => selectedPosConfig?.currency.firstOrNull?.symbol ?? Configuration.DEFAULT_CURRENCY_SYMBOL;
  
  CashOpen? posOpeningInfo;

  List<Product>? allProducts = [];

  List<Tax>? taxes;

  Company? companResponse;

  var _scannedPrinters = <HTPrinter>[].obs;
  var _pairedPrinters = <HTPrinter>[].obs;
  var _connectedPrinters = <HTPrinter>[].obs;
  List<HTPrinter> get scannedPrinters {
    var pairedPrintersDeviceNames = _pairedPrinters.map((e) => e.deviceName).toList();
    return _scannedPrinters.where((p) => !pairedPrintersDeviceNames.contains(p.deviceName)).toList();
  }
  List<HTPrinter> get pairedPrinters => _pairedPrinters.value;
  List<HTPrinter> get connectedPrinters => _connectedPrinters.toSet().toList();
  

  addPrinterToScannedPrinters(HTPrinter printer){
    var index = _scannedPrinters.indexWhere((printerElement) => printerElement.deviceName == printer.deviceName);
    // add the new printer if not present in _scannedPrinters
    if(index ==  -1){
      _scannedPrinters.add(printer);
    }
  }

  addPrinterToConnectedPrinters(HTPrinter printer){
    _connectedPrinters.add(printer);
  }

  removePrinterFromConnectedPrinters(HTPrinter printer){
    _connectedPrinters.removeWhere((element) => element.deviceName == printer.deviceName);
  }
  // listen printers status and update connected printers list
  listenPrinterStatusAndUpdateConnectedPrintersList(String printerType , Map<String, CustomPrinterConnectionStatus> onlinePrinters){
    var printersByType = _connectedPrinters.where((printer) => printer.typePrinter == printerType);
    if(onlinePrinters.isNotEmpty){
      // remove offline printers of this type
      var onlinePrintersByPrinterType = printersByType.where((printer) => !onlinePrinters.keys.contains(printer.deviceName)).toList();
      _connectedPrinters.removeWhere((element) => onlinePrintersByPrinterType.contains(element),);
    }
    else{
      // no online printers found by this printer type, so remove all previously connected printer of this type
      _connectedPrinters.removeWhere((element) => printersByType.map((e) => e.deviceName).contains(element.deviceName));
    }
  }

  setPairedPrinters(List<HTPrinter> printers){
    _pairedPrinters.value = printers;
  }

  addPrinterToPairedPrinter(HTPrinter printer){
    _pairedPrinters.add(printer);
  }
  
  removePrinterFromPairedPrinters(HTPrinter printer){
    _pairedPrinters.removeWhere((pr) => pr.deviceName == printer.deviceName);
  }


  List<int>? pendingTask;
  var isPrinterConnected = false.obs;

  var connectedNetworkIpAddresses = [];

  var selectedProductInCartIndex = 0.obs;
  onSelectedProductIndexchangedInCart(Function action){
    ever(selectedProductInCartIndex, (callback){
      action();
    });
  }

  
  var customerDisplayWindowId = Rxn<int>();

  // to control closing customer display screen only from the sidebar
  var canCloseCustomerWindowFromMainWindow = false;
    
  

  @override
  void onInit() async {
    apiClient = await CustomApiClient.getClient();
    // find ip address of connected wifi and netowrk
    var ipAddresses = await  ConnectivityService().getIPAddressOfConnectedNetwork();
    if(ipAddresses != null){
      connectedNetworkIpAddresses.add(ipAddresses);
    }
    connectToPairedPrinters();
    super.onInit();
  }

  @override
  onReady(){
    super.onReady();
  }

  
  getSplashInfo(BuildContext context) async {
    try{
      setSplashScreenToLoadingState();
      var isLoggedIn = await Helper.getDataFromPreference<bool>(SharedPreferenceRepository.D_IS_LOGGED) ?? false;
      if(isLoggedIn == true){
        var shopUsecase = ShopUsecase(shopRepo: ShopRepository(apiClient: apiClient));
        var splashInfoResult = await shopUsecase.getSplashInfoAndInitialize();
        isSplashApiCalled = true;
        if(splashInfoResult.success == true){
          _splashInfo.value = AppResponse.Response.completed(splashInfoResult);
        } else{
          _splashInfo.value = AppResponse.Response.error(splashInfoResult.message);
        } 
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>  ShopSelectionScreen()));
      }
      else{
        Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>  LoginScreen()));
      }
    } on AppException catch(ex){
      _splashInfo.value = AppResponse.Response.error(AppLocalizations.of(context)!.internet_connection_error);
    }
  }

  String getPriceStringWithConfiguration(double price){
     return currencyPosition == "before"
                    ? "$currencySymbol ${price.toStringAsFixed(2)}"
                    : "${price.toStringAsFixed(2)} $currencySymbol";

  }


  StreamSubscription<dynamic> getNetworkStatus(BuildContext context){
    var helper = Helper(connectivityService: ConnectivityService());
    var subscription = helper.getNetworkConnectivity().listen((String status) { 

      if (status == ConnectivityService.ONLINE) {
        Helper.showSnackbar(context, ConnectivityService.ONLINE);
      } else {
        Helper.showSnackbar(context, ConnectivityService.OFFLINE , color: Colors.redAccent);
      }
    });
    return subscription;
  } 

  Future<void> getTaxInfo() async {
    try {
      var dbRepo = DBRepository(DbName: dbName!);
      var productUsecase = ProductUsecase(productRepo: ProductRepository(apiClient: apiClient , dbRepository: dbRepo));
      // get tax info from db or api and save to app controller to easly access tax info on app level
      var taxInfoResult = await productUsecase.getTaxes();
      taxes = taxInfoResult;
    } catch (ex) {
      print("Unable to fetch tax info from db or api");
    }
  }


  Future<int?> openCustomerDisplayWindow(BuildContext context ,  List<Product> products, double totalAmount, double taxAmount, String? currencySymbol, String? currencyPosition) async {
    try {
      var customerDisplayInfo = jsonEncode({
        'products': products,
        'totalAmount': totalAmount,
        'totalVATAmount': taxAmount,
        'currencyPosition': currencyPosition,
        'currencySymbol' : currencySymbol
      });
      var customerUsecase = CustomerUsecase(windowService: WindowService());
      var windowId = await customerUsecase.openCustomerDisplayScreen(customerDisplayInfo);
      customerDisplayWindowId.value = windowId;
      return windowId;
    } on AppException catch (ex) {
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.unable_to_open_customer_display);
      return null;
    }
  }

  Future<bool> closeCustomerDisplayWindow(BuildContext context ,  int windowId) async {
    try {
      
      await WindowService().closeWindow(windowId);
      customerDisplayWindowId.value = null;
      Helper.showSnackbar(context, AppLocalizations.of(context)!.customer_display_opened_successfully);
      return true;
    } catch (ex) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.uanble_to_close_customer_display);
      return false;
    }
  }

  Future<void> connectToPairedPrinters() async {
    try {
      var printerUsecase = PrinterUsecase();
      var pairedPrintersResult = await printerUsecase.getPairedPrintersFromPreference();
      if(pairedPrintersResult.isNotEmpty){
        _pairedPrinters.value = pairedPrintersResult;
        await Future.forEach(_pairedPrinters, (printer) async{
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
                _connectedPrinters.add(printer);
              }
            } on AppException catch(ex){
              //remove from connected printers 
              // _connectedPrinters.removeWhere((element) => element.deviceName == printer.deviceName);
            }
          }
        });
      }
    } on AppException catch (ex) {
      print("paired printer connection exception ${ex.message}"); 
    }
  }

  
  Future<Uint8List?> convertPdfToImage(Uint8List pdfData , double height) async{
    try{
      var pdfService = PdfService();
      var convertedToImagePdfPages = await pdfService.convertPdfToImages(pdfData, height);
      if(convertedToImagePdfPages.firstOrNull != null){
        return convertedToImagePdfPages.first;
      }
      return null;
    }catch(ex){
      print("unable to convert pdf to image");
      return null;
    }
  } 

  Future<Uint8List?> generateTestReceiptImage( PdfPageFormat pdfPageFormat) async {
    var testREceiptPdf = await PdfService().buildTestReceipt(pdfPageFormat);
    var imageResult = await convertPdfToImage(testREceiptPdf, 125);
    return imageResult;
    
  }
}
