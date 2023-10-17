import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/printer/printer_receipt_debug.dart';
import 'package:odoo_pos/ui/widgets/printer/printer_setup_confirmation.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:pdf/pdf.dart';

import '../../../controller/app_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SmallScreenPrinterSetupScreen extends StatefulWidget {
  HTPrinter selectedPrinter;
  String action;
  Function(HTPrinter updatedPrinter)? onPrinterSetupCompleted;
  Function(HTPrinter configuredPrinter)? onTestPrintClicked;
  SmallScreenPrinterSetupScreen({super.key, 
    required this.selectedPrinter, 
    required this.action, 
    this.onTestPrintClicked,
    this.onPrinterSetupCompleted,
    });

  @override
  State<SmallScreenPrinterSetupScreen> createState() =>
      _SmallScreenPrinterSetupScreenState();
}

class _SmallScreenPrinterSetupScreenState extends State<SmallScreenPrinterSetupScreen> {
  var appController = Get.find<AppController>();
  PdfPageFormat selectedPageFormat = PdfPageFormat.roll57;
  String printType = PrintType.Invoice.name;
  String paperSize = PrintPaperSize.MM57.name;
  String selectedProtocol = HTPrinter.EPSON_PROTOCOL;
  var currentStep = 0;
  var showPrinterDebugUi = false;

  @override
  void initState() {
    printType = widget.selectedPrinter.printType ?? PrintType.Invoice.name;
    paperSize = widget.selectedPrinter.paperSize ?? PrintPaperSize.MM57.name;
    selectedProtocol =
        widget.selectedPrinter.protocol ?? HTPrinter.EPSON_PROTOCOL;
    if (paperSize == PrintPaperSize.MM80.name) {
      selectedPageFormat = PdfPageFormat.roll80;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.printer_setup)),
      body: showPrinterDebugUi ? 
      PrinterReceptDebug(smallScreen: true, onBackButton: (){
        setState(() {
          currentStep = 0;
          showPrinterDebugUi = false;
        });
      },)
      : Stack(
        children: [
          Positioned.fill(
            child: Column(
            children: [
              if(currentStep < 2)...[
                const SizedBox(height: 16),
                TextView(
                  "${widget.selectedPrinter.deviceName}",
                  textStyle: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 16), 
                TextView(
                    AppLocalizations.of(context)!.validate_printer_setting,
                    maxline: 2,
                    startMargin: 16,
                    endMargin: 16,
                    textAlignment: TextAlign.center,
                    textStyle: Theme.of(context).textTheme.bodyMedium),
              ],
              
              Expanded(
                child: Stepper(
                  currentStep: currentStep,
                  type: StepperType.horizontal,
                  elevation: 4,
                  margin: EdgeInsets.zero,
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
                    content: buildprintFormatAndPaperSizeSelector(),
                  ),
                  Step(
                    title: SizedBox(), 
                    isActive: currentStep >= 1,
                    state: currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: PrinterSetupConfirmation(configuredPrinter: widget.selectedPrinter, title: AppLocalizations.of(context)!.preview, addBorder: true)
                  ),
                  Step(
                    title: SizedBox(), 
                    isActive: currentStep >= 2,
                    state: currentStep > 2 ? StepState.complete : StepState.indexed,
                    content: PrinterSetupConfirmation(
                      configuredPrinter: widget.selectedPrinter, 
                      title: AppLocalizations.of(context)!.receipt_match_with_preview
                    )
                  )
                ]),
              ),
              
              const SizedBox(height: 100),
            ],
            ),
          ),
          Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: buildActionButton(),
              ))
        ],
      ),
    );
  }

  buildActionButton() {
    var buttonText = AppLocalizations.of(context)!.continue_text;
    if(currentStep == 1){
      buttonText = AppLocalizations.of(context)!.print_preview;
    } else if(currentStep == 2){
      buttonText = AppLocalizations.of(context)!.submit_print_preview;
    }
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16 , left: 40, right: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () {
              if(currentStep == 1){
                widget.onTestPrintClicked?.call(widget.selectedPrinter);
                setState(() {
                  currentStep +=1;
                });
              }
              else if(currentStep == 2){
                //close printer setup screen
                Navigator.of(context).pop();
                widget.onPrinterSetupCompleted?.call(widget.selectedPrinter);
              } else{
                setState(() {
                  currentStep +=1;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(buttonText)
            )
          ),
          if(currentStep == 2)...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: (){
                 setState(() {
                   showPrinterDebugUi = true;
                 });
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text( AppLocalizations.of(context)!.wrong_printer_setup, textAlign: TextAlign.center),
                )
            )
          ]
        ],),
    );
  }

  Widget buildprintFormatAndPaperSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextView(
          AppLocalizations.of(context)!.printer_purpose,
          textStyle: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            const SizedBox(width: 12),
            Flexible(
              child: TextView(
                AppLocalizations.of(context)!.printer_purpose_description,
                textStyle: Theme.of(context).textTheme.bodySmall,
                maxline: 2,
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          runSpacing: 16,
          children: [
            CustomContainer(
              customPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: () {
                updatePrinterSetupInfo(type: PrintType.Invoice.name);
              },
              color: printType == PrintType.Invoice.name
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Colors.white,
              width: 100,
              borderRadius: 8,
              borderColor: Colors.grey[300],
              child: TextView(
                PrintType.Invoice.name,
                textColor: printType == PrintType.Invoice.name
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.black,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 16),
            CustomContainer(
              customPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: () {
                updatePrinterSetupInfo(type: PrintType.Order.name);
              },
              color: printType == PrintType.Order.name
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Colors.white,
              width: 100,
              borderRadius: 8,
              borderColor: Colors.grey[300],
              child: TextView(
                PrintType.Order.name,
                textColor: printType == PrintType.Order.name
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.black,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextView(
          AppLocalizations.of(context)!.print_paper_size,
          textStyle: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            const SizedBox(width: 8),
            TextView(
              AppLocalizations.of(context)!.print_paper_size_description,
              textStyle: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          runSpacing: 16,
          children: [
            CustomContainer(
              customPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: () {
                updatePrinterSetupInfo(size: PrintPaperSize.MM57.name, format: PdfPageFormat.roll57);
              },
              color: selectedPageFormat == PdfPageFormat.roll57
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Colors.white,
              borderRadius: 8,
              width: 100,
              borderColor: Colors.grey[300],
              child: TextView(
                AppLocalizations.of(context)!.fiftyeight_mm,
                textColor: selectedPageFormat == PdfPageFormat.roll57
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.black,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 16),
            CustomContainer(
              customPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              onTap: () {
                updatePrinterSetupInfo(size: PrintPaperSize.MM80.name, format: PdfPageFormat.roll80);
              },
              color: selectedPageFormat == PdfPageFormat.roll80
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Colors.white,
              borderRadius: 8,
              width: 100,
              borderColor: Colors.grey[300],
              child: TextView(
                AppLocalizations.of(context)!.eighty_mm,
                textColor: selectedPageFormat == PdfPageFormat.roll80
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.black,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 16),
            
          ],
        ),
        const SizedBox(height: 24),
        TextView(
          AppLocalizations.of(context)!.printer_protocol,
          textStyle: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            const SizedBox(width: 8),
            TextView(
              AppLocalizations.of(context)!.choose_printer_protocol,
              textStyle: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
        const SizedBox(height: 16),
        DropdownButton<String>(
          underline: SizedBox(),
          isExpanded: true,
          autofocus: true,
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          value: selectedProtocol,
          items: [
            DropdownMenuItem(
                value: HTPrinter.EPSON_PROTOCOL,
                child: SizedBox(
                    width: 250,
                    child: TextView(HTPrinter.EPSON_PROTOCOL,
                        textStyle: Theme.of(context).textTheme.titleMedium))),
            DropdownMenuItem(
                value: HTPrinter.OBSOLETE_EPSON_PROTOCOL,
                child: SizedBox(
                    width: 250,
                    child: TextView(HTPrinter.OBSOLETE_EPSON_PROTOCOL,
                        textStyle: Theme.of(context).textTheme.titleMedium)))
          ],
          onChanged: (value) {
            if (value != null) {
              updatePrinterSetupInfo(protocol: value);
            }
          },
        )
      ],
    );
  }

  updatePrinterSetupInfo(
      {
      String? size,
      String? protocol,
      PdfPageFormat? format,
      String? type,
      Uint8List? data}) {
    setState(() {
      
      if (size != null) {
        paperSize = size;
        widget.selectedPrinter.paperSize = size;
      }
      if (protocol != null) {
        selectedProtocol = protocol;
        widget.selectedPrinter.protocol = protocol;
      }
      if (format != null) {
        selectedPageFormat = format;
      }
      if (type != null) {
        printType = type;
        widget.selectedPrinter.printType = type; 
      }
    });
  }
}
