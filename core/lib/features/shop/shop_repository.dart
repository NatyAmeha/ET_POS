import 'dart:convert';
import 'dart:developer';

import 'package:hozmacore/constants/constants.dart';
import 'package:hozmacore/features/shop/model/cashClose.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';

import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/payment/model/pricelistResponse.dart';
import 'package:hozmacore/features/shop/model/country.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';
import 'package:hozmacore/shared_models/session.dart';

abstract class IShopRepository{
  Future<LoginResponse> getShopData();
  Future<Session> getShopSessionFromApi(int shopId);
  Future<bool> saveSessionToSharedPreference(Session sessionInfo);
  Future<bool> saveShopInfo(POSConfig posInfo);
  Future<CashOpen> getCashOpen(int shopId);
  Future<CashClose> getCashClose(int shopId);
  Future<BaseModel> setCashOpen(int shopId , dynamic body);
  Future<BaseModel> setCashClose(int shopId , dynamic body);
  Future<List<Payment>> getPaymentMethod(int shopId);
  Future<bool> insertPaymentMethodsToDb(List<Payment> payments);

  Future<bool> saveShopConfigToPreference(int shopId , bool isAppOpened);

  Future<PriceListResponse> getPriceListFromApi(int shopId);
  Future<bool> insertPriceListToDb(List<PriceListItem> priceLists);
  Future<CategoryResponse> getCategories(int shopId , int offset);
  Future<List<Category>> getCategoriesFromDb();
  Future<bool> insertCategoriesToDb(List<Category> categories);
  Future<List<PriceListItem>> getPriceListFromDb();
  Future<SplashResponse> getSplashInfoFromApi();
  Future<bool> insertCountriesToDb(List<Country> countries);
  Future<List<Country>> getCountriesFromDb();
}

class ShopRepository extends IShopRepository{
  APIEndPoint? apiClient;
  IDbRepository? dbRepository;
  ISharedPrefRepository? sharedPrefRepo;

  ShopRepository({this.apiClient, this.dbRepository, this.sharedPrefRepo = const SharedPreferenceRepository()});

  static const SESSION_ALREADY_OPENED_ERROR_MESSAGE = "Session is already Opened. You can't set opening balance of opened session";


  @override
  Future<LoginResponse> getShopData() async{
    try{
       var shopResult = await apiClient!.shopData();
       if(shopResult.success ==false){
        return Future.error(AppException(message: shopResult.message , statusCode: shopResult.responseCode));
      }
       return shopResult;
    }catch(ex){
       return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<Session> getShopSessionFromApi(int shopId) async{
    try{
       var shopSessionResult = await apiClient!.shopSession(shopId.toString());
       if(shopSessionResult.success ==false){
        return Future.error(AppException(message: shopSessionResult.message , statusCode: shopSessionResult.responseCode));
      }
       return shopSessionResult;
    }catch(ex){
       return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> saveShopInfo(POSConfig posInfo) async {
    try {
       await sharedPrefRepo!.create<bool , String>(SharedPreferenceRepository.SHOP_NAME, posInfo.name!);
       await sharedPrefRepo!.create<bool , int>(SharedPreferenceRepository.SHOP_ID, posInfo.id!);
       await sharedPrefRepo!.create<bool , String>(SharedPreferenceRepository.CURRENCY_SYMBOL, posInfo.currency[0].symbol!);
       await sharedPrefRepo!.create<bool , String>(SharedPreferenceRepository.CURRENCY_POSTION, posInfo.currency[0].position!);
       await sharedPrefRepo!.create<bool , int>(SharedPreferenceRepository.CURRENCY_SYMBOL, posInfo.currency[0].decimal_places!);
       return true;
    } catch (e) {
       return Future.error(AppException(type: AppException.PREFERENCE_STORAGE_EXCEPTION, message: "Unable to save shop info to preference"));
    }
  }
  
  @override
  Future<List<Payment>> getPaymentMethod(int shopId) async {
    try {
      var paymentResult = await apiClient!.payments(shopId.toString());
      if(paymentResult.success ==false ){
        return Future.error(AppException(message: paymentResult.message , statusCode: paymentResult.responseCode));
      }
      else if(paymentResult.success == true && paymentResult.payments?.isNotEmpty == true){
         return paymentResult.payments!;
      }
      else{
         return <Payment>[];
      }
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<CashOpen> getCashOpen(int shopId) async {
    try {
      var cashOpenResult = await apiClient!.getCashOpen(shopId.toString());
      if(cashOpenResult.success ==false ){
        if(cashOpenResult.message == SESSION_ALREADY_OPENED_ERROR_MESSAGE){
          return cashOpenResult;
        }
        else {
          return Future.error(AppException(message: cashOpenResult.message , type: AppException.UNKNOWN_API__EXCEPTION));
        }

      }
      return cashOpenResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<CashClose> getCashClose(int shopId) async {
    try {
      var cashCloseResult = await apiClient!.getCashClose(shopId.toString());
      if(cashCloseResult.success ==false ){
          return Future.error(AppException(message: cashCloseResult.message , type: AppException.UNKNOWN_API__EXCEPTION));

      }
      return cashCloseResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<BaseModel> setCashOpen(int shopId , dynamic body) async {
   try {
      var cashOpenResult = await apiClient!.setCashOpen(shopId.toString() , body);
      return cashOpenResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }

  @override
  Future<BaseModel> setCashClose(int shopId , dynamic body) async {
   try {
      var cashCloseResult = await apiClient!.setCashClose(shopId.toString() , body);
      return cashCloseResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> saveShopConfigToPreference(int shopId , bool isAppOpened) async {
     try {
       await sharedPrefRepo!.create<bool , int>(SharedPreferenceRepository.CONFIG_ID, shopId);
       await sharedPrefRepo!.create<bool , bool>(SharedPreferenceRepository.APP_OPENED, isAppOpened);
       return true;
    } catch (e) {
       return Future.error(AppException(type: AppException.PREFERENCE_STORAGE_EXCEPTION, message: "Unable to save shop config to preference"));
    }
  }
  
  @override
  Future<CategoryResponse> getCategories(int shopId, int offset) async {
    try {
      var categoryResult = await apiClient!.getCategories(shopId.toString() , offset.toString() , "20");
      if(categoryResult.success ==false ){
        return Future.error(AppException(message: categoryResult.message , statusCode: categoryResult.responseCode , type: AppException.UNKNOWN_API__EXCEPTION));
      }
      return categoryResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> saveSessionToSharedPreference(Session sessionInfo) async {
    try {
      await sharedPrefRepo!.create<bool , int>(SharedPreferenceRepository.SESSION_ID, sessionInfo.session_id!);
      await sharedPrefRepo!.create<bool , int>(SharedPreferenceRepository.LOGIN_NUMBER, sessionInfo.login_number!);
      return true;
    } catch (ex) {
      return Future.error(AppException(type: AppException.PREFERENCE_STORAGE_EXCEPTION, message: "Unable to save session info to preference"));
    }
  }
  
  @override
  Future<bool> insertPaymentMethodsToDb(List<Payment> payments) async {
    try {
      await Future.forEach(payments, (payment)async{
        //insert data to database
        await dbRepository!.create<int , Payment>(DBRepository.PAYMENT_TABLE, payment);
      });
      return true;
       
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
   
  }
  
  @override
  Future<PriceListResponse> getPriceListFromApi(int shopId) async{
    try {
      var priceListResult = await apiClient!.getPriceListData(shopId.toString() );
      if(priceListResult.success ==false ){
        return Future.error(AppException(message: priceListResult.message , statusCode: priceListResult.responseCode , type: AppException.UNKNOWN_API__EXCEPTION));
      }
      return priceListResult;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertPriceListToDb(List<PriceListItem> priceLists) async {
    try {
      await Future.forEach(priceLists, (pricelist)async{
        //insert data to database
        await dbRepository!.create<int , PriceListItem>(DBRepository.PRICELIST_TABLE, pricelist);
      });
      return true;
       
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertCategoriesToDb(List<Category> categories) async{
    try {
      await Future.forEach(categories, (category)async{
        //insert data to database
        await dbRepository!.create<int , Category>(DBRepository.CATEGORY_TABLE, category);
      });
      return true;
       
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<List<PriceListItem>> getPriceListFromDb() async{
    try {
      var result = await dbRepository!.getAll<Map<String, dynamic>>(DBRepository.PRICELIST_TABLE);
      // Manual conversion to pricelist_item is required the 'List<dynamic> data' field inside the class is stored to db in json format
      // it must be decoded from json to list manually
      return List.generate(result.length, (i) {
        var id = result[i]["id"];
        var name = result[i]["name"];
        var list = json.decode(result[i]["data"]);
        return PriceListItem(
            id,
            name,
            List.generate(list.length, (index) => PricelistData.fromJson(list[i])));
      });
      
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));

    }
  }

  @override
  Future<List<Category>> getCategoriesFromDb() async{
    try{
       var mapResult = await dbRepository!.getAll<Map<String,dynamic>>(DBRepository.CATEGORY_TABLE);
       var categoryResult = mapResult.map((e) => Category.fromJson(e)).toList();
       return categoryResult;
    }catch (ex) {
      log("${ex.toString()}" , name: "get categories from db error");
      return Future.error(AppException().identifyErrorType(ex));

    }
  }
  
  @override
  Future<SplashResponse> getSplashInfoFromApi() async {
    try {
      var splashInfo = await apiClient!.splashData();
      return splashInfo;
    } catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<bool> insertCountriesToDb(List<Country> countries) async {
    try{
      await Future.forEach(countries, (country)async{
        await dbRepository!.create<int , Country>(DBRepository.COUNTRY_TABLE, country , queryParameters: {Constant.DB_CONFLICT_ALOGRITHIM_TYPE : DbConflictAlgorithim.IGNORE.name});
      });
      return true;
    }catch (ex) {
      log("${ex.toString()}" , name: "insert users to db error");
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
  
  @override
  Future<List<Country>> getCountriesFromDb() async {
     try{
      var mapResult = await dbRepository!.getAll<Map<String,dynamic>>(DBRepository.COUNTRY_TABLE);
      var countryResult = mapResult.map((e) => Country.fromJson(e)).toList();
      return countryResult;
    }catch (ex) {
      return Future.error(AppException().identifyErrorType(ex));
    }
  }
}