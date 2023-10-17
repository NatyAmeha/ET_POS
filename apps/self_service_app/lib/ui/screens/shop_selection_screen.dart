import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/shared_models/Response.dart';
import 'package:self_service_app/controller/auth_controller.dart';
import 'package:self_service_app/controller/shop_controller.dart';
import 'package:self_service_app/ui/screens/account/login_screen.dart';
import 'package:self_service_app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:self_service_app/ui/widgets/shop_selection_list_tile.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';
import 'package:self_service_app/utils/ui_helper.dart';

class ShopSelectionScreen extends StatefulWidget {
  @override
  State<ShopSelectionScreen> createState() => _ShopSelectionScreenState();
}

class _ShopSelectionScreenState extends State<ShopSelectionScreen> {

  var shopController = Get.put(ShopController());
  var authController = Get.put(AuthController());

  CashOpen? cashOpenData;


  getShopInfo(){
    Future.delayed(Duration.zero , (){
      shopController.getShopInfo();
    });
  }

  @override
  void initState() {
    getShopInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Company name"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                UiHelper.showAlertDialog(context, title: "Logout", description: "Do you want to logout from the app?", onConfirm: () async {
                  await authController.logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              },
              tooltip: "Logout",
            )
          ],
        ),
        body:  Obx((){
          return UiHelper.displayContent(
            canShow: shopController.selectedShop.value.status == Status.COMPLETED, 
            isLoading: shopController.selectedShop.value.status == Status.LOADING || shopController.isLoading.value,
            content: buildUI(shopController.selectedShop.value.data, context), 
            errorMessage: shopController.selectedShop.value.message,
            onTryAgain: (){
              getShopInfo();
            }
          );
        }
      )
    );
  }

  buildUI(LoginResponse? response, BuildContext context) {
    if (response == null) return UiHelper.showErrorMessage("Unable to get shop list");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          SizedBox(height: 70),
          TextViewHelper(
            "Shop List",
            textStyle: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 70),
          Expanded(
              child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).orientation ==
                              Orientation.landscape? 2 : 1,
                            mainAxisSpacing: 30,
                            crossAxisSpacing: 40,
                            mainAxisExtent: 200
                  ),
                  itemCount: response.pos_config!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var data = response.pos_config![index];
                    return ShopSelectionListTile(posConfig: data , agentName: response.agent_name,onResumeButtonClicked: (){
                           onResumeButtonClicked(data, context);
                        },);
                    
                  })),
        ],
      ),
    );
  }

  void onResumeButtonClicked(POSConfig data, BuildContext context) async {
    try{
      var cashOpenResult = await shopController.saveShopInfoAndGetSession(data , context);
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>  OnboardingScreen()));
    }
    catch(ex){
      UiHelper.showSnackbar(context,"Unable to start the session. please try again", color: Colors.red);
    }
  }
}
