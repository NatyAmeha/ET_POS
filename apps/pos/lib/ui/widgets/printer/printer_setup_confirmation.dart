import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/invoice/services/pdf_service.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:pdf/pdf.dart';


class PrinterSetupConfirmation extends StatefulWidget {
  var appController = Get.find<AppController>();
  HTPrinter configuredPrinter;
  String? title;
  String? description;
  bool addBorder;
  // pass test receipt data to printer info. it will be called for test print
  Function(HTPrinter updatedPrinter)? onPrinterSetupChanged;

  PrinterSetupConfirmation({required this.configuredPrinter,  this.title,  this.description  , this.addBorder = false , this.onPrinterSetupChanged});

  @override
  State<PrinterSetupConfirmation> createState() => _PrinterSetupConfirmationState();
}

class _PrinterSetupConfirmationState extends State<PrinterSetupConfirmation> {
  PdfPageFormat selectedFormat = PdfPageFormat.roll57;
  Uint8List? testReceiptData;

  @override
  void initState() {
    Future.delayed(Duration.zero , () async {
      var data =  await PdfService().buildTestReceipt(selectedFormat, addBorder: widget.addBorder);
      var imageData =  await widget.appController.convertPdfToImage(data, 125);
      setState(() {
        testReceiptData = imageData;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: CustomContainer(
        padding: 0,
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            if(widget.title != null)
              Text(widget.title!, style: Helper.isTablet(context) ? Theme.of(context).textTheme.displayMedium : Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center,),
            if(widget.description != null) ...[
              const SizedBox(height: 8),
              TextView(widget.description, maxline: 2,textAlignment: TextAlign.center,textStyle: Theme.of(context).textTheme.bodyLarge),
            ],
            const SizedBox(height: 16),
            testReceiptData != null ? Stack(
              children: [
                Positioned(child: SizedBox(height: 800)),
                Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset("assets/images/receipt_machine.png", height: 110),),
              
                Positioned.fill(
                  left: 0, right: 0, top: 45,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Image.memory(Uint8List.fromList(testReceiptData!),)),
                )
              ],
            ) : CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
