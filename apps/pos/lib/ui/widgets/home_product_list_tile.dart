import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:odoo_pos/AppConfiguration.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/shared_models/currency.dart';
import 'package:hozmacore/features/order/model/product/product.dart';

class HomeProductListTile extends StatelessWidget {
  Product? data;
  Function? onProductClicked;
  String priceInfo;
  HomeProductListTile({required this.data , required this.priceInfo, this.onProductClicked});


buildItemLayout(Product data, BuildContext context) {
  return CustomContainer(
      padding: 0,
      width: MediaQuery.of(context).size.width / 3,
      margin: 8,
      borderColor: Colors.grey,
      borderRadius: 16,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(child: Image.network(data.image_url!, fit: BoxFit.cover)),
                CustomContainer(
                  customPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  customMargin: const EdgeInsets.only(bottom: 12),
                  alignment: Alignment.centerLeft,
                  color: Colors.white,
                  child: TextView(
                    data.display_name!, textStyle: Theme.of(context).textTheme.titleLarge,
                    maxline: 2,
                  ),
                )
              ],
            ),
          ),
          
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  color: Colors.black45,
                ),
                
                child: TextView(
                    priceInfo,
                    alignment: Alignment.centerLeft,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                     textColor: Colors.white,),
              ),
            ),
          ),
        ],
      ),
      onTap: () {
        onProductClicked?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildItemLayout(data!, context);
  }
}