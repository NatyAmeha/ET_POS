import 'package:flutter/foundation.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:hozmacore/features/company/model/company.dart';
import 'package:hozmacore/features/order/repo/product_repoisitory.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/features/payment/payment_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/invoice/services/print_service.dart';
import 'package:hozmacore/features/invoice/invoice_ui_helper.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

abstract class IPdfservice{
  Future<Uint8List> buildTestReceipt(PdfPageFormat pageFormat, {bool addBorder = false});
  Future<Uint8List> buildInvoicePdf(PdfPageFormat pageFormat,Order order , Customer? customer, List<Product>? products, List<Tax>? taxes, Company? companyInfo, POSConfig? posConfig);
  Future<List<Uint8List>> convertPdfToImages(Uint8List document, double imageSize);
  
}

class PdfService extends IPdfservice {
  ISharedPrefRepository sharedPrefRepo;
  IPaymentRepository? paymentRepo;
  IPrintService? printService;
  IProductRepository? productRepo;
  PdfService({
    this.sharedPrefRepo = const SharedPreferenceRepository(),
    this.paymentRepo,
    this.printService,
    this.productRepo,
  });

  @override
  Future<Uint8List> buildInvoicePdf(PdfPageFormat pageFormat, Order order , Customer? customer, List<Product>? products, List<Tax>? taxes, Company? companyInfo, POSConfig? posConfig) async {
    try{
      final document = pw.Document();
      var agentname = await sharedPrefRepo.get<String>(SharedPreferenceRepository.AGENT_NAME) ?? "";
      var paymentMethods = await paymentRepo!.getPaymentsFromDb();
      var pdfPage = await InvoiceUiHelper()
          .buildReceiptPdfForOrderConfirmationScreen(pageFormat,
              agentName: agentname, 
              paymentMethods: paymentMethods,
              order: order,
              customer: customer,
              products: products,
              taxes: taxes,
              companyInfo: companyInfo,
              posConfig: posConfig,
          );
      document.addPage(pdfPage);
      return document.save();
    } catch(ex){
      print("invoice pdf exception ${ex}");
      return Future.error(AppException(message: "Error occured while generating invoice pdf"));
    }
  }

  Future<Uint8List> buildTestReceipt(PdfPageFormat pageFormat, {bool addBorder = false}) async {
    try {
      final document = pw.Document();
      var pdfPage = await InvoiceUiHelper().buildTestReceiptPdf(pageFormat, addBorder: addBorder);
      document.addPage(pdfPage);
      return document.save();
    } catch (ex) {
      return Future.error(AppException(message: "Error occured while generating test receipt"));
    }
  }
  
  @override
  Future<List<Uint8List>> convertPdfToImages(Uint8List document, double imageSize) async {
    try{
      var images = <Uint8List>[];
      await for (var page in Printing.raster(document, dpi: 125)) {
        final image = await page.toPng();
        images.add(image);
      }
      return images;
    } on AppException catch(ex){
      return Future.error(ex);
    } catch(generalException){
      return Future.error(AppException(message: generalException.toString() , type: AppException.UNKNOWN_EXCEPTION));
    }
  }
}