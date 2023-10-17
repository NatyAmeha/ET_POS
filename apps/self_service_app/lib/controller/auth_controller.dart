
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/datasource/api/custom_api_client.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/auth/user_repository.dart';
import 'package:hozmacore/features/auth/auth_usecase.dart';
import 'package:self_service_app/const/shop_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/ui/screens/shop_selection_screen.dart';
import 'package:self_service_app/utils/preference_helper.dart';
import 'package:self_service_app/utils/ui_helper.dart';


class AuthController extends GetxController{
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  var appController= Get.find<AppController>();

  changeDataloading(bool load) {
    _isLoading(load);
  }
 
   login(String email, String password , String workspace , BuildContext context) async {
    try {
      changeDataloading(true);
      var authUsecase = AuthUsecase(userRepository: UserRepository(sharedPrefRepository: SharedPreferenceRepository()));
      var loginResult = await authUsecase.login(email, password , workspace); 
      if(loginResult.success == true){
        // reinitialize the apiclient with proper workspace url
        appController.apiClient = await CustomApiClient.getClient();
        await PreferenceHelper.setDataToPreference<bool>(ShopConstant.D_IS_LOGGED, true);
        // call the splash api if not called on app start
        if(appController.isSplashApiCalled == false){
          await appController.getSplashInfo(context);
        }
        else{
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  ShopSelectionScreen()));
        }
      }  
    } on AppException catch (ex ) { 
      UiHelper.showSnackbar(context, ex.message ?? "Something went wrong" , color: Colors.red);   
    } finally {
      changeDataloading(false);
    }
  }

  Future<String?> getWorkspaceUrl() async {
     try {
       var authUsecase = AuthUsecase(userRepository: UserRepository());
       var workspaceUrl = await authUsecase.getWorkspaceUrl();
       return workspaceUrl;
     } on AppException catch (ex) {
       print("${ex.message}");
     }
  }

  Future<void> logout() async {
    try {
       var authUsecase = AuthUsecase(userRepository: UserRepository());
       await authUsecase.logout();
     } on AppException catch (ex) {
       print("Unable to logout");
     }
  }
}