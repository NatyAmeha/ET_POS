import 'dart:convert';
import 'dart:developer';
import 'package:hozmacore/features/order/model/holdCartModel.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';

abstract class IOrderRespository {
  Future<bool> insertHoldCart(String query , List<Object> arguments);
  Future<List<HoldCartModel>> getHoldCarts();
  Future<bool> removeCartHold(String? date);
  Future<List<OrderModel>> getOrdersFromDb();
  Future<List<OrderModel>> getOrdersFromDbByDate(int start , int end);
  Future<BaseModel> orderSyncRequest(OrderModel orderInfo);
  Future<bool> insertOrderToDb(String orderName , String orderDate  , String status , String orderContent);
  Future<bool> updateOrderInfoOnDb(String name , String status , String encodedOrderInfo);
  Future<bool> saveLastOrderIdToPreference(int orderId);
}

class OrderRepository extends IOrderRespository {
  APIEndPoint? apiClient;
  IDbRepository? dbRepository;
  ISharedPrefRepository? sharedPrefRepo;

  OrderRepository({this.apiClient, this.dbRepository, this.sharedPrefRepo = const SharedPreferenceRepository()});
  @override
  Future<List<HoldCartModel>> getHoldCarts() async {
    try {
      var result = await dbRepository!
          .getAll<Map<String, dynamic>>(DBRepository.HOLD_CART);

      return List.generate(result.length, (i) {
        var holdModelList = json.decode(result[i]["holdModelList"]);
        return HoldCartModel.fromJson(holdModelList);
      });
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }



  @override
  Future<bool> removeCartHold(String? date) async {
    try {
      var result = await dbRepository!.deleteWithFilter(DBRepository.HOLD_CART,"date",[date]);
      return result;
    } catch (ex) {
      return Future.error(ex);
    }
  }
  
  @override
  Future<bool> insertHoldCart(String query , List<Object> arguments) async{
    try {
      var result = await dbRepository!.rawInsert(query , arguments);
      return result;
    } catch (ex) {
      return Future.error(ex);
    }
  }
  
  @override
  Future<List<OrderModel>> getOrdersFromDb() async {
    try {
      var mapResult = await dbRepository!.getAll<Map<String, dynamic>>(DBRepository.ORDER_TABLE);
      var orderResult = mapResult.map((e){
        var orderData = json.decode(e["content"]);
        return OrderModel.fromJson(orderData);
      }).toList();
      return orderResult;
    } catch (ex) {
      return Future.error(ex);
    }
  }
  
  @override
  Future<List<OrderModel>> getOrdersFromDbByDate(int start, int end) async {
    try {
      var mapResult = await dbRepository!.queryWithFilter(DBRepository.ORDER_TABLE, 'creation_date >= ? AND creation_date <= ?', [start, end]);
      var orderResult = mapResult.map((e){
        var orderData = json.decode(e["content"]);
        return OrderModel.fromJson(orderData);
      }).toList();
      return orderResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<BaseModel> orderSyncRequest(OrderModel orderInfo)async {
    try {
      var orderSyncResult = await apiClient!.orderSync(json.encode(orderInfo));
      return orderSyncResult;
    } catch (ex) {
      return BaseModel(success: false);
    }
  }
  
  @override
  Future<bool> updateOrderInfoOnDb(String name, String status, String encodedOrderInfo) async {
    try {
      var sqlQuery = "UPDATE ${DBRepository.ORDER_TABLE} SET content =?, status = ? WHERE name = ?";
      var result = await dbRepository!.rawUpdate(sqlQuery , [encodedOrderInfo , status , name]);
      return result;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertOrderToDb(String orderName , String orderDate  , String status , String orderContent) async {
     try {
      var sqlQuery = "INSERT Into ${DBRepository.ORDER_TABLE} (name,creation_date,status,content) VALUES (?,?,?,?)";
      var result = await dbRepository!.rawInsert(sqlQuery , [orderName, int.parse(orderDate)  , status , orderContent]);
      return result;
    } catch (ex) {
      log("${ex.toString()}", name: "insert order error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> saveLastOrderIdToPreference(int orderId) async  {
    try {
      var result = await sharedPrefRepo!.create<bool, int>(SharedPreferenceRepository.LAST_ORDER_ID, orderId);
      return result;
    } catch (ex) {
      return Future.error(ex);
    }
  }
}
