
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/printer_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/ui/screens/dashboard_screen.dart';
import 'package:odoo_pos/ui/screens/invoice_screen.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OrderConfirmScreen extends StatefulWidget {
  Customer? customer;
  OrderModel mOrderModel;


  OrderConfirmScreen(this.customer, this.mOrderModel);

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  var shopController = Get.find<ShopController>();

  var printercontroller = Get.put(PrinterController());
  var receiptPreviewImage;

  @override
  void initState() {
    Future.delayed(Duration.zero , () async {
      var data =  await printercontroller.buildInvoicePdf(context, PdfPageFormat.roll80, widget.mOrderModel.orders[0], widget.mOrderModel.customer, );
      var imageData =  await shopController.appController.convertPdfToImage(data, 125);
      setState(() {
        receiptPreviewImage = imageData;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.order_confirmation),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Helper.isTablet(context)
            ? buildTabletVersion(context)
            : buildMobileVersion(context),
      ),
    );
  }

  buildPdf(BuildContext context, double width) {
    return PdfPreview(
      previewPageMargin: const EdgeInsets.all(1),
      padding: EdgeInsets.zero,
      maxPageWidth: width,
      build: (format) async {
        return printercontroller.buildInvoicePdf(
            context, format, widget.mOrderModel.orders[0], widget.mOrderModel.customer);
      },
      initialPageFormat: PdfPageFormat.roll80,
      canChangePageFormat: false, 
      canChangeOrientation: false,
      allowPrinting: false,
      allowSharing: false,
      dynamicLayout: false,
    );
  }

  buildTabletVersion(BuildContext context) {
    return CustomContainer(
      customPadding: const EdgeInsets.symmetric(horizontal: 76, vertical: 32),
      height: double.infinity,
      child: Column(children: [
        buildAppbar(context),
        const SizedBox(height: 32),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: CustomContainer(
                  customPadding: const EdgeInsets.symmetric(horizontal: 32),
                  alignment: Alignment.topCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomContainer(
                        color: Colors.green[100],
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                color: Theme.of(context).colorScheme.tertiary),
                            const SizedBox(width: 16),
                            TextView(AppLocalizations.of(context)!.order_completed,
                                textStyle:
                                    Theme.of(context).textTheme.titleMedium),
                            Spacer(),
                            Flexible(
                              child: TextView("${widget.mOrderModel.orders[0].name}",
                                  textStyle:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextView(AppLocalizations.of(context)!.how_do_you_want_to_receive_your_receipt,
                          textStyle: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppLocalizations.of(context)!.via_email),
                              Icon(Icons.send, size: 24),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                          onPressed: () async {
                            printercontroller.printOrderReceipt(context, widget.mOrderModel.orders[0], widget.mOrderModel.customer);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppLocalizations.of(context)!.print_receipt),
                                Icon(Icons.local_printshop, size: 24),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              CustomContainer(
                padding: 0,
                borderColor: Colors.grey,
                borderRadius: 16,
                width: MediaQuery.of(context).size.width * 0.4,
                child:
                    buildPdf(context, MediaQuery.of(context).size.width * 0.4),
              )
            ],
          ),
        )
      ]),
    );
  }

  buildMobileVersion(BuildContext context) {
    return SingleChildScrollView(
      child: CustomContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 70),
            Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.tertiary, size: 70),
            SizedBox(height: 24),
            TextView("${widget.mOrderModel.orders[0].name}",
            alignment: Alignment.center ,
                textStyle: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 54),
            TextView(AppLocalizations.of(context)!.how_do_you_want_to_receive_your_receipt,
                alignment: Alignment.center,
                textStyle: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {},
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.via_email),
                    Icon(Icons.send, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () async {
                printercontroller.printOrderReceipt(context, widget.mOrderModel.orders[0], widget.mOrderModel.customer);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppLocalizations.of(context)!.print_receipt),
                    Icon(Icons.local_printshop, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomContainer(
                padding: 0,
                height: 600,
                borderRadius: 16,
                borderColor: Colors.grey,
                child: buildPdf(context, MediaQuery.of(context).size.width)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => DashBoardScreen(null)),
                  ModalRoute.withName('/'),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.new_order),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildLayout(BuildContext context) {
    print("select cashier ${shopController.selectedCashier?.name}");
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 64),
          TextView(shopController.selectedCashier == null
              ? ""
              : "${AppLocalizations.of(context)!.cashier} : ${shopController.selectedCashier!.name!}"),
          TextView(widget.customer == null ? "" : "${AppLocalizations.of(context)!.cartCustomer} : " + widget.customer!.name!),
          TextView(
            "${AppLocalizations.of(context)!.order_id}:  + ${widget.mOrderModel.orders?.firstOrNull?.name}",
            margin: 12,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: MyColors.accentColor),
              onPressed: () {
                Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => DashBoardScreen(null)),
                  ModalRoute.withName('/'),
                );
              },
              child: Text(AppLocalizations.of(context)!.new_order)),
          ElevatedButton(
              style: ElevatedButton.styleFrom(primary: MyColors.accentColor),
              onPressed: () {
                if (widget.mOrderModel.orders?.isNotEmpty == true) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InvoiceScreen(widget.mOrderModel.orders![0], widget.customer)));
                }
              },
              child: Text(AppLocalizations.of(context)!.invoice))
        ],
      ),
    );
  }

  buildAppbar(BuildContext context) {
    return Row(
      mainAxisAlignment: Helper.isTablet(context)
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (Helper.isTablet(context)) ...[
          CustomContainer(
              width: 50,
              height: 50,
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => DashBoardScreen(
                          shopController.appController.posOpeningInfo)));
                }
              },
              child: Icon(Icons.arrow_back_ios)),
          const SizedBox(width: 16),
          TextView(AppLocalizations.of(context)!.orders,
              textStyle: Theme.of(context).textTheme.displayLarge),
          const Spacer(),
          FilledButton(
            onPressed: () {
               Navigator.pushAndRemoveUntil<void>(
                  context,
                  MaterialPageRoute<void>(
                      builder: (BuildContext context) => DashBoardScreen(null)),
                  ModalRoute.withName('/'),
                );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.new_order),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
