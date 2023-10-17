import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:self_service_app/controller/order_controller.dart';
import 'package:self_service_app/controller/shop_controller.dart';
import 'package:self_service_app/ui/screens/order/item_detail_screen.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/product/product_item_list_tile.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class ProductModifyScreen extends StatefulWidget {
  Product productInfo;
  ProductModifyScreen({super.key, required this.productInfo});

  @override
  State<ProductModifyScreen> createState() => _ProductModifyScreenState();
}

class _ProductModifyScreenState extends State<ProductModifyScreen> {
  var shopController = Get.find<ShopController>();
  var loadOrderController = Get.lazyPut(() => OrderController());
  var orderController = Get.find<OrderController>();

  var qty = 1;
  var priceInfo = "";

  @override
  void initState() {
    setState(() {
      qty = widget.productInfo.unitCount ?? 1;
      priceInfo = shopController.appController.getPriceStringWithConfiguration(widget.productInfo.calculateUnitPriceTaxIncluded(shopController.appController.taxes)* qty);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true, 
                  collapsedHeight: 360,
                  surfaceTintColor: Colors.white,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        productInfoWithQty(context),
                        ContainerHelper(
                          customPadding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
                          alignment: Alignment.centerLeft,
                          color: Theme.of(context).colorScheme.background,
                          child: Column(
                            children: [
                              TextViewHelper("Modify",
                                  textStyle:
                                      Theme.of(context).textTheme.displayLarge),
                            ],
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        child: TextViewHelper("Included Items",
                            setBold: true,
                            textStyle: Theme.of(context).textTheme.titleLarge)),
                    Divider(height: 0),
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(left: 32),
                      color: Theme.of(context).colorScheme.primary,
                      height: 1,
                      child: SizedBox(),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
                SliverGrid.builder(
                  itemCount: 10,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 32,
                    mainAxisExtent: 320,
                  ),
                  itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ProductItemListTile(
                        isIncluded: true,
                      )),
                ),
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: TextViewHelper(
                    "ADD-ONS",
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    setBold: true,
                    textAlignment: TextAlign.center,
                  ),
                )),
                SliverGrid.builder(
                  itemCount: 10,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 32,
                    mainAxisExtent: 250,
                  ),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ProductItemListTile(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 200),
                )
              ],
            ),
            Positioned(
              bottom: 0,
              child: bottomNavigation(context),
            )
          ],
        ),
      ),
    );
  }

  Widget productInfoWithQty(BuildContext context) {
    return ContainerHelper(
      padding: 32,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ContainerHelper(
            borderRadius: 20,
            width: 200,
            height: 200,
            color: Theme.of(context).colorScheme.background,
            child: Image.network(widget.productInfo.image_url ?? "",
                width: 120, height: 120),
          ),
          const SizedBox(width: 24),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextViewHelper(widget.productInfo.display_name,
                  textStyle: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 16),
              TextViewHelper(
                "The Jalapeno Popper Show is a Mexican Chicken Burger topped with jalapeno-infused cream cheese.",
                textStyle: Theme.of(context).textTheme.bodyLarge,
                maxline: 5,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton.outlined(
                    onPressed: () {
                      updateQtyAndPrice(decreaseQty: true);
                    },
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.remove),
                    ),
                    style: IconButton.styleFrom(
                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                      foregroundColor: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 24),
                  ContainerHelper(
                    width: 100,
                    borderColor: Colors.grey,
                    borderRadius: 30,
                    customPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: TextViewHelper("${qty}",
                          textStyle: Theme.of(context).textTheme.titleLarge),
                  ),
                  const SizedBox(width: 24),
                  IconButton.filled(
                    onPressed: () {
                      updateQtyAndPrice();
                    },
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget bottomNavigation(BuildContext context) {
    return ContainerHelper(
      customPadding: const EdgeInsets.symmetric(horizontal: 50),
      width: MediaQuery.of(context).size.width,
      height: 100,
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        children: [
          ContainerHelper(
              onTap: () {
                Navigator.of(context).pop();
              },
              width: null,
              height: 55,
              customPadding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              borderRadius: 40,
              borderColor: Colors.white,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  TextViewHelper(
                    "Back",
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    textColor: Colors.white,
                  ),
                ],
              )),
          Spacer(),
          TextViewHelper(
            "${priceInfo}",
            textStyle: Theme.of(context).textTheme.displayLarge,
            textColor: Colors.white,
          ),
          const SizedBox(width: 60),
          FilledButton.icon(
              onPressed: () {
                moveToItemDetailScreen(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              icon: Icon(Icons.add),
              label: Text("Add To Basket"))
        ],
      ),
    );
  }

  updateQtyAndPrice({bool decreaseQty = false}){
    setState(() {
      if(decreaseQty){
        if(qty > 1){
          qty = qty -1;
        }
      }
      else{
        qty = qty + 1;
      }
      priceInfo = shopController.appController.getPriceStringWithConfiguration(widget.productInfo.calculateUnitPriceTaxIncluded(shopController.appController.taxes)* qty);
                        
  });
    
  }


  moveToItemDetailScreen(BuildContext context) {    
     var index = orderController.addToCart(context, widget.productInfo, qty: qty);
     Navigator.of(context).push(MaterialPageRoute(builder: (context) => ItemDetailScreen(productIndex: index),));
  }
}
