import 'package:flutter/material.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/printer/printer_receipt_debug.dart';
import 'package:odoo_pos/ui/widgets/printer/printer_setup_confirmation.dart';
import 'package:odoo_pos/ui/widgets/printer/printer_setup_dialog.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:odoo_pos/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:pdf/pdf.dart';

class PrinterSetupNavigator extends StatefulWidget {
  HTPrinter selectedPrinter;
  String action;
  Future Function(HTPrinter configuredPrinter) onTestPrintClicked;
  Future Function(HTPrinter configuredPrinter)? onConfirmClicked;
  PrinterSetupNavigator({
    super.key,
    required this.selectedPrinter,
    required this.action,
    required this.onTestPrintClicked,
    this.onConfirmClicked,
  });

  @override
  State<PrinterSetupNavigator> createState() => _PrinterSetupNavigatorState();
}

class _PrinterSetupNavigatorState extends State<PrinterSetupNavigator> {
  String currentRouteName = HTPrinter.printerSetupRoute;
  var pdfPageFormat = PdfPageFormat.roll80;
  var currentStep = 0;
  var showdebugUi = false;
  var isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Helper.isTablet(context)
        ? Center(
            child: buildBody(context),
          )
        : buildBody(context);
  }

  Widget buildBody(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(Helper.isTablet(context) ? 16 : 0),
      child: CustomContainer(
        alignment: Alignment.topCenter,
        padding: Helper.isTablet(context) ? 8 : 0,
        width: Helper.isTablet(context)
            ? MediaQuery.of(context).size.width * 0.6
            : MediaQuery.of(context).size.width,
        height: Helper.isTablet(context)
            ? MediaQuery.of(context).size.height * 0.8
            : MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            showdebugUi 
              ? PrinterReceptDebug(onBackButton: (){
                setState(() {
                  currentStep = 0;
                  showdebugUi = false;
                });
              },)
              : Positioned.fill(
              top: 50,
              child: Column(
                children: [
                  if(currentStep < 1)...[
                    const SizedBox(height: 16),
                    TextView("${widget.selectedPrinter.deviceName}",textStyle: Theme.of(context).textTheme.displayMedium,),
                    const SizedBox(height: 16), 
                    TextView(
                      AppLocalizations.of(context)!.validate_printer_setting,
                      maxline: 2,
                      textAlignment: TextAlign.center,
                      textStyle: Theme.of(context).textTheme.bodyMedium
                    ),
                  ],
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Stepper(
                      type: StepperType.horizontal,
                      currentStep: currentStep,
                      elevation: 0,
                      controlsBuilder: (context, details) => SizedBox(),
                      onStepTapped: (value) {
                        if(value < currentStep){
                          setState(() {
                            currentStep = value;
                          });
                        }
                      }, 
                      steps: [
                        Step(
                          title: SizedBox(),
                          state: currentStep > 0 ? StepState.complete : StepState.indexed,
                          isActive: currentStep >= 0,
                          content: PrinterSetupDialog(selectedPrinter: widget.selectedPrinter,onPrinterSetupChanged: (HTPrinter updatedPrinter) {
                            syncPrinterInfowithchanges(updatedPrinter);
                          },
                          ),
                        ),
                        Step(
                          title: SizedBox(),
                          state: currentStep > 1 ? StepState.complete : StepState.indexed,
                            isActive: currentStep >= 1,
                          content: PrinterSetupConfirmation(configuredPrinter: widget.selectedPrinter,
                            title: AppLocalizations.of(context)!.submit_printing_receipt,
                            description: AppLocalizations.of(context)!.validate_printer_setting, 
                            addBorder: true, onPrinterSetupChanged: (HTPrinter updatedPrinter){
                              syncPrinterInfowithchanges(updatedPrinter);
                          }),
                        ),
                        Step(
                          title: SizedBox(),
                          state: currentStep > 2 ? StepState.complete : StepState.indexed,
                            isActive: currentStep >= 2,
                          content: PrinterSetupConfirmation(configuredPrinter: widget.selectedPrinter, 
                            title: AppLocalizations.of(context)!.receipt_match_with_preview,
                            description: AppLocalizations.of(context)!.validate_printer_setting, 
                          onPrinterSetupChanged: (HTPrinter updatedPrinter){
                                   syncPrinterInfowithchanges(updatedPrinter);
                          }),
                        ),
                       
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            if(isLoading)
              Positioned(child: Align(
                alignment: Alignment.center,
                child: DialogHelper.showProgressDialog(true),
              )),
            Positioned(
                top: 4,
                right: 8,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.close),
                    iconSize: 30)),
            if(!showdebugUi)
            Positioned.fill(
              bottom: 24,
              left: 24,
              right: 24,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentStep > 0) ...[
                      displayBackBtn(),
                      Spacer(),
                    ],
                    displayContinueBtn()
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  syncPrinterInfowithchanges(HTPrinter printer) {
    widget.selectedPrinter = printer;
    
    if (printer.paperSize == PrintPaperSize.MM57.name) {
      pdfPageFormat = PdfPageFormat.roll57;
    } else if (printer.paperSize == PrintPaperSize.MM80.name) {
      pdfPageFormat = PdfPageFormat.roll80;
    } else if (printer.paperSize == PrintPaperSize.A4.name) {
      pdfPageFormat = PdfPageFormat.a4;
    }
  }

  Widget displayContinueBtn(){
    var buttonText = AppLocalizations.of(context)!.continue_text;
    if(currentStep == 1){
      buttonText = AppLocalizations.of(context)!.print_preview;
    }
    else if(currentStep >= 2){
    buttonText = AppLocalizations.of(context)!.submit_print_preview;
    }
    return FilledButton(
      onPressed: () async {
        if(currentStep == 1)  {
          setState(() {
            isLoading = true;
          });
          await (widget.onTestPrintClicked(widget.selectedPrinter));
          setState(() {
            isLoading = false;
            currentStep += 1;
          });
        }
        else if(currentStep == 2){
          Navigator.of(context).pop();
          widget.onConfirmClicked?.call(widget.selectedPrinter);
        } else{
          setState(() {
            currentStep += 1;
          });
        }                
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 12),
          child: Text(buttonText)),
    );
  }
  Widget displayBackBtn(){
    return OutlinedButton(
      onPressed: () {
        if(currentStep < 2){
          setState(() {
            currentStep -=1;
          });
        } else {
          setState(() {
            showdebugUi = true;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(currentStep < 2 ? AppLocalizations.of(context)!.back : AppLocalizations.of(context)!.wrong_printer_setup)),
      );
  }
}
