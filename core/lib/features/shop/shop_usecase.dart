import 'dart:developer';

import 'package:hozmacore/features/shop/model/cashClose.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/payment/model/pricelistResponse.dart';
import 'package:hozmacore/features/shop/model/country.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/shop/shop_repository.dart';
import 'package:hozmacore/features/auth/user_repository.dart';
import 'package:hozmacore/shared_models/BaseModel.dart';
import 'package:hozmacore/util/helper.dart';


class ShopUsecase {
  IShopRepository shopRepo;
  IUserRepository? userRepo;
  
  ShopUsecase({required this.shopRepo, this.userRepo});

  Future<SplashResponse> getSplashInfoAndInitialize() async {
    var splashInfo = await shopRepo.getSplashInfoFromApi();

    if(splashInfo.order_prefix != null){
      await Helper.setDataToPreference<String>(SharedPreferenceRepository.ORDER_PREFIX, splashInfo.order_prefix!);
    }
    if(splashInfo.syc_order_limit != null){
      await Helper.setDataToPreference<int>(SharedPreferenceRepository.ORDER_LIMIT, splashInfo.syc_order_limit!);
    }
    return splashInfo;
  }

  Future<LoginResponse> getShopInfo() async {
    var shopResult = await shopRepo.getShopData();
    return shopResult;
  }

  Future<List<Category>> getCategoriesFromDb() async {
    var result = await shopRepo.getCategoriesFromDb();
    return result;
  }

  Future<bool> saveCountriesAndUsers(List<Country>? countries , List<User>? users) async {
    var result = false;
    if(countries?.isNotEmpty == true){
      result = await shopRepo.insertCountriesToDb(countries!);
    }
    if(users?.isNotEmpty == true){
      result = await userRepo!.insertUsersToDb(users!);
    }
    return result;
  }

  Future<CashOpen?> getShopSession(POSConfig posInfo )async {
    //save shop(pos) info
     var saveResult = await shopRepo.saveShopInfo(posInfo);
     log("$saveResult" , name: "save shop info");
    // get shop session from the api
    if(saveResult){
      var posSession = await shopRepo.getShopSessionFromApi(posInfo.id!);
      // save session to sharedpref
      var result = await shopRepo.saveSessionToSharedPreference(posSession);
      log("${posSession.toString()}  ${result}" , name: "shop session ");

    }

    // get payment method
    var payments = await shopRepo.getPaymentMethod(posInfo.id!);
    log("${payments.map((e) => e.name).toString()}" , name: "get payments");

    // save payment method to database
    var paymentMethodSaveresult = await shopRepo.insertPaymentMethodsToDb(payments);
    log("${paymentMethodSaveresult.toString()}" , name: "save payment to db");


    // get cashopen
    CashOpen? cashOpenData;
    bool isCashless = _isCashLess(payments);
    if(!isCashless){
       cashOpenData = await shopRepo.getCashOpen(posInfo.id!);
       // save shop config id to preference
      var prefSaveResult = await shopRepo.saveShopConfigToPreference(posInfo.id! , cashOpenData.success!);
      log("${cashOpenData.toString()} $prefSaveResult" , name: "get cashopen and save shop config");

    }

    //get price list from api and save to db
    var priceListResponse = await shopRepo.getPriceListFromApi(posInfo.id!);
    log("${ priceListResponse.pricelists?.map((e) => e.name.toString()).toString()} ${priceListResponse.success}" , name: "get price list");
    if (priceListResponse.success == true && priceListResponse.pricelists?.isNotEmpty == true){
      var rrr = await shopRepo.insertPriceListToDb(priceListResponse.pricelists!);
      log("$rrr" , name: "save price list to db");
    }

    // get categories from api and save to db
    _getCategoriesAndSaveToDb(posInfo.id!, 0);

    return cashOpenData;
  }

  Future<List<Payment>> getShopPaymentMethod(int shopId) async {
    var payments = await shopRepo.getPaymentMethod(shopId);
    return payments;
  }

  Future<List<PriceListItem>> getPriceListFromDatabase() async{
    var priceListResult = await shopRepo.getPriceListFromDb();
    return priceListResult;
  }

  Future<List<Country>> getCountriesFromDb() async {
    var countries = await shopRepo.getCountriesFromDb();
    return countries;
  }

  bool _isCashLess(List<Payment> payments) {
    bool is_cashless = true;
    var payments_iterator = payments.iterator;
    while (payments_iterator.moveNext()) {
      if (payments_iterator.current.type == 'cash') {
        is_cashless = false;
      }
    }
    return is_cashless;
  }

  Future<void> _getCategoriesAndSaveToDb(int id , int offset) async {
    var categoryResult = await shopRepo.getCategories(id, offset);
    if(categoryResult.pos_categories?.isNotEmpty == true){
        //ConflictAlgorithim.replace will replace rows by matching the id of the category 
        if(categoryResult.pos_categories?.isNotEmpty == true){
          await shopRepo.insertCategoriesToDb(categoryResult.pos_categories!);
        }
        _getCategoriesAndSaveToDb(id, offset+20);
      }
    
  }

  Future<CashClose> getCashCloseDataAndSaveConfigId(int id) async{
    var cashCloseResult = await shopRepo.getCashClose(id);
    await shopRepo.saveShopConfigToPreference(id, true);
    return cashCloseResult;

  }
  Future<BaseModel> setCashClose(int id , dynamic body) async{
    var cashCloseResult = await shopRepo.setCashClose(id , body);
    return cashCloseResult;
  }

  Future<BaseModel> setCashOpen(int id , dynamic body) async{
    var cashCloseResult = await shopRepo.setCashOpen(id , body);
    return cashCloseResult;
  }
}
