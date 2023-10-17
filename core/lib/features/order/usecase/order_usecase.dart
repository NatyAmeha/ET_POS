import 'dart:convert';

import 'package:hozmacore/features/order/model/holdCartModel.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/features/order/repo/order_repository.dart';

class OrderUsecase {
  IOrderRespository orderRepo;

  OrderUsecase({required this.orderRepo});

  Future<List<HoldCartModel>> getHoldCarts() async {
    var result = await orderRepo.getHoldCarts();
    return result;
  }

  Future<List<OrderModel>> getOrdersFromDb() async {
    var result = await orderRepo.getOrdersFromDb();
    return result;
  }

  Future<List<OrderModel>> getOrdersFromDbByDate(int start , int end) async {
    var result = await orderRepo.getOrdersFromDbByDate(start, end);
    return result;
  }

  Future<List<HoldCartModel>> holdCart(String query , List<Object> arguments) async{
    var insertResult = await orderRepo.insertHoldCart(query, arguments);
    if(insertResult){
      var holdCartResult = await getHoldCarts();
      return holdCartResult;
    }
    return [];
  }

  Future<bool> deleteholdCart(String date) async {
    var result = await orderRepo.removeCartHold(date);
    return result;
  }

  Future<bool> placeOrderAndSaveToDb(OrderModel orderInfo , DateTime dateCreated, int orderId) async {
    var date = dateCreated.microsecondsSinceEpoch.toString();
     var orderRequestResult = await orderRepo.orderSyncRequest(orderInfo);
     if(orderRequestResult.success == true){
      orderInfo.syncStatus = "sync";
     } else{
      orderInfo.syncStatus = "unsync";
     }
     var result = await orderRepo.insertOrderToDb(orderInfo.orders[0].name!, date ,  orderInfo.syncStatus!, json.encode(orderInfo.toJson()));
     await orderRepo.saveLastOrderIdToPreference(orderId);
     return result;
  }

  Future<bool> placeOrderToApi(OrderModel orderInfo , DateTime dateCreated, int orderId) async {
     var orderRequestResult = await orderRepo.orderSyncRequest(orderInfo);
     if(orderRequestResult.success == true){
      await orderRepo.saveLastOrderIdToPreference(orderId);
      orderInfo.syncStatus = "sync";
      return true;
     } else{
      return false;
     }
  }

  Future<String?> syncOrderWithServer(OrderModel orderInfo) async{
    var syncWithServerResult = await orderRepo.orderSyncRequest(orderInfo);
    if(syncWithServerResult.success == true){
      orderInfo.syncStatus = "sync";
      await orderRepo.updateOrderInfoOnDb(orderInfo.orders[0].name!, "sync", json.encode(orderInfo.toJson()));
    }else{
      orderInfo.syncStatus = "unsync";
      await orderRepo.updateOrderInfoOnDb(orderInfo.orders[0].name!, "unsync", json.encode(orderInfo.toJson()));
    }
    return syncWithServerResult.message;
  }
}
