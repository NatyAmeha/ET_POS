import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hozmacore/features/payment/model/pricelistResponse.dart';
import 'package:hozmacore/features/shop/model/splashResponse.dart';
import 'package:hozmacore/shared_models/Response.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/auth_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/ui/screens/account/login_screen.dart';
import 'package:odoo_pos/ui/widgets/CommonWidgets.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class ProfileScreen extends StatelessWidget {
  final shopController = Get.find<ShopController>();
  var authController = Get.put(AuthController());


  loadAgentInfo(BuildContext context){
    Future.delayed(Duration.zero , (){
      shopController.getAgentInfo(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    loadAgentInfo(context);
    return Scaffold(
      body: Obx(() {
        switch (shopController.agentInfoStatus) {
          case Status.LOADING:
            return CommonWidgets.showProgressbar();

          case Status.ERROR:
            return CommonWidgets.showErrorMessage(context,shopController.selectedShop.value.message!);

          case Status.COMPLETED:
            return Container(
              child: SingleChildScrollView(
                          child: Column(
                          children: [
                           Stack(
                            children: [
                              Container(
                                color: MyColors.accentColor,
                                height: 200,
                                alignment: Alignment.topRight,
                                child: TextButton(
                                  child: TextView(
                                    AppLocalizations.of(context)!.logout,
                                    setBold: true,
                                  ),
                                  onPressed: () {
                                    Helper.showAlertDialog(context, title: AppLocalizations.of(context)!.logout, description: AppLocalizations.of(context)!.logout_description, onConfirm: () async {
                                      await authController.logout();
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                                    });
                                  },
                                ),
                              ),
                              Container(
                                  alignment: Alignment.topCenter,
                                  margin: const EdgeInsets.only(top: 136),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(66.0),
                                      child: Image.network(
                                        shopController.agentInfo.agentProfileImage!,
                                        width: 128,
                                        height: 128,
                                      )))
                            ],
                          ),
                          TextView(
                            shopController.agentInfo.agent_name,
                            textSize: 22,
                            margin: 16,
                            setBold: true,
                          ),
                          Divider(
                            height: 2,
                            color: MyColors.grey,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextView(
                                  "Change Cashier",
                                  textSize: 18,
                                  margin: 8,
                                  setBold: true,
                                ),
                                buildUserSelection()
                              ]),
                          Obx(() => shopController.priceLists.length > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                      TextView(
                                        "Change PriceList",
                                        textSize: 18,
                                        margin: 8,
                                        setBold: true,
                                      ),
                                      buildPriceListSelection(
                                          shopController.priceLists)
                                    ])
                              : Container()),
                        ],
                      ),)
            );
        }
      },),
    );
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape &&
        MediaQuery.of(context).size.height > 600;
  }

  buildPriceListSelection(List<PriceListItem?> prices) {
    return DropdownButton<PriceListItem>(
      // style: TextStyle(color: Colors.white),
      value: shopController.getSelectedPriceListItem(),
      dropdownColor: MyColors.accentColor,
      // iconEnabledColor: Colors.white,
      onChanged: (PriceListItem? newValue) {
        shopController.setSelectedPriceItem(newValue);
      },
      items: shopController.priceLists
          .map<DropdownMenuItem<PriceListItem>>((PriceListItem? value) {
        return DropdownMenuItem<PriceListItem>(
          value: value,
          child: Text(value!.name!),
        );
      }).toList(),
    );
  }

  buildUserSelection() {
    return Obx(() => shopController.cashiersList.isNotEmpty == true ? Container() : 
    DropdownButton<User>(
        value: shopController.selectedCashier,
        dropdownColor: MyColors.accentColor,
        onChanged: (User? newValue) {
          shopController.setSelectedUser(newValue);
        },
        items: shopController.cashiersList.map<DropdownMenuItem<User>>((User value) {
          return DropdownMenuItem<User>(
            value: value,
            child: Text(value.name!),
          );
        }).toList(),
      )); 
  }
}
