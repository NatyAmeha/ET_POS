import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/repo/order_repository.dart';
import 'package:hozmacore/features/order/usecase/order_usecase.dart';
import 'package:intl/intl.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/const/shop_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/utils/preference_helper.dart';
import 'package:self_service_app/utils/ui_helper.dart';

class OrderController extends GetxController{
  var appController = Get.find<AppController>();

  // info used for order placement
  String? userName = null;
  String? email = null;
  String? phoneNumber = null;
  int orderCounter = 0;

  int addToCart(BuildContext context, Product product, {int qty = 1}) {
    var newCart = [...appController.cart];
    var index = newCart.indexWhere((element) => element.id == product.id);
    if (index > -1) {
      if (qty >= 1) {
        product.unitCount = qty;
        newCart[index] = product;
      }
    } else {
      product.unitCount = qty;
      newCart.add(product);
      index = newCart.length - 1;
    }
    appController.cart.value = newCart;
    return index;
  }

  removeFromCart(BuildContext context, Product productInfo) {
    var newCart = [...appController.cart];
    var index =
        newCart.indexWhere((cartProduct) => cartProduct.id == productInfo.id);
    print("index to delete $index");
    if (index > -1) {
      newCart.removeAt(index);
    }
    appController.cart.value = newCart;
  }

  Future<bool> placeOrder(BuildContext context) async {
    try {
      int? sessionId = await PreferenceHelper.getDataFromPreference<int>(
          SharedPreferenceRepository.SESSION_ID);
      orderCounter = await PreferenceHelper.getDataFromPreference<int>(
              SharedPreferenceRepository.LAST_ORDER_ID) ??
          0;
      orderCounter = orderCounter + 1;

      int? configId = await PreferenceHelper.getDataFromPreference<int>(
          SharedPreferenceRepository.SHOP_ID);

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(now);
      formattedDate = formattedDate.replaceAll(" ", "T");
      List<Map<String, dynamic>> request = [];
      List<Map<String, dynamic>> lineList = [];

      appController.cart.forEach((element) {
        Map<String, dynamic> lineMap = <String, dynamic>{
          "display_name": element.display_name,
          "product_id": element.id,
          "price_unit": element.unit_price.toString(),
          "price_subtotal": element.calculateFinalPriceTaxExcluded(),
          "price_subtotal_incl": element.calculateFinalPriceTaxIncluded(appController.taxes),
          "qty": element.unitCount,
          "discount":
              element.discount != null ? double.parse(element.discount!) : 0,
          "discountAmount": Product.calculateDiscount(element),
          "id": "0",
        };
        lineList.add(lineMap);
      });
      var orderName = "mobi $sessionId ${now.microsecondsSinceEpoch}";
      
      Map<String, dynamic> paymentMethodInfoMap =  <String, dynamic>{
          "amount": appController.cartTotalAmount,
          "payment_id": appController.selectedPayment.value?.id,
        };
      Map map = <String, dynamic>{
        "payment_method_id": [paymentMethodInfoMap],
        "lines": lineList,
        "id": "$sessionId ${now.microsecondsSinceEpoch}",
        "name": orderName,
        "amount_paid": appController.cartTotalAmount,
        "amount_return": 0,
        "amount_total":
            Product.getTotalAmountOfCartTaxIncluded(appController.cart, appController.taxes).toString(),
        "creation_date": formattedDate,
        "username": userName,
      };
      request.add(map as Map<String, dynamic>);

      Map allMap = <String, dynamic>{
        "config_id": configId.toString(),
        "session_id": sessionId,
        "orders": request,
      };
      print("tab one $allMap");

      var model = OrderModel.fromJson(allMap as Map<String, dynamic>);
      model.orders[0].paymentName = appController.selectedPayment.value?.name ?? ShopConstant.SHOP_PAYMENT_METHOD_CASH;
      var orderRepo = OrderRepository(apiClient: appController.apiClient);
      var orderUsecase = OrderUsecase(orderRepo: orderRepo);
      var placeOrderResult =
          await orderUsecase.placeOrderToApi(model, now, orderCounter);
      if (placeOrderResult) {
        appController.cart.value = [];
        appController. selectedPayment.value = null;
        if (appController.selectedReceiptOption.value == ReceiptOptions.PRINTED.name) {
          // call print feature here
        }
        appController.selectedReceiptOption.value = ReceiptOptions.EMAIL.name;
        return true;
      } else {
        return false;
      }
    } catch (ex) {
      print("order exception ${ex.toString()}");
      UiHelper.showSnackbar(context, "Unable to place order");
      return false;
    }
  }
}