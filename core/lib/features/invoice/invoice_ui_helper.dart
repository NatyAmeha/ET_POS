import 'dart:convert';

import 'package:darq/darq.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hozmacore/constants/constants.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:intl/intl.dart';
import 'package:hozmacore/features/company/model/company.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceUiHelper {
  static const double INVOICE_WIDTH = 300;

  Future<pw.Page> buildTestReceiptPdf(
      PdfPageFormat pageFormat, {bool addBorder = true}) async {
      final cairoRegularFont = await rootBundle.load('assets/google_fonts/Cairo-Regular.ttf');
      final cairoBoldFont = await rootBundle.load('assets/google_fonts/Cairo-Bold.ttf');
    return pw.Page(
        pageTheme: pw.PageTheme(
            margin: pw.EdgeInsets.all(1),
            textDirection: pw.TextDirection.ltr,
            orientation: pw.PageOrientation.portrait,
            pageFormat: pageFormat,
            theme: pw.ThemeData.withFont(
                base: pw.Font.ttf(cairoRegularFont),
                bold: pw.Font.ttf(cairoBoldFont)).copyWith(defaultTextStyle: pw.TextStyle(color: PdfColors.black)),
            buildBackground: (context) => pw.Container(
                  decoration: pw.BoxDecoration(
                      border: addBorder ? pw.Border.all(color: PdfColors.red, width: 1) : null,
                      gradient: pw.LinearGradient(
                          begin: pw.Alignment.topCenter,
                          end: pw.Alignment.bottomCenter,
                          colors: [
                            PdfColors.white,
                            PdfColors.grey100,
                            PdfColors.white,
                            PdfColors.grey100
                          ])),
                ),
            ),
          
        build: ((context) {
          return pw.Padding(
              padding: pw.EdgeInsets.all(10),
              child: pw.Container(
                decoration: addBorder 
                  ? pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.red, width: 1),
                      ) : null,
                child: buildTestReceiptBody()
              )
             );
        }));
  }

  pw.Widget buildTestReceiptBody() {
    return pw.Column(
                  // mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text("CASH RECEIPT",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Divider(
                        borderStyle: pw.BorderStyle.dashed,
                        ),
                    pw.SizedBox(height: 3),
                    pw.Text("Receipt  :  1234567",
                        style: pw.TextStyle(fontSize: 6)),
                    pw.Text("Manager  :  Lorem I.",
                        style: pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 4),
                    pw.Text("DD/MM/YYYY 00:00:00",
                        style: pw.TextStyle(fontSize: 6)),
                    pw.Text("Address", style: pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text("Client",
                              style: pw.TextStyle(fontSize: 6)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(":", style: pw.TextStyle(fontSize: 6)),
                        ),
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text("Jhon Smith",
                              style: pw.TextStyle(fontSize: 6)),
                        )
                      ],
                    ),
                    pw.SizedBox(height: 1),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text("Date of Birth",
                              style: pw.TextStyle(fontSize: 6)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(":", style: pw.TextStyle(fontSize: 6)),
                        ),
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text("DD/MM/YYYY",
                              style: pw.TextStyle(fontSize: 6)),
                        )
                      ],
                    ),
                    pw.SizedBox(height: 1),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text("Location",
                              style: pw.TextStyle(fontSize: 6)),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(":", style: pw.TextStyle(fontSize: 6)),
                        ),
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text("Lorem Ip 123 567",
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(fontSize: 6)),
                        )
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text("Lorem Ipsum dolor 33-123",
                              style: pw.TextStyle(fontSize: 6)),
                          pw.Row(children: [
                            pw.Text("Cost", style: pw.TextStyle(fontSize: 6)),
                            pw.Expanded(
                                child: pw.Divider(
                                    borderStyle: pw.BorderStyle.dotted,
                                    )),
                            pw.Text("\$125.25",
                                style: pw.TextStyle(fontSize: 6)),
                          ])
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text("Lorem Ipsum dolor 33-123",
                              style: pw.TextStyle(fontSize: 6)),
                          pw.Row(children: [
                            pw.Text("Cost", style: pw.TextStyle(fontSize: 6)),
                            pw.Expanded(
                                child: pw.Divider(
                                    borderStyle: pw.BorderStyle.dotted,
                                    )),
                            pw.Text("\$125.25",
                                style: pw.TextStyle(fontSize: 6)),
                          ])
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text("Lorem Ipsum dolor 33-123",
                              style: pw.TextStyle(fontSize: 6)),
                          pw.Row(children: [
                            pw.Text("Cost", style: pw.TextStyle(fontSize: 6)),
                            pw.Expanded(
                                child: pw.Divider(
                                    borderStyle: pw.BorderStyle.dotted,
                                    )),
                            pw.Text("\$125.25",
                                style: pw.TextStyle(fontSize: 6)),
                          ])
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text("Lorem Ipsum dolor 33-123",
                              style: pw.TextStyle(fontSize: 6)),
                          pw.Row(children: [
                            pw.Text("Cost", style: pw.TextStyle(fontSize: 6)),
                            pw.Expanded(
                                child: pw.Divider(
                                    borderStyle: pw.BorderStyle.dotted,
                                    )),
                            pw.Text("\$125.25",
                                style: pw.TextStyle(fontSize: 6)),
                          ])
                        ]),
                    pw.Divider(
                        borderStyle: pw.BorderStyle.dashed,
                        ),
                    pw.Row(children: [
                      pw.Text("Total", style: pw.TextStyle(fontSize: 8)),
                      pw.Expanded(
                          child: pw.Divider(
                              borderStyle: pw.BorderStyle.dotted,
                              )),
                      pw.Text("\$225.25", style: pw.TextStyle(fontSize: 8)),
                    ]),
                    pw.SizedBox(height: 10),
                    pw.Text("THANK YOU FOR SHOPPING",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 12),
                    pw.Padding(
                      padding: pw.EdgeInsets.symmetric(horizontal: 24),
                      child: pw.BarcodeWidget(
                          barcode: pw.Barcode.code128(),
                          height: 25,
                          width: 115,
                          data: "12345"),
                    ),
                    pw.SizedBox(height: 7),
                    pw.Text("hozmatech.com",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 6)),
                  ]);
  }

  Future<pw.Page> buildReceiptPdfForOrderConfirmationScreen(
      PdfPageFormat pageFormat,
      {required String agentName,
      required List<Payment> paymentMethods,
      required Order order,
      Customer? customer,
      List<Product>? products,
      List<Tax>? taxes,
      Company? companyInfo,
      POSConfig? posConfig}) async {
    final cairoRegularFont =
        await rootBundle.load('assets/google_fonts/Cairo-Regular.ttf');
    final cairoBoldFont =
        await rootBundle.load('assets/google_fonts/Cairo-Bold.ttf');

    if (pageFormat.height == double.infinity) {
      // pdf viwer for rollor paper (thermal receipt papers)
      return pw.Page(
        pageTheme: pw.PageTheme(
            margin: pw.EdgeInsets.all(0),
            textDirection: pw.TextDirection.rtl,
            orientation: pw.PageOrientation.portrait,
            theme: pw.ThemeData.withFont(
                base: pw.Font.ttf(cairoRegularFont),
                bold: pw.Font.ttf(cairoBoldFont),
            ).copyWith(defaultTextStyle: pw.TextStyle(color: PdfColors.black)),
            pageFormat: pageFormat,
            buildBackground: (context) => pw.Container(
                  decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                          begin: pw.Alignment.topCenter,
                          end: pw.Alignment.bottomCenter,
                          colors: [
                            PdfColors.white,
                            PdfColors.grey100,
                            PdfColors.white,
                            PdfColors.grey100
                          ])),
                ),
            ),
        build: ((context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(8),
            child: pw.Column(
              children: [
                _buildHeader(context,
                    order: order,
                    shopName: companyInfo?.name, // appController.selectedPosConfig!.name,
                    customer: customer,
                    companyInfo: companyInfo,
                    products: products,
                    taxes: taxes,
                    
                ),
                _items(context, order, products, taxes, posConfig),
              ],
            ),
          );
        }),
      );
    } else {
      return pw.MultiPage(
        maxPages: 100,
        pageTheme: pw.PageTheme(
          buildBackground: (pw.Context context) =>
              pw.Container(color: PdfColors.white),
          orientation: pw.PageOrientation.portrait,
          pageFormat: pageFormat,
        ),
        header: (ctx) => _buildHeader(ctx,
            order: order,
            shopName: companyInfo?.name, // appController.selectedPosConfig!.name,
            customer: customer,
            products: products,
            taxes: taxes,
            companyInfo: companyInfo,
          ),
        build: (ctx) => [
          _items(ctx, order, products, taxes, posConfig),
        ],
      );
    }
  }

  List<int> buildEncodedQrField(int tag , String field){
    var encodedField = utf8.encode(field);
    var length = [encodedField.length];
    var encodedTag = [tag];
    var encodeddata = encodedTag.concat(length).concat(encodedField).toList();
    return  encodeddata;
  } 

  pw.Widget _buildQrCode(Company companyInfo, Order orderInfo, List<Product>? products, List<Tax>? taxes) {
    var companyNameEncoded = buildEncodedQrField(1, companyInfo.name!);
    var companyVatEncoded = buildEncodedQrField(2, companyInfo.vat!);
    var orderTimestampEncoded = buildEncodedQrField(3, orderInfo.creation_date!);
    var totalAmountEncoded = buildEncodedQrField(4, orderInfo.amount_total!);
    var totalVatAmountEncoded = buildEncodedQrField(5, "${orderInfo.getTotalVat(products, taxes)}");
    var finalInfo = companyNameEncoded.concat(companyVatEncoded).concat(orderTimestampEncoded).concat(totalAmountEncoded).concat(totalVatAmountEncoded).toList();
    var finalQrInfoBase64 = base64.encode(finalInfo);
    return pw.Container(
        padding: pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 3),
            borderRadius: pw.BorderRadius.circular(12)),
        child: pw.BarcodeWidget(
            color: PdfColor.fromHex("#000000"),
            barcode: pw.Barcode.qrCode(),
            height: 40,
            width: 40,
            data: finalQrInfoBase64),
    );
  }

  pw.Widget _buildBarcode(String data) {
    return pw.BarcodeWidget(
        color: PdfColor.fromHex("#000000"),
        barcode: pw.Barcode.code128(),
        height: 30,
        width: 140,
        data: data);
  }

  pw.Widget _footer(Order order) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Container(
        alignment: pw.Alignment.center,
        width: INVOICE_WIDTH,
        child: pw.Column(children: [
          pw.Text("ايصال  \n" + order!.id!,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: 14,
              )),
          pw.Text(
            DateTime.now().toString().substring(
                  0,
                  DateTime.now().toString().indexOf(".", 0),
                ),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 14,
            ),
          ),
        ]),
      ),
    );
  }

  pw.Widget _items(
      pw.Context context, Order order, List<Product>? products, List<Tax>? taxes, POSConfig? posConfig) {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(children: [
        pw.Divider(thickness: 0.5, height: 4),
        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
          pw.Expanded(
              child: pw.Text("Total",
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
              flex: 2),
          pw.Expanded(
              child: pw.Text("VAT",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
              flex: 2),
          pw.Expanded(
              child: pw.Text("Product",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)),
              flex: 4),
        ]),
        pw.Divider(thickness: 0.5, height: 4),
        pw.ListView.separated(
            itemBuilder: (context, index){
              var selectedOrderItem = order.lines[index];
              return _orderedItems(selectedOrderItem, products, taxes, posConfig);
            },
            separatorBuilder: (context, index) =>
                pw.Divider(thickness: 0.5, height: 4, color: PdfColors.grey300),
            itemCount: order.lines.length),
        pw.Divider(
            borderStyle: pw.BorderStyle.dashed,
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "${posConfig?.getPriceStringWithConfiguration(order.getSubtotal())}",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("Subtotal",
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "${posConfig?.getPriceStringWithConfiguration(order.getTotalVat(products, taxes))}",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("VAT (15%)",
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              "${posConfig?.getPriceStringWithConfiguration(double.parse(order.amount_total!))}",
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("Total",
                textAlign: pw.TextAlign.center,
                style:
                    pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ],
        ),
        pw.Divider(height: 36, thickness: 1),
        _buildBarcode(order.id!)
      ]),
    );
  }

  pw.Widget _paymentMethods(
      pw.Context context, Order order, List<Payment> appPaymentMethods) {
    var orderPaymentInfo = paymentInfoUsedForOrder(appPaymentMethods, order);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.SizedBox(height: 8),
        pw.Divider(height: 16, thickness: 1),
        pw.Text(
          "Payment Method",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(height: 16, thickness: 1),
        pw.ListView.separated(
            separatorBuilder: (context, index) => pw.SizedBox(height: 8),
            itemBuilder: (context, index) {
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(orderPaymentInfo[index]!["payment_name"].toString(),
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(fontSize: 14)),
                  // pw.Text(
                  //     "${appController.getPriceStringWithConfiguration((double.parse(orderPaymentInfo[index]!["amount"].toString())))}",
                  //     textAlign: pw.TextAlign.center,
                  //     style: pw.TextStyle(fontSize: 14)),
                ],
              );
            },
            itemCount: orderPaymentInfo.length),
        pw.Divider(thickness: 1, height: 16, color: PdfColors.grey300),
        (getTotalDiscounts(order).toInt() > 0)
            ? pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Discount",
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  // pw.Text(
                  //     "${appController.getPriceStringWithConfiguration(getTotalDiscounts(order))}",
                  //     textAlign: pw.TextAlign.center,
                  //     style: pw.TextStyle(
                  //         fontSize: 14, fontWeight: pw.FontWeight.bold)),
                ],
              )
            : pw.Container()
      ],
    );
  }

  pw.Widget _orderedItems(Line orderItem, List<Product>? products, List<Tax>? taxes, POSConfig? posConfig) {
    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Expanded(
              child: pw.Text(
                  "${posConfig?.getPriceStringWithConfiguration(orderItem.getTotalAmount(products, taxes))}",
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(fontSize: 7)),
              flex: 2),
          pw.Expanded(
              child: pw.Text(
                  "${posConfig?.getPriceStringWithConfiguration(orderItem.getVatAmount(products, taxes))}",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: 7)),
              flex: 2),
          pw.Expanded(
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(orderItem.display_name.toString(),
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.normal)),
                    pw.Text(
                        "${orderItem.qty}X (${posConfig?.getPriceStringWithConfiguration(double.parse(orderItem.price_unit!))})",
                        textAlign: pw.TextAlign.left,
                        style: pw.TextStyle(
                            fontSize: 7, fontWeight: pw.FontWeight.normal)),
                    if (orderItem.discount.toInt() > 0)
                      pw.Text(
                          "${posConfig?.getPriceStringWithConfiguration(orderItem.discountAmount)} (Discount ${orderItem.discount.toStringAsFixed(0)}%)",
                          textAlign: pw.TextAlign.left,
                          style: pw.TextStyle(fontSize: 7))
                  ]),
              flex: 4),
        ],
      ),
    ]);
  }


  pw.Widget _buildHeader(pw.Context context,
      {
      required Order order,
      String? shopName,
      Customer? customer,
      List<Product>? products,
      List<Tax>? taxes,
      Company? companyInfo}) {
    return pw.Container( 
      alignment: pw.Alignment.center,
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if(companyInfo?.logo != null)
              pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 8, bottom: 16),
                height: 40,
                width: 40,
                child:  pw.Image(pw.MemoryImage(base64Decode(companyInfo!.logo!))) ,
              ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  alignment: pw.Alignment.center,
                  height: 50,
                  width: 50,
                  child: companyInfo != null ? _buildQrCode(companyInfo, order, products, taxes) : pw.SizedBox(),
                ),
                pw.Expanded(child: pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Simplified Tax Invoice",
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        )),
                    pw.Text("Order Id",
                        textDirection: pw.TextDirection.rtl,
                        maxLines: 1,
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    pw.Text("${order.id}",
                        textDirection: pw.TextDirection.rtl,
                        maxLines: 1,
                        style: pw.TextStyle(fontSize: 6)),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "${shopName}",
                      style: pw.TextStyle(
                          fontSize: 7, fontWeight: pw.FontWeight.bold),
                    ),
                    if (companyInfo?.address != null)
                      pw.Text(
                        "${companyInfo?.address}, ${companyInfo?.city}",
                        style: pw.TextStyle(fontSize: 9),
                      ),
                  ],
                ),)
              ],
            ),
            pw.Divider(thickness: 2, height: 24),
            pw.Text(
              "${DateFormat("dd-MM-yyyy hh:mm").format(DateTime.tryParse(order.creation_date!)!)} :Order date",
              style: pw.TextStyle(fontSize: 8),
            ),
            pw.SizedBox(height: 4),
            if (companyInfo?.vat != null)
              pw.Text(
                "${companyInfo?.vat} :VAT id",
                style: pw.TextStyle(fontSize: 8),
              ),
          ]),
    );
  }

  double getTotalDiscounts(Order order) {
    var totalDiscount = 0.0;
    order.lines.forEach((element) {
      totalDiscount += element.discountAmount;
    });
    return totalDiscount;
  }

  List<Map<String, dynamic>> paymentInfoUsedForOrder(
      List<Payment> paymentMethods, Order order) {
    List<Map<String, dynamic>> paymentInfoList = [];
    order.payment_method_id.forEach((element) {
      paymentMethods.forEach((e) {
        if (e.id == element.payment_id) {
          var paymentMap = <String, dynamic>{
            "amount": element.amount,
            "payment_name": e.name,
          };
          paymentInfoList.add(paymentMap);
        }
      });
    });
    return paymentInfoList;
  }

}
