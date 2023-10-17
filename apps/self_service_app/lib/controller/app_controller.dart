
import 'package:darq/darq.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hozmacore/datasource/api/ApiEndpoint.dart';
import 'package:hozmacore/datasource/api/custom_api_client.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/features/company/model/company.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/order/model/tax/tax.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/features/shop/shop_repository.dart';
import 'package:hozmacore/features/shop/shop_usecase.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:hozmacore/shared_models/Response.dart' as ApiResponse;
import 'package:self_service_app/const/shop_constant.dart';
import 'package:self_service_app/main.dart';
import 'package:self_service_app/ui/screens/account/login_screen.dart';
import 'package:self_service_app/ui/screens/home_screen.dart';
import 'package:self_service_app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:self_service_app/ui/screens/shop_selection_screen.dart';
import 'package:self_service_app/utils/app_config_helper.dart';
import 'package:self_service_app/utils/preference_helper.dart';
import 'package:self_service_app/utils/activity_tracker_tiimer.dart';

class AppController extends GetxController{
  APIEndPoint? apiClient;
  // initialized when shop is selected
  String? dbName;
  setDatabaseName(String posId){
    dbName = "${AppConstant.DB_PREFIX_NAME}_${posId}.db";
  }
  var isSplashApiCalled = false;
  var selectedLanguage = LanguageEnum.ENGLISH.name.obs;
  OrderOptionType? selectedOrderType = null;

  // info fetched from splash api response
  var _splashInfo = ApiResponse.Response<SplashResponse>.loading(null).obs;
  SplashResponse? get splashResponse => _splashInfo.value.data;
  ApiResponse.Status get splashResponseStatus => _splashInfo.value.status;
  String get splashResponseErrorMessage => _splashInfo.value.message ?? "";


  POSConfig? selectedPosConfig;
  String? get currencyPosition => selectedPosConfig?.currency.firstOrNull?.position ?? AppConstant.DEFAULT_CURRENCY_POSITION;
  String? get currencySymbol => selectedPosConfig?.currency.firstOrNull?.symbol ?? AppConstant.DEFAULT_CURRENCY_SYMBOL;
  
  CashOpen? posOpeningInfo;

  Company? companyInfo;

  List<Product>? allProducts = [];

  List<Tax>? taxes;
  List<Payment>? paymentMethods;
  var selectedPayment = Rxn<Payment>(null);
  selectPaymentMethod(Payment payment){
    selectedPayment.value = payment;
  }

  var selectedReceiptOption = ReceiptOptions.EMAIL.name.obs;
  changeReceiptOption(ReceiptOptions option){
    selectedReceiptOption.value = option.name;
  }

  var cart = <Product>[].obs;
  double get cartTotalAmount => cart.sum((item) => item.calculateFinalPriceTaxIncluded(taxes));
  String get getTotalAmountInfoOfCartTaxIncluded{
    return getPriceStringWithConfiguration(Product.getTotalAmountOfCartTaxIncluded(cart, taxes));
  }

  String get getSubtotalAmountInfoOfCart{
    return getPriceStringWithConfiguration(Product.calculateTotalAmountOfCartTaxExcluded(cart));
  }

  String get getTotalTaxInfoOfCart{
    return getPriceStringWithConfiguration(Product.calculateTotalTaxAmountofCart(cart, taxes));
  }

  
  
  var timeToCompleteOrder = Duration(seconds: AppConstant.MAX_TIME_FOR_INACTIVITY_IN_SECOND).obs;
  late ActivityTrackerTimer activityTrackerTimer;
  

  @override
  void onInit() async {
    super.onInit();
    apiClient = await CustomApiClient.getClient();
    activityTrackerTimer = ActivityTrackerTimer(
      timeToCompleteOrderInSecond: AppConstant.MAX_TIME_FOR_INACTIVITY_IN_SECOND,
       timeToShowTrackerDialogInSecond: AppConstant.TIME_TO_SHOW_INACTIVITY_DIALOG,
    );
  }

  changeLanguage(BuildContext context ,  LanguageEnum selectedLanguageType){
    var newSelectedLocal = AppConfigHelper.getSelectedLocal(selectedLanguageType.name);
    selectedLanguage.value = selectedLanguageType.name;
    MyApp.setLocale(context, newSelectedLocal);
  }

  getSplashInfo(BuildContext context) async {
    try {
      var isLoggedIn = await PreferenceHelper.getDataFromPreference<bool>(ShopConstant.D_IS_LOGGED) ??false;
      if (isLoggedIn == true) {
        var shopUsecase =
            ShopUsecase(shopRepo: ShopRepository(apiClient: apiClient));
        var splashInfoResult = await shopUsecase.getSplashInfoAndInitialize();
        isSplashApiCalled = true;
        if (splashInfoResult.success == true) {
          _splashInfo.value = ApiResponse.Response.completed(splashInfoResult);
        } else {
          _splashInfo.value =
              ApiResponse.Response.error(splashInfoResult.message);
        }
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => ShopSelectionScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } on AppException catch (ex) {
      _splashInfo.value = ApiResponse.Response.error(
          "Error occured, please try again later. Make sure internet connection is stable");
    }
  }

  selectOrderOption(BuildContext context,  OrderOptionType type){
    selectedOrderType = type;
    Navigator.of(context).push( MaterialPageRoute(builder: (c) => HomeScreen()));
  }

  Product? getProductInfoFromCart(int productId) {
    var index = cart.indexWhere((element) => element.id == productId);
    if (index > -1) {
      return cart[index];
    } else {
      return null;
    }
  }

  resetAppStatusAfterInactivity(BuildContext timerContext){
    cart.value = [];
    selectedPayment.value =null;
    timeToCompleteOrder.value = Duration(seconds: activityTrackerTimer.savedTimeToCompleteOrder);
    Navigator.of(timerContext).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
      (Route<dynamic> route) => false,
    );
  }

  initializedTimerContext(BuildContext context){
    activityTrackerTimer.initializedTimerContext(context);
  }


  startTimerForActivityTracking(){
    activityTrackerTimer.startTimerToShowActivityDialog(onTimeTick: (remainingSeconds) {
        timeToCompleteOrder.value = Duration(seconds: remainingSeconds);
    }, onTimerCanceled: (timerContext){
      resetAppStatusAfterInactivity(timerContext);
    });
  }

  

  restartTimer(){
    activityTrackerTimer.restartTimer(
      onTimeTick: (remainingSeconds) {
        timeToCompleteOrder.value = Duration(seconds: remainingSeconds);
      },
      onTimerCanceled: (timerContext){
        resetAppStatusAfterInactivity(timerContext);
      },
    );
  }
  

  String getPriceStringWithConfiguration(double price){
     return currencyPosition == "before"
                    ? "$currencySymbol ${price.toStringAsFixed(2)}"
                    : "${price.toStringAsFixed(2)} $currencySymbol";

  }
}