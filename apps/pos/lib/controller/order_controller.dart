import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:intl/intl.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/ui/screens/customer/customer_selection_screen.dart';
import 'package:odoo_pos/ui/screens/order/order_confirmation_screen.dart';
import 'package:odoo_pos/utils.dart';
import 'package:hozmacore/features/customer/model/customerResponse.dart';
import 'package:hozmacore/features/order/model/holdCartModel.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/customer/services/multi_window_service.dart';
import 'package:hozmacore/features/customer/customer_usecase.dart';
import 'package:hozmacore/shared_models/Response.dart' as AppResposne;
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/features/order/repo/order_repository.dart';
import 'package:hozmacore/features/payment/payment_repository.dart';
import 'package:hozmacore/features/order/repo/product_repoisitory.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/order/services/barcode_service.dart';

import 'package:hozmacore/features/order/usecase/order_usecase.dart';
import 'package:hozmacore/features/payment/payment_usecase.dart';
import 'package:hozmacore/features/order/usecase/product_usecase.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OrderController extends GetxController{
  var appController = Get.find<AppController>();

  var isLoading = false.obs;
  
  var shopController = Get.find<ShopController>();
  int? get selectedPriceListId => shopController.getSelectedPriceListItem()?.id ?? 0;

  var selectedHoldedCart = 0.obs;
  var holdOrderList = <HoldCartModel>[].obs;

  var selectedOrder = 0.obs;

  var orderList = <OrderModel>[].obs;
  var ogOrderList = <OrderModel>[].obs;
  var isOfflineSelected = false.obs;
  var dateRange = "".obs;

  var _paymentMethodList= AppResposne.Response<List<Payment>>.loading(null).obs;
  List<Payment> get paymentMethodList => _paymentMethodList.value.data!;
  AppResposne.Status get paymentMethodResponseStatus => _paymentMethodList.value.status;
  String? get  paymentMethodResponseErrorMsg => _paymentMethodList.value.message;

  var _cartProducts = AppResposne.Response<List<Product>>.loading(null).obs;
  List<Product> get cartProducts => _cartProducts.value.data ?? [];
  AppResposne.Status get cartProductsResponseStatus => _cartProducts.value.status;
  int get cartCount => cartProducts.length;

  var selectedCustomer = Rxn<Customer>();
  void setCustomer(customer) {
    selectedCustomer.value = customer;
  }
  var isInvoiceOpted = false.obs;
  setInvoiceOption(bool isOpted) {
    isInvoiceOpted.value = isOpted;
  }

  //to control selected product in cart when product added or updated in the cart
  int get selectedProductIndexInCart => appController.selectedProductInCartIndex.value;
  updateSelectedProductIndexInCart(int newIndex){
    appController.selectedProductInCartIndex.value = newIndex;
  }

  @override
  void onInit() {
    Future.delayed(Duration.zero , (){
      getCartProducts();
    });
    super.onInit();
  }

  var  selectedPaymentList = <Payment>[].obs;
  var selectedPaymentIndex = (-1).obs;
    var enteredPrice = (0.0).obs;

  setEnteredPrice(double price){
    enteredPrice.value = price;
    if(selectedPaymentIndex.value >=0){
      paymentMethodList[selectedPaymentIndex.value].amountTendered = price.toString();
    }
  }

  getSelectedPaymentMethod(int index){
    selectedPaymentIndex.value = index;
    var selectedPayment =  paymentMethodList.elementAtOrNull(selectedPaymentIndex.value);
    var previousPrice = selectedPaymentList.where((p0) => p0.name == selectedPayment?.name).map((element) => double.parse((element.amountTendered ?? '0').toString())).toList();
    enteredPrice.value = previousPrice.reduce((value, element) => value+element); 
  }

  bool isPaymentInSelectedList(Payment payment){
    return selectedPaymentList.contains(payment); 
  }
 
  getTotalAmountPaidByCustomer() {
    var totalAmount = 0.0;
    selectedPaymentList.forEach((element) {
      if (element.amountTendered != null && !element.amountTendered!.isEmpty)

        totalAmount = totalAmount + double.parse(element.amountTendered!);
    });
    return totalAmount;
  }

  removeAllSelectedPaymentMethods(){
    selectedPaymentList.value = [];
    enteredPrice.value = 0.0;
  }

  setSelectedHoldedCartIndex(int index) {
    selectedHoldedCart.value = index;
  }

  setSelectedOrderIndex(int index) {
    selectedOrder.value = index; 
  }

  setDateRange(String val) {
    dateRange.value = val;
  }

  OrderModel? getSelectedOrder() {
    if (orderList.length > 0) {
      return orderList[selectedOrder.value];
    }
    return null;
  }

  void addPayment(Payment payment, int index) {
    if (selectedPaymentList.contains(payment)) return;
    selectedPaymentIndex.value = index;
    enteredPrice.value = 0.0;
    if(selectedPaymentList.isNotEmpty){
      selectedPaymentList.insert(index, payment);
    }
    else{
      selectedPaymentList.add(payment);
    }
  }

  void deletePayment(Payment payment, int index) {
    payment.amountReturned = null;
    payment.amountTendered = null;
    selectedPaymentIndex.value = index;
    selectedPaymentList.remove(payment);    
    var ind= selectedPaymentList.isNotEmpty ? paymentMethodList.indexOf(selectedPaymentList.first) : -1;
      selectedPaymentIndex.value = ind;
    if(selectedPaymentIndex > -1)
      enteredPrice.value = double.parse((paymentMethodList.elementAtOrNull(selectedPaymentIndex.value)?.amountTendered ?? 0.0).toString());
    else{
      enteredPrice.value = 0.0;
    }
  }

  setOfflineSelect(bool selected) {
    isOfflineSelected.value = selected;
    selectedOrder.value = 0;
    var filterdOrderList = ogOrderList
        .where((element) => isOfflineSelected.value
            ? element.syncStatus == "unsync"
            : element.syncStatus == "sync")
        .toList();
    orderList.value = filterdOrderList;  
  }

  getCartProducts() async {
    try {
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(productRepo: ProductRepository(apiClient: appController.apiClient , dbRepository: dbRepo));
      var products = await productUsecase.getCartProducts();
      _cartProducts.value = AppResposne.Response.completed(products);
    } on AppException catch(ex){
      log("${ex.message}");
      _cartProducts.value = AppResposne.Response.error("No product found");
    }
  }

  addProductToCart(BuildContext context ,  Product productInfo , {int qty = 1}) async{
    try{
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(productRepo: ProductRepository(dbRepository: dbRepo));

      var ncartProduct = cartProducts;
      var index = ncartProduct.indexWhere((element) => element.id == productInfo.id);
      if(index > -1){
        productInfo.unitCount = productInfo.unitCount! + qty;
          var result = await productUsecase.updateCartProduct(productInfo);
          if(result){
            ncartProduct[index] = productInfo;       
            updateSelectedProductIndexInCart(index);   
          }
      } else{
          productInfo.unitCount = qty;
          // to avoid shallow copying (updating the product data in the cart also making unwanted change to product inside product list), i have to query the db to get the original product
          var originalProductInfo = await productUsecase.getProductByIdFromDb(productInfo.id!);
          originalProductInfo?.unitCount = qty;
          if(originalProductInfo != null){
            var result = await productUsecase.addProductToCart(originalProductInfo);
            if(result){
              ncartProduct.add(originalProductInfo);
              updateSelectedProductIndexInCart(ncartProduct.length -1);
            } 
          }   
        }
      _cartProducts.value = AppResposne.Response.completed(ncartProduct); 
      await sendCartInfoToCustomerDisplayScreen(context, cartProducts, Product.calculateTotalAmountOfCartTaxExcluded(cartProducts) , Product.calculateTotalTaxAmountofCart(cartProducts, appController.taxes), appController.currencySymbol, appController.currencyPosition);
    } on AppException catch(ex){
      Helper.showSnackbar(context,  AppLocalizations.of(context)!.unable_to_add_product_to_cart);
    }  
  }

  Future<Product?> getProductFromBarcodeAndAddToCart(BuildContext context) async{
    try {
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(barcodeService: BarcodeService(), productRepo: ProductRepository(dbRepository: dbRepo));
      var productResult = await productUsecase.getProductFromBarcode("#ff6666", false);
      if(productResult != null){
        await addProductToCart(context , productResult);
      }else{
        Helper.showSnackbar(context, AppLocalizations.of(context)!.barcode_product_not_available);
      }
      return productResult;
    } on AppException catch (ex) {
      log("${ex.message}");
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.refund_error_description , color: Colors.red, prefixIcon: Icons.error_outline);
      return null;
    }
  }

  updateProductInCart(BuildContext context ,  Product product) async{
    try {
      var ncartProduct = cartProducts;
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(productRepo: ProductRepository(dbRepository: dbRepo));
      var result = await productUsecase.updateCartProduct(product);
      if(result){
        var index = ncartProduct.indexOf(product);
        if(product.unitCount == 0){
          ncartProduct.remove(product);
          updateSelectedProductIndexInCart(index == 0 ? index : index-1);

        }
        else{
          ncartProduct[index] = product;
          updateSelectedProductIndexInCart(index);
        }
        _cartProducts.value = AppResposne.Response.completed(ncartProduct);
        await sendCartInfoToCustomerDisplayScreen(
            context,
            cartProducts,
            Product.calculateTotalAmountOfCartTaxExcluded(cartProducts),
            Product.calculateTotalTaxAmountofCart(cartProducts, appController.taxes),
            appController.currencySymbol,
            appController.currencyPosition);
      }
      else{
        print("error occured update");
      }
    
    } on AppException catch(ex){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_update_product_in_cart);
    }
  }

  void removeAllProductsFromCart(BuildContext context) async{
    try{
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(productRepo: ProductRepository(dbRepository: dbRepo));
      var deleteCartResult = await productUsecase.removeAllProductsFromCart();
      if(deleteCartResult){
        _cartProducts.value = AppResposne.Response<List<Product>>.completed([]);
        selectedCustomer.value = null;
        sendCartInfoToCustomerDisplayScreen(
            context,
            cartProducts,
            Product.calculateTotalAmountOfCartTaxExcluded(cartProducts),
            Product.calculateTotalTaxAmountofCart(cartProducts, appController.taxes),
            appController.currencySymbol,
            appController.currencyPosition);
      }
    } on AppException catch (ex) {
      Helper.showSnackbar(Get.context!, AppLocalizations.of(context)!.unable_to_remove_cart);
    }
  }

  Future<List<HoldCartModel>> holdCart(BuildContext context) async{
    try {
    var orderRepo = OrderRepository(dbRepository: DBRepository(DbName: appController.dbName!));
    var orderUsecase = OrderUsecase(orderRepo: orderRepo);

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
    var dataToInsert = json.encode(HoldCartModel(formattedDate,selectedCustomer.value  , cartProducts).toJson());

    var sqlQueryToInsert = "INSERT Into ${DBRepository.HOLD_CART} (date,holdModelList) VALUES (?,?)";
    var result = await orderUsecase.holdCart(sqlQueryToInsert, [formattedDate , dataToInsert]);
    holdOrderList(result);
    removeAllProductsFromCart(context);
     return result;
    } on AppException catch (ex) {
      Helper.showSnackbar(Get.context!, AppLocalizations.of(context)!.erro_occured_please_try_again);
      return [];
    }
  }

  sendCartInfoToCustomerDisplayScreen(BuildContext context ,  List<Product> products, double totalAmount, double taxAmount, String? currencySymbol, String? currencyPosition) async {
    try {
      if(appController.customerDisplayWindowId.value != null){
        var cartInfo = jsonEncode({
        'products': products,
        'totalAmount': totalAmount,
        'totalVATAmount': taxAmount,
        'currencyPosition': currencyPosition,
        'currencySymbol' : currencySymbol
        });
        var customerUsecase = CustomerUsecase(windowService: WindowService());
        var result = await customerUsecase.sendCartInfoToCustomerDisplay(appController.customerDisplayWindowId.value!,  cartInfo);
      }
    } catch (ex) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.customer_display_sync_error_message);
    }
  }


  void fetchCartProductFromDatabase() async {
    var orderRepo = OrderRepository(dbRepository: DBRepository(DbName: appController.dbName!));
     var orderUsecase = OrderUsecase(orderRepo: orderRepo);
    var result = await orderUsecase.getHoldCarts();
    holdOrderList(result); 
  }

  Future<void> fetchOrdersFromDb(BuildContext context) async {
    try {
      var orderRepo = OrderRepository(dbRepository: DBRepository(DbName: appController.dbName!));
      var orderUsecase = OrderUsecase(orderRepo: orderRepo);
      var result = await orderUsecase.getOrdersFromDb();
      ogOrderList.value = result;
      setOfflineSelect(false);
    } on AppException catch (ex) {
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.unable_to_get_orders);
    }
  }

  void getPaymentMethodsFromDb(BuildContext context) async{
    try {
      var paymentUsecase = PaymentUsecase(paymentRepo: PaymentRepository(dbRepository: DBRepository(DbName: appController.dbName!)));
      var paymentResult = await paymentUsecase.getPaymentMethodsFromDb();
      _paymentMethodList.value = AppResposne.Response.completed(paymentResult);
    } on AppException catch (ex) {
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.unable_to_get_payment_methods);
    }
  }

  void fetchOrdersFromDbByDate(BuildContext context ,  start , int end) async {
    try {
      var orderRepo = OrderRepository(dbRepository: DBRepository(DbName: appController.dbName!));
     var orderUsecase = OrderUsecase(orderRepo: orderRepo);
    var result = await orderUsecase.getOrdersFromDbByDate(start , end);
    ogOrderList.value = result;
    setOfflineSelect(false);
    } on AppException catch (ex) {
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.unable_to_get_orders);
    }
  }

  orderSyncWithServer(BuildContext context, OrderModel orderInfo) async{
     try{
      var orderRepo = OrderRepository(apiClient: appController.apiClient, dbRepository: DBRepository(DbName: appController.dbName!));
      var orderUsecase = OrderUsecase(orderRepo: orderRepo);
      var syncWithServerMessageResult = await orderUsecase.syncOrderWithServer(orderInfo);
      fetchOrdersFromDb(context);
      if(syncWithServerMessageResult?.isNotEmpty == true){
        Helper.showSnackbar(context, syncWithServerMessageResult ?? "");
      }
     }on AppException catch (ex) {
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.order_sync_with_server_error);
    }
  }

  void removeCurrentCartHold(bool restoreToCart) async{
    if (holdOrderList.isNotEmpty){
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var orderRepo = OrderRepository(dbRepository: dbRepo);
      var orderUsecase = OrderUsecase(orderRepo: orderRepo);
      var selectedHold = holdOrderList[selectedHoldedCart.value];
      if(selectedHold.date!= null){
      var deleteResult = await orderUsecase.deleteholdCart(selectedHold.date!);
      if(deleteResult){
        holdOrderList.removeAt(selectedHoldedCart.value);
        selectedHoldedCart.value = 0;
        // restore products to the cart
        if(restoreToCart && selectedHold.products?.isNotEmpty == true){
          var productUsecase = ProductUsecase(productRepo: ProductRepository(dbRepository: dbRepo));
          var addResult = await Future.forEach(selectedHold.products!, (p) async {
            await productUsecase.addProductToCart(p);
          });
          _cartProducts.value = AppResposne.Response.completed(selectedHold.products);
        }
        refresh();
      }
     }
    }
  }

  validateAndPlaceOrder(BuildContext context) async{
    try{
    if (selectedPaymentList.length == 0) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.select_atlease_one_payment ,  color: Colors.red);
      return;
    }
    var paidAmount = getTotalAmountPaidByCustomer();
    if (Product.getTotalAmountOfCartTaxIncluded(cartProducts, appController.taxes) > paidAmount){
      Helper.showSnackbar(context, AppLocalizations.of(context)!.tendered_amount_is_less, color: Colors.red);
      return;
    }
    if(isInvoiceOpted.value && selectedCustomer.value == null){
      Helper.showAlertDialog(
        context, 
        title: AppLocalizations.of(context)!.please_select_customer, 
        description: AppLocalizations.of(context)!.select_customer_description,
        onConfirm: () async {
          var customer = await Navigator.push(context, MaterialPageRoute(builder: (context) => new CustomerSelectionPage()));
          setCustomer(customer);
        });
        return;
      }
      // wil be refactored
      DialogHelper.showProgressDialog(false);

      int? sessionId = await Helper.getDataFromPreference<int>(
          SharedPreferenceRepository.SESSION_ID);
      int lastOrderId = await Helper.getDataFromPreference<int>(
              SharedPreferenceRepository.LAST_ORDER_ID) ??
          0;
      var userId = await Helper.getDataFromPreference<int>(
          SharedPreferenceRepository.USER_ID);
      var username = userId.toString();
      int? loginNumber = await Helper.getDataFromPreference<int>(
          SharedPreferenceRepository.LOGIN_NUMBER);
      int? configId = await Helper.getDataFromPreference<int>(
          SharedPreferenceRepository.SHOP_ID);

      var tempOrderId = (lastOrderId + 1).toString();
      var tempSessionId = sessionId.toString();
      var tempLoginNumber = loginNumber.toString();

      for (var index = 0; index <= (5 - tempSessionId.length); index++) {
        tempSessionId = '0' + tempSessionId;
      }
      for (var index = 0; index <= (3 - tempLoginNumber.length); index++) {
        tempLoginNumber = '0' + tempLoginNumber;
      }
      for (var index = 0; index <= (4 - tempOrderId.length); index++) {
        tempOrderId = '0' + tempOrderId;
      }

      DateTime now = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second);
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      formattedDate = formattedDate.replaceAll(" ", "T");
      List<Map<String, dynamic>> request = [];
      List<Map<String, dynamic>> paymentList = [];
      List<Map<String, dynamic>> lineList = [];
      double totalCash = await Helper.getDataFromPreference<double>(
              SharedPreferenceRepository.TOTAL_CASH) ??
          0.0;
      double totalBank = await Helper.getDataFromPreference<double>(
              SharedPreferenceRepository.TOTAL_BANK) ??
          0.0;

      selectedPaymentList.forEach((element) {
        if (element.type == "cash") {
          totalCash +=
              element.amountTendered == null || element.amountTendered!.isEmpty
                  ? 0
                  : double.parse(element.amountTendered!);
          Helper.setDataToPreference<double>(
              SharedPreferenceRepository.TOTAL_CASH, totalCash);
          print(totalCash);
        }
        if (element.type == "bank") {
          totalBank +=
              element.amountTendered == null || element.amountTendered!.isEmpty
                  ? 0
                  : double.parse(element.amountTendered!);
          Helper.setDataToPreference<double>(
              SharedPreferenceRepository.TOTAL_BANK, totalBank);
          print(totalBank);
        }
        Map<String, dynamic> paymentMap = <String, dynamic>{
          "amount":
              element.amountTendered == null || element.amountTendered!.isEmpty
                  ? 0
                  : double.parse(element.amountTendered!),
          "payment_id": element.id,
        };
        paymentList.add(paymentMap);
        print(paymentList);
      });

      cartProducts.forEach((element) {
        Map<String, dynamic> lineMap = <String, dynamic>{
          "display_name": element.display_name,
          "product_id": element.id,
          "price_unit": element.unit_price.toString(),
          "price_subtotal":
              (double.parse(element.unit_price!) * element.unitCount!) -
                  Product.calculateDiscount(element).toInt(),
          "price_subtotal_incl": double.parse(element.unit_price!) -
              Product.calculateDiscount(element).toInt(),
          "qty": element.unitCount,
          "discount":
              element.discount != null ? double.parse(element.discount!) : 0,
          "discountAmount": Product.calculateDiscount(element),
          "id": "0",
        };
        lineList.add(lineMap);
      });
      var orderName =
          "mobi $tempSessionId $tempLoginNumber ${now.microsecondsSinceEpoch}";

    Map map = <String, dynamic>{
      "payment_method_id": paymentList,
      // "payment_ids": paymentList,
      "lines": lineList,
      "id": "$tempSessionId $tempLoginNumber ${now.microsecondsSinceEpoch}",
      "name": orderName,
      "amount_paid": getTotalAmountPaidByCustomer(),
      "amount_total": Product.getTotalAmountOfCartTaxIncluded(cartProducts, appController.taxes).toString(),
      "partner_id": selectedCustomer.value != null ? selectedCustomer.value!.id : false,
      "to_invoice": isInvoiceOpted,
      "amount_return": (getTotalAmountPaidByCustomer() - Product.getTotalAmountOfCartTaxIncluded(cartProducts, appController.taxes)),
      "creation_date": formattedDate,
      "user_id": userId,
      "username": username,
      "pricelistId": selectedPriceListId
    };
    request.add(map as Map<String, dynamic>);

      Map allMap = <String, dynamic>{
        "config_id": configId.toString(),
        "session_id": sessionId,
        "orders": request,
      };

      OrderModel model = OrderModel.fromJson(allMap as Map<String, dynamic>);
      model.customer = selectedCustomer.value;
      String? paymentName = "";
      if (selectedPaymentList.length > 1) {
        selectedPaymentList.forEach((element) {
          paymentName = element.name! + " + " + paymentName!;
        });
      } else {
        paymentName = selectedPaymentList[0].name;
      }
      model.orders[0].paymentName = paymentName;

      var orderRepo = OrderRepository(
          apiClient: appController.apiClient,
          dbRepository: DBRepository(DbName: appController.dbName!));
      var orderUsecase = OrderUsecase(orderRepo: orderRepo);
      var placeOrderResult =
          await orderUsecase.placeOrderAndSaveToDb(model, now, lastOrderId + 1);
      if (placeOrderResult) {
        removeAllProductsFromCart(context);
        selectedPaymentList.value = [];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OrderConfirmScreen(selectedCustomer.value, model),
          ),
        ); 
      }
    } catch (ex) {
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_place_order);
    } finally {
      isLoading(false);
    }

  }

  Future<void> refundProduct(BuildContext context ,  List<Line> itemsToReturn) async{
    // add product to cart with negetive price
    var dbRepo = DBRepository(DbName: appController.dbName!);
    var productUsecase = ProductUsecase(productRepo: ProductRepository(apiClient: appController.apiClient, dbRepository: dbRepo));
    await Future.forEach(itemsToReturn, (item) async {
    var productInfo = await productUsecase.getProductByIdFromDb(item.product_id!);
    if(productInfo != null){
      var returnQty = item.refunded_qty!.toInt();
      await addProductToCart(context , productInfo , qty: (-returnQty));
    }
    });
  }
}