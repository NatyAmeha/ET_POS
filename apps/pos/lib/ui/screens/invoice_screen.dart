import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/printer_controller.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InvoiceScreen extends StatefulWidget {
  Order order;
  Customer? customer;

  InvoiceScreen(this.order, this.customer);

  @override
  InvoiceScreenState createState() {
    return InvoiceScreenState();
  }
}

class InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  var printerController = Get.put(PrinterController());
  PrintingInfo? printingInfo;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero , (){
      printerController.getPrintingInfo();
    }); 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    pw.RichText.debug = false;
    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.invoice)),
        body: Obx(
          () => printerController.printintInfo.value.data == null
              ? const Center(child: CircularProgressIndicator())
              : PdfPreview(
                  previewPageMargin: const EdgeInsets.all(1),
                  padding: EdgeInsets.zero,
                  maxPageWidth: Helper.isTablet(context)
                      ? MediaQuery.of(context).size.width * 0.6
                      : MediaQuery.of(context).size.width,
                  build: (format) async {
                    return printerController.buildInvoicePdf(
                        context, format, widget.order, widget.customer);
                  },
                  initialPageFormat: PdfPageFormat.roll57,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  allowPrinting: false,
                  allowSharing: false,
                  dynamicLayout: false,
                ),
        ));
  }
}
