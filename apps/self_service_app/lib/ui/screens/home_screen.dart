import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:self_service_app/controller/order_controller.dart';
import 'package:self_service_app/controller/shop_controller.dart';
import 'package:self_service_app/ui/screens/order/cart_screen.dart';
import 'package:self_service_app/ui/screens/order/item_detail_screen.dart';
import 'package:self_service_app/ui/screens/order/modify_product_screen.dart';
import 'package:self_service_app/ui/screens/payment/payment_selection_screen.dart';
import 'package:self_service_app/ui/widgets/order/order_list_dialog.dart';
import 'package:self_service_app/ui/widgets/product/category_list_tile.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/product/product_list_tile.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';
import 'package:self_service_app/utils/ui_helper.dart';
import 'package:hozmacore/shared_models/Response.dart' as ApiResponse;
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var shopController = Get.put(ShopController());
  var loadOrderController = Get.lazyPut(() => OrderController());
  var orderController = Get.find<OrderController>();
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      shopController.appController.initializedTimerContext(context);
      shopController.getProductsAndTaxes(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => UiHelper.displayContent(
            canShow: shopController.productList.value.status ==
                ApiResponse.Status.COMPLETED,
            isLoading: shopController.productList.value.status ==
                ApiResponse.Status.LOADING,
            content: Stack(
              children: [
                Positioned.fill(
                    child:
                        buildBody(shopController.productList.value.data ?? [])),
                Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: buildBottomNavigation()
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildBody(List<Product> products) {
    var productsByCategory = shopController.selectProductsByCategory(products);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerHelper(
          padding: 0,
          height: shopController.categories.length > 5 ? 330 : 160,
          width: double.infinity,
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: shopController.categories.length,
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: shopController.categories.length > 5 ? 2 : 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
              mainAxisExtent: 150,
            ),
            itemBuilder: (context, index) => Obx(
              () => CategoryListTile(
                categoryInfo: shopController.categories[index],
                index: index,
                selectedIndex: shopController.selectedCategory.value,
                onCategorySelected: () {
                  shopController.setSelectedCategory(index);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding :  const EdgeInsets.symmetric(horizontal: 24),
          child: TextViewHelper(
            shopController.getSelectedCategory().name,
            textStyle: Theme.of(context).textTheme.displayLarge,
            setBold: true,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: productsByCategory.isNotEmpty
              ? GridView.builder(
                  padding:
                      const EdgeInsets.only(bottom: 150, left: 24, right: 24),
                  itemCount: productsByCategory.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: setCrossAxisCount(),
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    mainAxisExtent:  430
                  ),
                  itemBuilder: (context, index) => Obx(
                    () => ProductListTile(
                      productInfo: productsByCategory[index],
                      priceInfo: shopController.getPriceStringForProduct(productsByCategory[index],showUnitPrice: true),
                      isAddedToCart: shopController.isProductInCart(productsByCategory[index]),
                      onAddClicked: (){
                        moveToOrderItemDetails(context, productsByCategory[index]);
                      },
                      onModifyClicked: () {
                        moveToProductModifyScreen(context, productsByCategory[index]);
                      },
                    ),
                  ),
                )
              : ContainerHelper(
                  alignment: Alignment.topCenter,
                  child: TextViewHelper(
                  "No product foud in this category",
                  textStyle: Theme.of(context).textTheme.titleLarge,
                )),
        )
      ],
    );
  }

  buildBottomNavigation(){
    return ContainerHelper(
        customPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 1200
                ? MediaQuery.of(context).size.width * 0.15
                : 0,
            vertical: 16),
        height: 100,
        width: double.infinity,
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.wheelchair_pickup),
                iconSize: 30,
                color: Colors.white),
            const SizedBox(width: 8),
            VerticalDivider(),
            const SizedBox(width: 16),
            badges.Badge(
              position: badges.BadgePosition.topEnd(),
              badgeContent: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Obx(() => TextViewHelper(
                        "${shopController.appController.cart.length}",
                        setBold: true,
                        textSize: 17,
                        textColor: Colors.white,
                      ))),
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.transparent,
                elevation: 8,
                borderSide: BorderSide(color: Colors.white, width: 2),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartScreen(),));
                },
                icon: Icon(Icons.shopping_cart, size: 40),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            VerticalDivider(),
            const SizedBox(width: 30),
            Obx(
              () => TextViewHelper(
                "${shopController.appController.getTotalAmountInfoOfCartTaxIncluded}",
                textStyle: Theme.of(context).textTheme.displayMedium,
                textColor: Colors.white,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: FilledButton(
                  onPressed: () {
                    showOrderListBottomSheet();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: Text("View my order")),
                      Icon(Icons.keyboard_arrow_up)
                    ],
                  )),
            ),
            const SizedBox(width: 24),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentSelectionScreen()));
                },
                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Checkout"),
                    const SizedBox(width: 16),
                    Icon(Icons.keyboard_arrow_right)
                  ],
                ))
          ],
        ));
  }


  setCrossAxisCount(){
    //330 is product tile width
    if(MediaQuery.of(context).size.width/4 >= 330){
      return 4;
    }
    else if(MediaQuery.of(context).size.width /3 >= 330){
      return 3; 
    }
    else {
      return 2;
    }
  }

  showOrderListBottomSheet(){
    UiHelper.showBottomsheetDialog(context, OrderListDialog(
      onQtyUpdated: (int updatedQty, int selectedProductIndex) {
        orderController.addToCart(
          context, 
          shopController.appController.cart[selectedProductIndex],
          qty: updatedQty
        );
      },
      onDelete: (selectedProdutIndex) {
        orderController.removeFromCart(
          context, 
          shopController.appController.cart[selectedProdutIndex],
        );
      },
      ), 
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.95,
      verticalMargin: 60, 
    
  );
  }

  moveToOrderItemDetails(BuildContext context, Product selectedProduct){
    var index = orderController.addToCart(context, selectedProduct, qty: selectedProduct.unitCount ?? 1);
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => ItemDetailScreen(productIndex: index)));
  }

  moveToProductModifyScreen(BuildContext context, Product selectedProduct){
    var productInfo = shopController.appController.getProductInfoFromCart(selectedProduct.id!) ?? selectedProduct;
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => ProductModifyScreen(productInfo: productInfo)));
  }
}
