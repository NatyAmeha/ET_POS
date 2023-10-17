import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/auth_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/ui/screens/account/login_screen.dart';
import 'package:odoo_pos/ui/screens/dashboard_screen.dart';
import 'package:odoo_pos/ui/widgets/CommonWidgets.dart';
import 'package:odoo_pos/ui/widgets/shop_selection_list_tile.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:hozmacore/shared_models/Response.dart';

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
          title: Text(AppLocalizations.of(context)!.hozma_pos),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Helper.showAlertDialog(context, title: AppLocalizations.of(context)!.logout, description: AppLocalizations.of(context)!.logout_description, onConfirm: () async {
                  await authController.logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                });
              },
              tooltip: AppLocalizations.of(context)!.logout,
            )
          ],
        ),
        body:  Obx((){
          return Helper.displayContent(
            canShow: shopController.selectedShop.value.status == Status.COMPLETED, 
            isLoading: shopController.selectedShop.value.status == Status.LOADING || shopController.isLoading.value,
            content: buildUI(shopController.selectedShop.value.data, context), 
            errorMessage: shopController.selectedShop.value.message,
            context: context,
            onTryAgain: (){
              getShopInfo();
            }
          );
        }
      )
    );
  }

  buildUI(LoginResponse? response, BuildContext context) {
    if (response == null) return CommonWidgets.showProgressbar();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Helper.isTablet(context)?  100: 16),
      child: Column(
        children: [
          SizedBox(height: Helper.isTablet(context) ? 70 : 16),
          TextView(
            AppLocalizations.of(context)!.shopList,
            textStyle: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: Helper.isTablet(context) ? 70 : 16),
          Expanded(
              child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).orientation ==
                              Orientation.landscape? 2 : Helper.isTablet(context)? 2: 1,
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
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => new DashBoardScreen(cashOpenResult)));
    }
    catch(ex){
      Helper.showSnackbar(context,AppLocalizations.of(context)!.unable_to_start_sessin_error_message, color: Colors.red);
    }
  }
}
