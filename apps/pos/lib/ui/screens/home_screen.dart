
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/ui/screens/cart/cart_screen.dart';
import 'package:odoo_pos/ui/screens/order/order_list_screen.dart';
import 'package:odoo_pos/ui/screens/search_screen.dart';
import 'package:odoo_pos/ui/widgets/CommonWidgets.dart';
import 'package:odoo_pos/ui/widgets/bottom_cart_money_return_indicator.dart';
import 'package:odoo_pos/ui/widgets/category_list.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/home_product_list_tile.dart';
import 'package:odoo_pos/ui/widgets/search_bar.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/shared_models/Response.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  var shopController = Get.find<ShopController>();
  var orderController = Get.find<OrderController>();

  @override
  void initState() {
    Future.delayed(Duration.zero , (){
      shopController.getProductsAndTaxes(context);
      shopController.getCustomersFromApiAndSaveToDb(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
        body: Obx((){
          switch (shopController.productList.value.status) {
            case  Status.LOADING:
              return CommonWidgets.showProgressbar();  
            case Status.COMPLETED:
              return buildData(shopController.productList.value.data, context); 
            case Status.ERROR:
              return CommonWidgets.showErrorMessage(context , AppLocalizations.of(context)!.erro_occured_please_try_again,
              onTryAgain: (){
                Future.delayed(Duration.zero , (){
                  shopController.getProductsAndTaxes(context);
                  shopController.getCustomersFromApiAndSaveToDb(context);
                });
              });      
          }
        }),
    );
  }

  buildData(List<Product>? products, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if(Helper.isTablet(context)) ...[
          const SizedBox(height: 16),
          Searchbar(onSearchbarClicked: (){
            Navigator.of(context).push( MaterialPageRoute(builder: (c) => SearchScreen()));
          },
        ),
        ],
        if(Helper.isTablet(context))
          const SizedBox(height: 24),
        Expanded(  
          child: CustomContainer(
            padding: 0,
            customMargin: Helper.isTablet(context) ? const EdgeInsets.symmetric(horizontal: 108) : null,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Helper.isTablet(context) ? CartScreen() : Container(),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomContainer(
                        margin: Helper.isTablet(context) ?  16 : null,
                        borderRadius: Helper.isTablet(context) ?  6 : 0,
                        borderColor:  Helper.isTablet(context) ?  Colors.grey[300] : null,
                        padding:  Helper.isTablet(context) ?  12 : 8,
                       
                        width: MediaQuery.of(context).orientation == Orientation.landscape &&
                                Helper.isTablet(context)
                            ? MediaQuery.of(context).size.width / 1.8
                            : MediaQuery.of(context).size.width,
                        child: Column(
                            children: [
                              Obx(() =>
                                 CategoryList(categoryList: shopController.categories , selectedIndex: shopController.selectedCategory.value, onCategorySelected: (selectedCategoryIndex){
                                    shopController.setSelectedCategory(selectedCategoryIndex);
                                  },),
                              ),
                              Divider(thickness: 1),
                              Expanded(child: buildListData(products, context))
                            ],
                          ),
                      ),
                    ),
                    if(!Helper.isTablet(context))
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: CartAndMoneyReturnIndicator(carttotalPrice: shopController.appController.getPriceStringWithConfiguration(Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes)) , 
                        onShoppingCartClicked: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext c) => CartScreen()));
                        },
                        onMoneyReturnClic: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext c) => OrderListScreen()));
                        
                        },),
                      )
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape &&
        MediaQuery.of(context).size.height > 600;
  }

  buildListData(List<Product>? productList, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Obx(() {
          var products = filterProductList(productList);
          return  GridView.builder(
              controller: ScrollController(),
              physics: ClampingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 100),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:calculateCrossAxisCountForProduct(constraint.maxWidth),
                mainAxisExtent: 200
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
              });
        });
      }
    );
  }

  List<Product> filterProductList(List<Product>? productList) {
    filterPriceList(productList);
    if (shopController.selectedCategory == 0)
      return productList ?? [];
    else {
      var categoryId = shopController.categories[shopController.selectedCategory.value];
      List<Product> products = productList!.where((element) {
        return element.pos_categ_id.toString() == categoryId.id.toString();
      }).toList();
      return products;
    }
  }

  filterPriceList(List<Product>? productList) {
    if (shopController.priceLists.length > 0) {
      var list = shopController.getSelectedPriceListItem()!.data;
      list?.forEach((pricelistItem) {
        productList!.forEach((product) {
          if (product.id.toString() == pricelistItem.productId.toString())
            product.unit_price = pricelistItem.price.toString();
        });
      });
    }
  }

  int calculateCrossAxisCountForProduct(double availableWidth){
    if(availableWidth/5 >= 170){
      return 5;
    }
    else if(availableWidth/4 >=170){
      return 4;
    }
    else if (availableWidth / 3 >= 170) {
      return 3;
    }
    else {
      return 2;
    }
  }
}
