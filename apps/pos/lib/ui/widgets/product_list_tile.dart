import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/controller/app_controller.dart';

import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ProductListTile extends StatelessWidget {
  var appController = Get.find<AppController>();
  Product item;
  String? currencySymbol;
  String? currencyPosition;
  ProductListTile(
      {super.key,
      required this.item,
      this.currencyPosition = "after",
      this.currencySymbol = ""});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 16),
        child: Row(children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Image.network(item.image_url!, width: 48, height: 48),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(item.display_name, textSize: 16),
              TextView("${AppLocalizations.of(context)!.unit_price} :${appController.getPriceStringWithConfiguration(double.parse(item.unit_price!))}"),
              TextView("${AppLocalizations.of(context)!.quantity} : " + item.unitCount.toString()),
              item.discount != null
                  ? TextView(item.discountInfo(),textSize: 16, alignment: Alignment.topLeft)
                  : Container()
            ],
          )
        ]));
  }
}
