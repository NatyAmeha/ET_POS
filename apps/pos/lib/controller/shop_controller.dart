import 'dart:convert';
import 'dart:developer';

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/ui/screens/shop_selection_screen.dart';
import 'package:odoo_pos/utils.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/payment/model/pricelistResponse.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/features/company/company_repository.dart';
import 'package:hozmacore/features/company/company_usecase.dart';
import 'package:hozmacore/shared_models/Response.dart' as NetworkReponse;
import 'package:hozmacore/features/customer/customer_repository.dart';
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/features/order/repo/product_repoisitory.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/shop/shop_repository.dart';
import 'package:hozmacore/features/auth/user_repository.dart';
import 'package:hozmacore/features/auth/auth_usecase.dart';
import 'package:hozmacore/features/customer/customer_usecase.dart';
import 'package:hozmacore/features/order/usecase/product_usecase.dart';
import 'package:hozmacore/features/shop/shop_usecase.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class ShopController extends GetxController {
  var appController = Get.find<AppController>();
  
  // to track loading state when async operation takes place
  var isLoading = false.obs;

  var selectedShop = NetworkReponse.Response<LoginResponse>.loading(null).obs;
  POSConfig? selectedPosConfig = null;

  var productList = NetworkReponse.Response<List<Product>>.loading(null).obs;
  var searchedProductList = <Product>[].obs;

  var _categories = <Category>[Category(-1, "All Products", "parent_id", 0)].obs;
  var selectedCategory = 0.obs;
  List<Category> get  categories{
    return _categories.distinct((e) => e.id!).toList();
  }

  var priceLists = <PriceListItem?>[].obs;
  int selectedPriceList = 0;

  var _agentInfo = NetworkReponse.Response<LoginResponse>.loading(null).obs;
  LoginResponse get agentInfo => _agentInfo.value.data!;
  NetworkReponse.Status get agentInfoStatus => _agentInfo.value.status;

  var _cashiers = <User>[].obs;
  List<User> get cashiersList => _cashiers.value;
  
  Rx<User?> _selectedCashier = null.obs;
  User? get selectedCashier => _selectedCashier.value;


  setSelectedCategory(int index) {
    selectedCategory.value =index;
  }

  setSelectedPriceItem(PriceListItem? item) {
    selectedPriceList = priceLists.indexOf(item); 
    refresh();   
  }

  setSelectedUser(User? user){
   _selectedCashier.value = user;
  }

  PriceListItem? getSelectedPriceListItem() {
    if (priceLists.length > 0)
      return priceLists[selectedPriceList];
    else{
      return null;
    }
  }

  //to control selected product in cart when product added or updated in the cart
  int get selectedProductIndexInCart => appController.selectedProductInCartIndex.value;
  updateSelectedProductIndexInCart(int newIndex){
    appController.selectedProductInCartIndex.value = newIndex;
  }


  getShopInfo() async {
    try {
      selectedShop(NetworkReponse.Response.loading(null));
      var shopUsecase = ShopUsecase(shopRepo: ShopRepository(apiClient: appController.apiClient));
      var shopResult = await shopUsecase.getShopInfo();
      selectedShop(NetworkReponse.Response.completed(shopResult));

      // save agent data to db
      var authUsecase = AuthUsecase(userRepository: UserRepository(sharedPrefRepository: SharedPreferenceRepository()));
      await authUsecase.saveAgentInfo(shopResult);

    } on AppException catch (ex) {
      selectedShop(NetworkReponse.Response.error(ex.message));
    }
  }

  Future<CashOpen?> saveShopInfoAndGetSession(POSConfig posInfo, BuildContext context) async {
    try {
      isLoading(true);
      selectedPosConfig = posInfo;
      appController.selectedPosConfig = selectedPosConfig;
      appController.dbName = "pos_profile" + posInfo.id.toString() + ".db";
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var shopRepo = ShopRepository(apiClient: appController.apiClient,dbRepository: dbRepo);
      var userRepo = UserRepository(dbRepository: dbRepo);
      var shopUsecase = ShopUsecase(shopRepo: shopRepo , userRepo: userRepo);
      var companyUsecase = CompanyUsecase(companyRepo: CompanyRepository(apiClient: appController.apiClient));
      
      var cashOpenData = await shopUsecase.getShopSession(posInfo);
      appController.posOpeningInfo = cashOpenData;

      var companyInfo = await companyUsecase.getCompanyInfo();
      appController.companResponse = companyInfo;
      
      // save countries and users fetched from splash response
      await shopUsecase.saveCountriesAndUsers(appController.splashResponse?.allCountries, appController.splashResponse?.users);

      // get categories from db
      var categoryResults = await shopUsecase.getCategoriesFromDb();

      _categories.addAll(categoryResults);
      setSelectedCategory(0);

      // get price list from database
      var priceListResult = await shopUsecase.getPriceListFromDatabase();
      priceLists(priceListResult);
      return cashOpenData;
    } catch (e) {
      // will be catched in on resume button clicked
      rethrow;
    } finally{
      isLoading(false);
    }
  }

  Future<int?> setOpeningBalanceForNewSession(CashOpen? cashOpenData , BuildContext context) async{
     try {
      isLoading(true);
      var isOpened = await Helper.getDataFromPreference<bool>(SharedPreferenceRepository.APP_OPENED);
      var shopId = await Helper.getDataFromPreference<int>(SharedPreferenceRepository.CONFIG_ID);
      if (shopId != null && cashOpenData?.success! == true && isOpened == true) {
          DialogHelper.openingBalanceDialog(context, cashOpenData!,
              onConfirm: (Map<String, dynamic> req) async {
            var shopUsecase = ShopUsecase(shopRepo: ShopRepository(apiClient: appController.apiClient,sharedPrefRepo: SharedPreferenceRepository()));
            var response = await shopUsecase.setCashOpen(shopId, json.encode(req));
            // this will remove the cash open dialog
            Helper.showSnackbar(context, response.message!);
            if (response.success!) {
              Helper.setDataToPreference(SharedPreferenceRepository.APP_OPENED, false);              
            }
          });
      }  
       return shopId; 
     } on AppException catch (ex) {
       Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.erro_occured_please_try_again);
       return null;
     } finally{
        isLoading(false);
     }
  }

  getProductsAndTaxes(BuildContext context) async{
    try{
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(productRepo: ProductRepository(apiClient: appController.apiClient , dbRepository: dbRepo));
      var products = await productUsecase.getProductsAndUOM();
      productList.value = NetworkReponse.Response.completed(products);
      appController.allProducts = products;
      await appController.getTaxInfo();

    } on AppException catch (ex) {
      productList.value = NetworkReponse.Response.error(ex.message ?? AppLocalizations.of(context)!.erro_occured_please_try_again);
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.erro_occured_please_try_again);
    }
  }

  searchProducts(String productName ,  BuildContext context) async {
    try{
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(productRepo: ProductRepository( dbRepository: dbRepo));
      var searchResult = await productUsecase.searchProducts(productName);
      if(searchResult.isNotEmpty){
        searchedProductList.value= searchResult;
      }
      else{
        searchedProductList.value= [];
      }
    } on AppException catch (ex) {
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.erro_occured_please_try_again);
    }
  }

  getCustomersFromApiAndSaveToDb(BuildContext context) async{
    try{
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var customerUsecase = CustomerUsecase(customerRepo: CustomerRepository(apiClient: appController.apiClient!, dbRepository: dbRepo));
      await customerUsecase.getCustomersFromApiAndInsertToDb(0 , 20);
    } on AppException catch (ex) {
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.erro_occured_please_try_again);
    }
  }

  closeShop(int id , BuildContext context) async{
    try {
      isLoading(true);
      var shopUsecase = ShopUsecase(shopRepo: ShopRepository(apiClient: appController.apiClient,sharedPrefRepo: SharedPreferenceRepository()));
      var cashCloseResult = await shopUsecase.getCashCloseDataAndSaveConfigId(id);
      DialogHelper.closingBalanceDialog(context, cashCloseResult,
                  onConfirm: (Map<String, dynamic> req) async {
          var response = await shopUsecase.setCashClose(id, json.encode(req));
          Helper.showSnackbar(context, response.message!);      
                if (response.success!) {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => ShopSelectionScreen()),
                      (Route<dynamic> route) => false);
                }
              }, onOpen: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => ShopSelectionScreen()),
                    (Route<dynamic> route) => false);
              });
      
      
    } on AppException catch (ex) {
      log("${ex.message}");
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_close_session);
    } finally{
      isLoading(false);
    }
  }

  getAgentInfo(BuildContext context) async{
    try {
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var authUsecase = AuthUsecase(userRepository: UserRepository(dbRepository: dbRepo));
      var agentResult = await authUsecase.getAgentInfo();
      _agentInfo.value = NetworkReponse.Response.completed(agentResult);
      var cashiersResult = await authUsecase.getCashiersFromDb();
      if(cashiersResult.isNotEmpty == true){
      _selectedCashier.value = cashiersResult[0]; 
      }
      _cashiers.value = cashiersResult;
    } on AppException catch (ex) {
      log("${ex.message}");
      Helper.showSnackbar(context, AppLocalizations.of(context)!.unable_to_get_user_info);
    }
  }
}