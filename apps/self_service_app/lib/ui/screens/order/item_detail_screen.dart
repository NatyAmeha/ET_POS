import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:self_service_app/controller/shop_controller.dart';
import 'package:self_service_app/ui/screens/home_screen.dart';
import 'package:self_service_app/ui/screens/order/cart_screen.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class ItemDetailScreen extends StatelessWidget {
  int productIndex;
  ItemDetailScreen({super.key, required this.productIndex});
  var shopController = Get.find<ShopController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 40),
                    const SizedBox(width: 12),
                    TextViewHelper("Added to basket",
                        textStyle: Theme.of(context).textTheme.displayMedium),
                  ],
                ),
                ContainerHelper(
                  borderRadius: 30,
                  customMargin: const EdgeInsets.only(
                      left: 130, right: 130, top: 50, bottom: 32),
                  color: Theme.of(context).colorScheme.background,
                  child: Column(
                    children: [
                      TextViewHelper(
                        shopController.appController.cart.elementAtOrNull(productIndex)?.display_name ?? "",
                        textStyle: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 16),
                      TextViewHelper(
                        "${shopController.appController.cart.elementAtOrNull(productIndex) != null? shopController.getPriceStringForProduct(shopController.appController.cart[productIndex]) : ""}",
                        textStyle: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 50),
                      Image.network(
                        shopController.appController.cart.elementAtOrNull(productIndex)?.image_url ?? "",
                        width: 250,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextViewHelper(
                    "The Jalapeno Popper Show is a Mexican Chicken Burger topped with jalapeno-infused cream cheese." *
                        3,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    setBold: true,
                    textAlignment: TextAlign.center,
                    
                    maxline: 4,
                  ),
                ),
                const SizedBox(height: 24),
                buildIncludedItemsList(context),
                const SizedBox(height: 40),
                buildAdditionalOptionList(context),
                const SizedBox(height: 300)
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ContainerHelper(
              customPadding:
                  const EdgeInsets.only(left: 100, right: 100, bottom: 32),
              color: Colors.white,
              child: Column(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CartScreen(),));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Go to basket"),
                        const SizedBox(width: 16),
                        Icon(Icons.keyboard_arrow_right_outlined)
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      moveToHomeScreen(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Continue shopping"),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  Widget buildAdditionalOptionList(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),
        ContainerHelper(
          color: Theme.of(context).colorScheme.background,
          child: TextViewHelper("Add to your order",
              setBold: true,
              textStyle: Theme.of(context).textTheme.displayMedium),
        ),
        const SizedBox(height: 32),
        GridView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 24,
            mainAxisSpacing: 16,
            mainAxisExtent: 250,
          ),
          children: List.generate(5, (index) => optionListTile(context)),
        )
      ],
    );
  }

  Widget optionListTile(BuildContext context) {
    return ContainerHelper(
        borderRadius: 16,
        padding: 12,
        borderColor: Colors.grey[300],
        child: Column(
          children: [
            ContainerHelper(
              borderRadius: 20,
              color: Theme.of(context).colorScheme.background,
              child: Image.asset("assets/images/product_item_sample.png",
                  width: 80, height: 100),
            ),
            const SizedBox(height: 16),
            TextViewHelper("Pepsi",
                textStyle: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextViewHelper("SR 120",
                textColor: Theme.of(context).colorScheme.primary,
                textStyle: Theme.of(context).textTheme.titleSmall)
          ],
        ));
  }

  Widget buildIncludedItemsList(BuildContext context) {
    return GridView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 24,
          mainAxisSpacing: 16,
          mainAxisExtent: 30,
        ),
        children: List.generate(
          6,
          (index) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Flexible(
                child: TextViewHelper(
                  "Customizd item name $index",
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  maxline: 2,
                  textColor: Theme.of(context).colorScheme.primary,
                ),
              )
            ],
          ),
        ));
  }

  moveToHomeScreen(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()), (Route<dynamic> route) => false);
  }
}
