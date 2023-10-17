
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/datasource/api/custom_api_client.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/ui/screens/shop_selection_screen.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/features/auth/user_repository.dart';
import 'package:hozmacore/features/auth/auth_usecase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
        var saveLoginStatusToPref = await Helper.setDataToPreference<bool>(SharedPreferenceRepository.D_IS_LOGGED, true);
        // call the splash the api if not called on app start
        if(appController.isSplashApiCalled == false){
          await appController.getSplashInfo(context);
        }
        else{
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  ShopSelectionScreen()));
        }
      }  
    } on AppException catch (ex ) { 
      Helper.showSnackbar(context, ex.message ?? AppLocalizations.of(context)!.erro_occured_please_try_again , color: Colors.red);   
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