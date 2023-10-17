import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/AppConfiguration.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/ui/widgets/product_list_tile.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/order/model/holdCartModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class HoldCartDetailScreen extends StatelessWidget {
  var shopController = Get.find<ShopController>();
  var orderController = Get.find<OrderController>();
  HoldCartModel mHoldCartModel;

  HoldCartDetailScreen(this.mHoldCartModel);

  @override
  Widget build(BuildContext context) {
    return
      Helper.isTablet(context)
          ? tabletLandScapeBuild(context)
          : portrait(context);
  }

  portrait(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.hold_cart_details_page),
          actions: [
            InkWell(
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(Icons.delete)),
                onTap: () {
                  Helper.showAlertDialog(context , title: AppLocalizations.of(context)!.hold_cart , description: AppLocalizations.of(context)!.hold_cart_description, onConfirm: () async{
                    Navigator.of(context).pop();
                    orderController.removeCurrentCartHold(false);
                    if (!Helper.isTablet(context)){
                      Navigator.pop(context);
                    }
                  });
                  
                }),
          ],
        ),
        body: buildBodyUI(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            orderController.removeCurrentCartHold(true);
            if (!Helper.isTablet(context))
              Navigator.pop(context);
          },
          child: Icon(Icons.shopping_cart, color: MyColors.textColorOnAccent),
          backgroundColor: MyColors.accentColor,
        ));
  }

  tabletLandScapeBuild(BuildContext context) {
    return Scaffold(
      body: buildBodyUI(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          orderController.removeCurrentCartHold(true);
          if (!Helper.isTablet(context))
            Navigator.pop(context);
        },
        child: const Icon(
          Icons.shopping_cart, color: MyColors.textColorOnAccent,),
        backgroundColor: MyColors.accentColor,
      ),
    );
  }

  Widget buildBodyUI(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          mHoldCartModel.customer != null ? customerData(context) : Container(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextView(
              AppLocalizations.of(context)!.product_detail,
              setBold: true,
              textSize: 24,
              topMargin: 22,
              alignment: Alignment.centerLeft,
            ),
            TextView(
              "${AppLocalizations.of(context)!.cartTotal}- ${shopController.appController.getPriceStringWithConfiguration(mHoldCartModel.getTotalAmountOfHoldCartTaxIncluded(shopController.appController.taxes))}",
              setBold: true,
              textSize: 18,
              topMargin: 22,
              alignment: Alignment.centerLeft,
            )
          ]),
          Divider(color: Colors.black),
          Expanded(
              child: ListView.builder(
                  itemCount: mHoldCartModel.products!.length,
                  itemBuilder: (BuildContext c, int i) {
                    var item = mHoldCartModel.products![i];
                    var currencyPosition = shopController.selectedPosConfig?.currency.firstOrNull?.position ?? Configuration.DEFAULT_CURRENCY_POSITION;
                    var currencySymbol = shopController.selectedPosConfig?.currency.firstOrNull?.symbol ?? Configuration.DEFAULT_CURRENCY_SYMBOL;
                    return ProductListTile(item: item,  currencySymbol: currencySymbol, currencyPosition: currencyPosition);
                  }))
        ],
      ),
    );
  }

  customerData(BuildContext context) {
    return Column(children: [
      TextView(
        AppLocalizations.of(context)!.cart_customer_details,
        setBold: true,
        textSize: 24,
        topMargin: 22,
        alignment: Alignment.centerLeft,
      ),
      Divider(color: Colors.black),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextView(
            "${AppLocalizations.of(context)!.cartCustomer} : " + mHoldCartModel.customer!.name!,
            setBold: true,
            topMargin: 12,
          ),
          TextView(
            "${AppLocalizations.of(context)!.date} : " + mHoldCartModel.date!,
            setBold: true,
            topMargin: 12,
          )
        ],
      ),
    ]);
  }
}
