import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/ui/widgets/home_product_list_tile.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchScreen extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  var shopController = Get.find<ShopController>();
  var orderController = Get.find<OrderController>();

  @override
  Widget build(context) {
    return Scaffold(
          appBar: AppBar(
            title: TextFormField(
              style: TextStyle(color: Colors.white),
              controller: controller,
              autofocus: true,
              onChanged: (value) {
                shopController.searchProducts(value , context);
              },
              cursorColor: Colors.white,
              decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.search,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder : InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey)),
            ),
          ),
          body:  Obx((){
            var products = shopController.searchedProductList.value;
            filterPriceList(products , context);
            return products.length > 0
        ? GridView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 &&
                      MediaQuery.of(context).orientation == Orientation.portrait
                  ? 4
                  : MediaQuery.of(context).orientation == Orientation.landscape
                      ? 4
                      : 2,
              childAspectRatio: (1 - (90 / MediaQuery.of(context).size.width)),
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              var product = products[index];
              return HomeProductListTile(
                data: product, 
                priceInfo :  product.getUnitPriceWithConfiguration(shopController.appController.currencyPosition, shopController.appController.currencySymbol),
                onProductClicked: () async {
                  await orderController.addProductToCart(context , product);
                  Helper.showSnackbar(context, AppLocalizations.of(context)!.added_into_cart, color: Colors.green);
                }
              );
            })
        : Container(
            child: TextView(
              AppLocalizations.of(context)!.no_product,
              textSize: 24,
              setBold: true,
              alignment: Alignment.center,
            ),
          );
        }) );
      
  }

  filterPriceList(List<Product> productList, BuildContext context) {
    var priceListItem = shopController.getSelectedPriceListItem()!.data;
      if (priceListItem != null) {
        priceListItem.forEach((pricelistItem) {
          productList.forEach((product) {
            if (product.id.toString() == pricelistItem.productId.toString())
            product.unit_price = pricelistItem.price.toString();
          });
        });
      }
  }
}
