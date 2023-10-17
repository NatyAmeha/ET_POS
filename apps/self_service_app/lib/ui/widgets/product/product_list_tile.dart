import 'package:flutter/material.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class ProductListTile extends StatelessWidget {
  Product productInfo;
  String priceInfo;
  Function? onAddClicked;
  Function? onModifyClicked;
  bool isAddedToCart;
  ProductListTile({
    super.key,
    required this.productInfo,
    required this.priceInfo,
    this.isAddedToCart = false,
    this.onAddClicked,
    this.onModifyClicked,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerHelper(
      borderRadius: 16,
      padding: 24,
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Image.network(productInfo.image_url ?? "", width: 130, height: 130),
          const SizedBox(height: 16),
          TextViewHelper(productInfo.display_name,
              textStyle: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          TextViewHelper(
            "The Jalapeno Popper Show is a Mexican Chicken Burger topped with jalapeno-infused cream cheese.",
            textStyle: Theme.of(context).textTheme.bodyMedium,
            maxline: 3,
          ),
          const SizedBox(height: 16),
          TextViewHelper(
            priceInfo,
            textStyle: Theme.of(context).textTheme.displayMedium,
            textColor: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                  onPressed: () {
                    this.onModifyClicked?.call();
                  },
                  child: Text("Modify")),
              
              isAddedToCart ?
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green,), 
                  const SizedBox(width: 8),
                  TextViewHelper("Added", textStyle: Theme.of(context).textTheme.titleLarge,
                  textColor: Colors.green,)
                ]
              ):
              FilledButton(
                onPressed: !isAddedToCart
                ? () {
                  this.onAddClicked?.call();
                }
                : null,
                child: Text("Add")
              )
            ],
          )
        ],
      ),
    );
  }
}
