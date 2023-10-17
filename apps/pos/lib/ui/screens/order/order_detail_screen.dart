
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/controller/printer_controller.dart';
import 'package:odoo_pos/ui/screens/dashboard_screen.dart';
import 'package:odoo_pos/ui/widgets/CommonWidgets.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/number_pad_beta.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';

import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/constants/constants.dart';

import 'package:pdf/pdf.dart';

class OrderDetailScreen extends StatefulWidget {
  OrderModel orderModel;

  OrderDetailScreen(this.orderModel);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  var orderController = Get.find<OrderController>();
  var printerController = Get.put(PrinterController());

  
  var selectedProductIndex = 0;
  var refundedQty = "";
  var selectedAction = NumberPadAction.QTY.name;

  var selectedProductsToRefund = <Line>[];

  @override
  Widget build(BuildContext context) {
    return Helper.isTablet(context)
        ? Scaffold(body: drawOrderDetailsLayout(widget.orderModel, context))
        : Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.ordDetOrderDetails),
              actions: [
                if (widget.orderModel.syncStatus == "unsync" &&
                    !Helper.isTablet(context))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: syncButton(widget.orderModel, context),
                  )
              ],
            ),
            body: drawOrderDetailsLayout(widget.orderModel, context),
          );
  }

  syncButton(OrderModel orderModel, BuildContext context) {
    return FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary),
        onPressed: () {
          CommonWidgets.showProgressbar();
          orderController.orderSyncWithServer(context, orderModel);
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text(AppLocalizations.of(context)!.ordDetSyncOrder)));
  }

  drawOrderDetailsLayout(OrderModel orderModel, BuildContext context) {
    var data = orderModel.orders[0];
    return CustomContainer(
        borderRadius: 6,
        padding: 0,
        borderColor: Colors.grey[50],
        customMargin: EdgeInsets.symmetric(
            horizontal: Helper.isTablet(context) ? 25 : 0,
            vertical: Helper.isTablet(context) ? 8 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (Helper.isTablet(context))
              CustomContainer(
                color: Colors.grey[100],
                height: 80,
                borderColor: Colors.grey[300],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextView(
                      AppLocalizations.of(context)!.date +
                          " : " +
                          data.name!,
                      textStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (orderModel.syncStatus == "unsync")
                      syncButton(orderModel, context)
                  ],
                ),
              ),
            CustomContainer(
              
              padding: 0,
              borderColor: Colors.grey[300],
              height: Helper.isTablet(context) ? MediaQuery.of(context).size.height * 0.45 : MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: data.lines.length,
                      separatorBuilder: (context, index) => Divider(height: 0),
                      itemBuilder: (BuildContext c, int index) {
                        var item = data.lines[index];
                        return productItemLayout(
                            context, item, index, selectedProductIndex, () {
                          setState(() {
                            selectedProductIndex = index;
                            refundedQty = "";
                          });
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Divider(thickness: 1, color: Colors.grey),
                        TextView(
                          "${AppLocalizations.of(context)!.cartTotal}: ${orderController.appController.getPriceStringWithConfiguration(double.parse(widget.orderModel.orders[0].amount_total!))}",
                          textSize: 24,
                          setBold: true,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FilledButton(
                    onPressed: () {
                      showReceiptPreviewAndPrint();
                    },
                      child: Padding(
                        padding: const EdgeInsets.all(10), 
                        child: Row(
                          children: [
                            Icon(Icons.add),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.print_invoice),
                          ],
                        ),
                      )),
                  const SizedBox(width: 24),
                  FilledButton(
                      onPressed: () {},
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.add),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.bill),
                            ],
                          ))),
                ],
              ),
            ),
            Expanded(
              child: NumberPadBeta(
                disablePrice: true,
                disableDiscount: true,
                initialAction: selectedAction,
                heightFactorForActionPad: 2,
                additionalActions: [
                  CustomContainer(
                    padding: 0,
                    color: Colors.black,
                    borderColor: Colors.grey,
                    selectedBorderSidesForRadius: [8,0,0,0],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.account_circle_outlined,
                            color: Colors.white, size: 30),
                        Flexible(
                          child: TextView(
                              "${widget.orderModel.customer?.name ?? AppLocalizations.of(context)!.cartCustomer}",
                              textColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  CustomContainer(
                    padding: 0,
                    selectedBorderSidesForRadius: [0,0,0,8],
                    onTap: selectedProductsToRefund.isNotEmpty
                        ? () {
                            handleProductRefund();
                          }
                        : null,
                    borderColor: selectedProductsToRefund.isNotEmpty
                        ? Colors.grey
                        : null,
                    color: selectedProductsToRefund.isEmpty
                        ? Colors.grey[100]
                        : Colors.black,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.rotate_left,
                            color: selectedProductsToRefund.isEmpty
                                ? Colors.grey
                                : Colors.white,
                            size: 30),
                        Flexible(
                          child: TextView(
                            AppLocalizations.of(context)!.refund,
                            textColor: selectedProductsToRefund.isEmpty
                                ? Colors.black45
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
                onNumberClicked: (value) {
                  setState(() {
                    setRefundQtyToProduct(value);
                  });
                },
                onActionSelected: (value) {
                  setState(() {
                    handleActionSelection(value);
                  });
                },
              ),
            ),
          ],
        ));
  }

  productItemLayout(BuildContext context, Line item, int index,
      int selectedIndex, Function onProductSelected) {
    return CustomContainer(
        padding: 10,
        onTap: () {
          onProductSelected();
        },
        color: selectedIndex == index
            ? Theme.of(context).colorScheme.secondaryContainer
            : Colors.white,
        borderRadius: 0,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        item.display_name,
                        setBold: true,
                        textStyle: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      TextView(
                        item.itemQtyWithPriceInfo(),
                        textSize: 16,
                      ),
                      if(item.discount > 0)
                        TextView(
                          item.discountInfo(),
                          textStyle: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 4),
                      if (item.refunded_qty?.toInt().isGreaterThan(0) == true)
                        TextView(
                          item.refundInfo(),
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          textColor: Theme.of(context).colorScheme.tertiary,
                        ),
                    ]),
              ),
              TextView(
                " ${item.qty?.isLowerThan(0) == true ? "-" : ""} ${orderController.appController.getPriceStringWithConfiguration(item.getTotalAmount(orderController.appController.allProducts, orderController.appController.taxes))}",
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ]));
  }

  setRefundQtyToProduct(String value) {
    // selectedproductindex variable holds index of selected product from list ordered items(lines) insdie order 
    // before setting refund qty we should have to select product, that's why we use selectedproductindex 
    if(selectedProductIndex < 0){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.refund_error_description);
    }
    else{
      // avoid setting refund qty when cashier click "." button from number pad
      if (value == ".") {
        //append the dot to previous refund qty
        return;
      }
      refundedQty += value;
      var newQty = int.parse(refundedQty);
      var selectedProduct =
          widget.orderModel.orders[0].lines[selectedProductIndex];
      if (selectedProduct.qty?.isLowerThan(newQty) == true) {
        Helper.showAlertDialog(context,
            title: AppLocalizations.of(context)!.maximum_exceeded,
            description:
                AppLocalizations.of(context)!.maximum_exceeded_description,
            cancelText: "",
            confirmText: AppLocalizations.of(context)!.ok);
            refundedQty = "";
      } else {
        if (selectedProduct.product_id != null && newQty > 0) {
          selectedProduct.refunded_qty = newQty.toDouble();
          var index = selectedProductsToRefund.indexWhere((p) => p.product_id == selectedProduct.product_id);
          if(index > -1){
            selectedProductsToRefund[index] = selectedProduct;
          }
          else{
            selectedProductsToRefund.add(selectedProduct);
          }
        }
      }
    }
  }

  handleActionSelection(String value) {
    selectedAction = value;
    if (value == "DELETE") {
      var selectedProduct =
          widget.orderModel.orders[0].lines[selectedProductIndex];
      selectedProduct.refunded_qty = 0;
      selectedProductsToRefund.remove(selectedProduct);
      refundedQty = "";
    }
  }

  handleProductRefund() async {
    await orderController.refundProduct(context ,  selectedProductsToRefund);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              DashBoardScreen(orderController.appController.posOpeningInfo)));
  }

  showReceiptPreviewAndPrint() async {
    var orderReceiptPdf = await printerController.buildInvoicePdf(context, PdfPageFormat.roll80, widget.orderModel.orders[0], widget.orderModel.customer);
    var receiptIMage = await printerController.appController.convertPdfToImage(orderReceiptPdf, 125);
    Helper.showPreviewModal(
      context, 
      Helper.isTablet(context) ? MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.9 ,
      MediaQuery.of(context).size.height * 0.8,
      showPrintReciptBtn: true,
      pdfData: receiptIMage,
      actionText: AppLocalizations.of(context)!.print_invoice,
      onTestPrintCalled: () {
        printerController.printOrderReceipt(context, widget.orderModel.orders[0], widget.orderModel.customer);
      },
    );
  }
}
