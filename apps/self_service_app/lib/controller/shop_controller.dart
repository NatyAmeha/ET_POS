import 'dart:convert';
import 'dart:developer';

import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/features/order/repo/product_repoisitory.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/shop/model/categoryResponse.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/payment/model/pricelistResponse.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/features/company/company_repository.dart';
import 'package:hozmacore/features/company/company_usecase.dart';
import 'package:hozmacore/shared_models/Response.dart' as NetworkReponse;
import 'package:hozmacore/datasource/db/db_repository.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/shop/shop_repository.dart';
import 'package:hozmacore/features/auth/user_repository.dart';
import 'package:hozmacore/features/auth/auth_usecase.dart';
import 'package:hozmacore/features/shop/shop_usecase.dart';
import 'package:hozmacore/features/order/usecase/product_usecase.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/utils/ui_helper.dart';

class ShopController extends GetxController {
  var appController = Get.find<AppController>();
  
  var isLoading = false.obs;
 

  var selectedShop = NetworkReponse.Response<LoginResponse>.loading(null).obs;
  POSConfig? selectedPosConfig = null;

  var productList = NetworkReponse.Response<List<Product>>.loading(null).obs;
  var selectedProductIndex = -1.obs;
  
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
  Category getSelectedCategory(){
    return categories[selectedCategory.value];
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
      appController.setDatabaseName(posInfo.id.toString());
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var shopRepo = ShopRepository(apiClient: appController.apiClient,dbRepository: dbRepo);
      var userRepo = UserRepository(dbRepository: dbRepo);
      var shopUsecase = ShopUsecase(shopRepo: shopRepo , userRepo: userRepo);
      var companyUsecase = CompanyUsecase(companyRepo: CompanyRepository(apiClient: appController.apiClient));
      
      var cashOpenData = await shopUsecase.getShopSession(posInfo);
      var paymentMethodResult = await shopUsecase.getShopPaymentMethod(posInfo.id!);

      appController.posOpeningInfo = cashOpenData;
      appController.paymentMethods = paymentMethodResult;
      var companyInfo = await companyUsecase.getCompanyInfo();
      appController.companyInfo = companyInfo;
      
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

  getProductsAndTaxes(BuildContext context) async {
    try {
      var dbRepo = DBRepository(DbName: appController.dbName!);
      var productUsecase = ProductUsecase(
          productRepo: ProductRepository(
              apiClient: appController.apiClient, dbRepository: dbRepo));
      var products = await productUsecase.getProductsAndUOM();
       var taxInfoResult = await productUsecase.getTaxes();
       appController.allProducts = products;
       appController.taxes = taxInfoResult;
       if(products.isNotEmpty){
        productList.value = NetworkReponse.Response.completed(products);
       }
       else {
        productList.value = NetworkReponse.Response.error("No product found");
       }
      
    } on AppException catch (ex) {
      productList.value = NetworkReponse.Response.error(
          ex.message ?? "Error occured, please try again");
      UiHelper.showSnackbar(
          context, ex.message ?? "Error occured, please try again");
    }
  }

  List<Product> selectProductsByCategory(List<Product>? productList) {
    if (selectedCategory == 0){
      return productList ?? [];
    } else{
      var categoryId = categories[selectedCategory.value];
      List<Product> products = productList!.where((element) {
        return element.pos_categ_id.toString() == categoryId.id.toString();
      }).toList();
      return products;
    }
  }

  bool isProductInCart(Product produtInfo){
    return appController.getProductInfoFromCart(produtInfo.id!) != null;
  }

  

  getPriceStringForProduct(Product productInfo, {bool showUnitPrice = false}){
    var price= 0.0;
    if(showUnitPrice){
      price = productInfo.calculateUnitPriceTaxIncluded(appController.taxes);
    }
    else{  
      price = productInfo.calculateFinalPriceTaxIncluded(appController.taxes);
    }
    return appController.getPriceStringWithConfiguration(price);
  }
  

}