import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/ui/widgets/order/cart_list_tile.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class OrderListDialog extends StatelessWidget {
  var appController = Get.find<AppController>();
  Function(int, int)? onQtyUpdated;
  Function(int selectedProdutIndex)? onDelete;
  OrderListDialog({super.key, this.onQtyUpdated, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.keyboard_arrow_down, size: 50, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Obx(() {
            return appController.cart.isNotEmpty
                ? ListView.separated(
                    itemCount: appController.cart.length,
                    separatorBuilder: (context, index) => SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      var selectedProduct = appController.cart[index];
                      return CartListTile(
                        productInfo: selectedProduct,
                        priceInfo:
                            appController.getPriceStringWithConfiguration(
                          selectedProduct.calculateFinalPriceTaxIncluded(
                              appController.taxes),
                        ),
                        onQtyUpdated: (newQty) {
                          onQtyUpdated?.call(newQty, index);
                        },
                        onDelete: () {
                          onDelete?.call(index);
                        },
                      );
                    },
                  )
                : buildEmptyCart(context);
          }),
        ),
      ],
    );
  }

  buildEmptyCart(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.background,
        radius: 150,
        child: Icon(Icons.shopping_cart, size: 100, color: Colors.grey[400]),
      ),
      const SizedBox(height: 100),
      TextViewHelper("Your basket is empty",
          textStyle: Theme.of(context).textTheme.displayLarge)
    ]);
  }
}
