import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/controller/order_controller.dart';
import 'package:self_service_app/ui/screens/home_screen.dart';
import 'package:self_service_app/ui/screens/order/modify_product_screen.dart';
import 'package:self_service_app/ui/screens/payment/payment_selection_screen.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/custom_text_field.dart';
import 'package:self_service_app/ui/widgets/order/cart_list_tile.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class CartScreen extends StatelessWidget {
  var loadOrderController = Get.lazyPut(() => OrderController());
  var orderController = Get.find<OrderController>(); 
  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(children: [
                      const SizedBox(height: 60),
                      TextViewHelper("Your Order",
                          textStyle: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 20),
                      TextViewHelper(
                        getOrderTypeString(),
                        textStyle: Theme.of(context).textTheme.displaySmall,
                        textColor: Colors.grey,
                      ),
                      const SizedBox(height: 50),
                    ]),
                  ),
                  Obx(() {
                    return orderController.appController.cart.isNotEmpty
                        ? SliverList.builder(
                            itemCount:  orderController.appController.cart.length,
                            itemBuilder: (context, index) {
                              var cartProduct =  orderController.appController.cart[index];
                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  child: CartListTile(
                                    productInfo: cartProduct,
                                    priceInfo:  orderController.appController
                                        .getPriceStringWithConfiguration(
                                      cartProduct
                                          .calculateFinalPriceTaxIncluded(
                                               orderController.appController.taxes),
                                    ),
                                    onQtyUpdated: (int updatedQty) {
                                      orderController.addToCart(
                                          context, cartProduct,
                                          qty: updatedQty);
                                    },
                                    onDelete: () {
                                      orderController.removeFromCart(
                                          context, cartProduct);
                                    },
                                    onEdit: (){
                                      moveToProductModifyScreen(context, cartProduct);
                                    },
                                  ));
                            },
                          )
                        : buildEmptyCart(context);
                  }),
                  buildPromoCode(context),
                  buildCartSummary(context),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: buildBottomActionButtons(context))
          ],
        ),
      ),
    );
  }

  buildPromoCode(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(
        () => Visibility(
          visible:  orderController.appController.cart.isNotEmpty,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 50),
              ContainerHelper(
                color: Theme.of(context).colorScheme.background,
                borderRadius: 12,
                width: double.infinity,
                customMargin: EdgeInsets.symmetric(horizontal: 24),
                customPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextViewHelper("Do you have promocode?",
                        textStyle: Theme.of(context).textTheme.titleLarge),
                    Container(
                      width: 200,
                      color: Colors.white,
                      child: TextFieldHelper(
                        label: "Enter code",
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildCartSummary(BuildContext context) {
    return Obx(
      () => SliverToBoxAdapter(
        child: Visibility(
          visible:  orderController.appController.cart.isNotEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: TextViewHelper("Subtotal:",
                                  textStyle:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            const SizedBox(width: 32),
                            Obx(
                              () => TextViewHelper(
                                "${orderController.appController.getSubtotalAmountInfoOfCart}",
                                textStyle:
                                    Theme.of(context).textTheme.displaySmall,
                                setBold: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: TextViewHelper("Discount:",
                                  textStyle:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            const SizedBox(width: 32),
                            TextViewHelper("SR 80",
                                textStyle:
                                    Theme.of(context).textTheme.displaySmall),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: TextViewHelper("Tax:",
                                  textStyle:
                                      Theme.of(context).textTheme.titleLarge),
                            ),
                            const SizedBox(width: 32),
                            Obx(
                              () => TextViewHelper(
                                "${orderController.appController.getTotalTaxInfoOfCart}",
                                textStyle:
                                    Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextViewHelper("Total:",
                            textStyle: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 24),
                        Obx(() => TextViewHelper(
                               orderController.appController.getTotalAmountInfoOfCartTaxIncluded,
                              textStyle:
                                  Theme.of(context).textTheme.displaySmall,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 150)
            ],
          ),
        ),
      ),
    );
  }

  buildBottomActionButtons(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ContainerHelper(
            width: null,
            borderRadius: 32,
            color: Theme.of(context).colorScheme.background,
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (Route<dynamic> route) => false);
            },
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios),
                const SizedBox(width: 32),
                TextViewHelper("Back to menu",
                    textStyle: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentSelectionScreen(),));
            },
            child: Row(
              children: [
                Text("Checkout"),
                const SizedBox(width: 32),
                Icon(Icons.arrow_forward_ios)
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildEmptyCart(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.background,
          radius: 200,
          child: Icon(Icons.shopping_cart, size: 150, color: Colors.grey[400]),
        ),
        const SizedBox(height: 100),
        TextViewHelper("Your basket is empty",
            textStyle: Theme.of(context).textTheme.displayLarge)
      ]),
    );
  }

  moveToProductModifyScreen(BuildContext context, Product selectedProduct){
    var productInfo =  orderController.appController.getProductInfoFromCart(selectedProduct.id!) ?? selectedProduct;
    Navigator.of(context).push(MaterialPageRoute(builder: (c) => ProductModifyScreen(productInfo: productInfo)));
  }

  String getOrderTypeString() {
    return  orderController.appController.selectedOrderType?.name == OrderOptionType.EAT_IN.name
        ? "Eat in"
        : "Take away";
  }
}
