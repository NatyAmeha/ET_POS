import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrinterSetupDialog extends StatefulWidget {
  HTPrinter selectedPrinter;
  Function(HTPrinter updatedPrinter)? onPrinterSetupChanged;
  PrinterSetupDialog({
    super.key,
    required this.selectedPrinter,
    this.onPrinterSetupChanged,
  });

  @override
  State<PrinterSetupDialog> createState() => _PrinterSetupDialogState();
}

class _PrinterSetupDialogState extends State<PrinterSetupDialog> {
   var appController = Get.find<AppController>();
  PdfPageFormat selectedPageFormat = PdfPageFormat.roll57;
  String printType = PrintType.Invoice.name;
  String paperSize = PrintPaperSize.MM57.name;
  String selectedProtocol =  HTPrinter.EPSON_PROTOCOL;
  Uint8List? testReceiptImage;

  @override
  void initState() {
    printType = widget.selectedPrinter.printType ?? PrintType.Invoice.name;
    paperSize = widget.selectedPrinter.paperSize ?? PrintPaperSize.MM57.name;
    selectedProtocol = widget.selectedPrinter.protocol ?? HTPrinter.EPSON_PROTOCOL;
    if (paperSize == PrintPaperSize.MM80.name) {
      selectedPageFormat = PdfPageFormat.roll80;
    }
    updateReceiptIMage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: 0,
      alignment: Alignment.topCenter,
          width: Helper.isTablet(context)
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.width,
          height: Helper.isTablet(context)
              ? MediaQuery.of(context).size.height * 0.8
              : MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Helper.isTablet(context)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child:
                                  buildprintFormatAndPaperSizeSelector()),
                          SizedBox(width: 24),
                          Expanded(child: buildReceiptPreview())
                        ],
                      )
                    : Column( 
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          buildprintFormatAndPaperSizeSelector(),
                          const Divider(height: 50, thickness: 2),
                          buildReceiptPreview()
                        ],
                      )
              ],
            ),
          ),
        );
  }

  Widget buildReceiptPreview(){
    return Stack(
      children: [
          Positioned(child: SizedBox(height: 800)),
          Positioned(left: 0, right: 0,
           child: Image.asset("assets/images/receipt_machine.png", height: paperSize == PrintPaperSize.MM57.name? 130 : 130),
          ),
          Positioned.fill(
            left: 0, right: 0, top: 57,
            child: Align(
              alignment: Alignment.topCenter,
              child: testReceiptImage != null 
                ? Image.memory(Uint8List.fromList(testReceiptImage!),)
                : SizedBox(
                    height: 350,
                    child: Center(child: CircularProgressIndicator(),)
                  ),
              ),
            )
      ],
    );
  } 

  updateReceiptIMage(){
    Future.delayed(Duration.zero, () async{
      var imageData = await appController.generateTestReceiptImage(selectedPageFormat);
      setState(() {
        testReceiptImage = imageData;
      });
    });
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
          children: [
            Icon(Icons.info, color: Colors.grey),
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
        Row(
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
            Icon(Icons.info, color: Colors.grey),
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
            Icon(Icons.info, color: Colors.grey),
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
          padding: const EdgeInsets.symmetric(horizontal: 16 , vertical: 4),
          value: selectedProtocol,

          items: [
          DropdownMenuItem(value: HTPrinter.EPSON_PROTOCOL, child: SizedBox(width: 250, child: TextView(HTPrinter.EPSON_PROTOCOL , textStyle: Theme.of(context).textTheme.titleMedium))),
          DropdownMenuItem(value: HTPrinter.OBSOLETE_EPSON_PROTOCOL, child: SizedBox(width: 250, child: TextView(HTPrinter.OBSOLETE_EPSON_PROTOCOL , textStyle: Theme.of(context).textTheme.titleMedium)))
        ], 
        
        onChanged: (value) {
          if(value != null){
            updatePrinterSetupInfo(protocol: value);
          }
        },)
      ],
    );
  }

  updatePrinterSetupInfo({String? size , String? protocol , PdfPageFormat? format , String? type , Uint8List? data}){
    setState(() {
      if(size != null){
        paperSize = size;
        widget.selectedPrinter.paperSize = size;

      }
      if(protocol != null){
        selectedProtocol = protocol;
        widget.selectedPrinter.protocol = protocol;

      }  
      if(format != null){
        selectedPageFormat = format;

      }    
      if(type != null){
        printType = type;
        widget.selectedPrinter.printType = type;
      }   
    });
    if(size != null){
      updateReceiptIMage(); 
    }

  }

}
