import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/controller/printer_controller.dart';
import 'package:odoo_pos/ui/screens/printer/small_screen_printer_setup_screen.dart';
import 'package:odoo_pos/ui/widgets/printer/network_printer_scanner_dialog.dart';
import 'package:odoo_pos/ui/widgets/printer/printer_setup_navigator.dart';
import 'package:odoo_pos/ui/widgets/printer_list_tile.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/invoice/services/pdf_service.dart';
import 'package:hozmacore/constants/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class PrinterListScreen extends StatefulWidget {
  Function? onBackBtnClicked;
  PrinterListScreen({Key? key , this.onBackBtnClicked}) : super(key: key);

  @override
  State<PrinterListScreen> createState() => _PrinterListScreenState();
}

class _PrinterListScreenState extends State<PrinterListScreen> {
  var appController = Get.find<AppController>();
  var printerController = Get.put(PrinterController());

  var printerManager = PrinterManager.instance;
  List<StreamSubscription<HTPrinter>>? printerScanScanSubscriptions;
  StreamSubscription<CustomPrinterConnectionStatus>? printerStatusSubscription;
  List<int>? pendingTask;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      printerScanScanSubscriptions = await printerController.scanAllPrinterDevices(context);
    });
  }

  @override
  void dispose() {
    if (printerScanScanSubscriptions?.isNotEmpty == true) {
      Future.forEach(printerScanScanSubscriptions!, (element) async {
        element.cancel();
      });
    }
    printerStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: !Helper.isTablet(context)
            ? AppBar(
                title: Text(AppLocalizations.of(context)!.printer_setup),
                leading: IconButton(
                  onPressed: () {
                    widget.onBackBtnClicked?.call();
                  },
                  icon: Icon(Icons.arrow_back_ios),
                ),
              )
            : null,
        body: Obx((){
      return Helper.displayContent(
        canShow: true, 
        errorMessage: appController.splashResponseErrorMessage,
        isLoading: printerController.isLoading.value,
        context: context,
        content: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: Helper.isTablet(context) ? 50 : 20),
            child: Column(
              children: [
                if (Helper.isTablet(context)) ...[
                  const SizedBox(height: 24),
                  buildCustomAppbarForLargeScreen(),
                ],
                const SizedBox(height: 40), 

                Obx(() {
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 75),
                      child: buildScannedPrinterList(Constant.PAIRED_DEVICES,
                          appController.pairedPrinters));
                }),

                Obx(() => buildScannedPrinterList(
                    Constant.AVAILABLE_DEVICES, appController.scannedPrinters)),
              ],
            )), 
      );
    })
  );
  }

  Widget buildCustomAppbarForLargeScreen() {
    return Row(
      children: [
        IconButton(
            onPressed: () {
              widget.onBackBtnClicked?.call();
            },
            icon: Icon(Icons.arrow_back_ios)),
        const SizedBox(width: 16),
        TextView(
          AppLocalizations.of(context)!.printer_setup,
          textStyle: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }

  Widget buildScannedPrinterList(String title, List<HTPrinter> printers) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: TextView(title, 
                textStyle: Theme.of(context).textTheme.titleLarge, maxline: 2),
          ),
              Spacer(),
          if(title == Constant.AVAILABLE_DEVICES)
            buildNetworkPrinterScannerAndConnectorDropDown()
        ],
      ),
      const SizedBox(height: 32),
      (printers.isEmpty)
          ? SizedBox(
              width: Helper.isTablet(context)
                  ? 400
                  : MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                      title == Constant.PAIRED_DEVICES
                          ? AppLocalizations.of(context)!.no_paired_device
                          : AppLocalizations.of(context)!.no_new_printer,
                      textStyle: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              itemCount: printers.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                  mainAxisExtent: 160),
              itemBuilder: (context, index) {
                return Obx(
                  () => PrinterListTile(
                      device: printers[index],
                      isPairedBefore:
                          title == Constant.PAIRED_DEVICES ? true : false,
                      isConnected: printerController.isInConnectedPrinter(printers[index]),
                      onActionSelected: (selectedAction) async {
                        if (selectedAction == PrinterAction.Connect.name) {
                          connectToPrinter(title, printers[index]);
                        } else if (selectedAction ==
                            PrinterAction.Disconnect.name) {
                          await printerController.disconnectPrinter(context , printers[index]);
                        } else if (selectedAction == PrinterAction.TestPrint.name) {
                          if(printerController.isInConnectedPrinter(printers[index])){
                             generateTestReceiptAndPrint(printers[index]);
                          }
                        } else if (selectedAction == PrinterAction.Info.name) {
                          showPrinterSetup(printers[index], PrinterAction.Info.name, onSetupCompleted:  (configuredPrinter) {});
                        } else if (selectedAction == PrinterAction.Remove.name) {
                          printerController.removePrinterFromPairedDevice(
                              context, printers[index]);
                        }
                      }),
                );
              },
            )
    ]);
  }

  Widget buildNetworkPrinterScannerAndConnectorDropDown(){
    return PopupMenuButton<NetworkPrinterAction>(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Icon(Icons.add), 
                  const SizedBox(width: 8) , 
                  TextView(AppLocalizations.of(context)!.add_new_printer, textStyle: Theme.of(context).textTheme.titleMedium)
                ],),
              ),
              onSelected: (action){
                 Helper.showModal(context,NetworkPrinterScannerDialog(action: action, onConfirm: (String ipAddress , String? port){
                  if(action == NetworkPrinterAction.SCAN){
                    printerController.scanNetworkPrinter(context, ipAddress);
                  }
                  else if(action == NetworkPrinterAction.CONNECT){
                    setUpNetworkPrinter(ipAddress, port!);
                  }
                 },));
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: NetworkPrinterAction.SCAN,
                    child: TextView(AppLocalizations.of(context)!.scan_network_printer,
                        textStyle: Theme.of(context).textTheme.titleMedium),
                  ),
                  PopupMenuItem(
                    value: NetworkPrinterAction.CONNECT,
                    child: TextView(AppLocalizations.of(context)!.connect_new_printer,
                        textStyle: Theme.of(context).textTheme.titleMedium),
                  )
                ];
              },
            );
  }

  showPrinterSetup(HTPrinter printer , String action, {Function(HTPrinter configuredPrinter)? onSetupCompleted}) {
    if(Helper.isTablet(context)){
      Helper.showModal(
      context,
      PrinterSetupNavigator(
        selectedPrinter: printer,
        action: action,
        onTestPrintClicked: (HTPrinter configuredPrinter) async {
          await printerController.printTestReceipt(context, configuredPrinter);
        },
        onConfirmClicked: (HTPrinter configuredPrinter) async {
          onSetupCompleted?.call(configuredPrinter);
        },
      ));
    }
    else{
      Navigator.of(context).push(
        MaterialPageRoute(builder: (c) =>SmallScreenPrinterSetupScreen(selectedPrinter: printer , action: action, 
          onTestPrintClicked: (configuredPrinter) {
            printerController.printTestReceipt(context, configuredPrinter);
          },
          onPrinterSetupCompleted: (updatedPrinter) {
            onSetupCompleted?.call(updatedPrinter);
          },
          
        )
      ),);
    }
    
  }

  void setUpNetworkPrinter(String ip, String port) async {
    var device = HTPrinter(
      deviceName: "$ip:$port",
      address: ip,
      port: port,
      typePrinter: HTPrinterType.NETWORK.name,
      state: false,
    );
    connectToPrinter("NETWORK_PRINTER", device);
  }

  Future<void> connectToPrinter(String title , HTPrinter printer) async {
    if(title == Constant.PAIRED_DEVICES){
       await printerController.connectPrinter(context, printer);
    } else{
      var connectResult = await printerController.connectPrinter(context, printer);
      if(connectResult){
        showPrinterSetup(
          printer, PrinterAction.Connect.name,
          onSetupCompleted : (configuredPrinter) {
            printerController.addPrinterToPairedPrinterList(context, printer);
          }
        );
      }
    }
  }

  Future<void> generateTestReceiptAndPrint(HTPrinter printer) async {
    var pdfData = await PdfService().buildTestReceipt(PdfPageFormat.roll57);
    var image = await appController.convertPdfToImage(pdfData, 125);
    Helper.showPreviewModal(context, 
      Helper.isTablet(context) ? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.9, 
      MediaQuery.of(context).size.height * 0.9, 
      pdfData: image , 
      showPrintReciptBtn: true, 
      onTestPrintCalled: () {
        printerController.printTestReceipt(context, printer);
      },
    );
  }
}
