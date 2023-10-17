import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:lottie/lottie.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/ui/screens/cart/hold_cart_detail_screen.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class HoldCartListScreen extends StatefulWidget {
  @override
  State<HoldCartListScreen> createState() => _HoldCartListScreenState();
}

class _HoldCartListScreenState extends State<HoldCartListScreen> {
  var orderController = Get.find<OrderController>();

  @override
  void initState() {
    Future.delayed(Duration.zero , (){
      orderController.fetchCartProductFromDatabase();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildStreamBuild(context),
    );
  }

  buildStreamBuild(BuildContext context) {
    return Obx(() => orderController.holdOrderList.isNotEmpty 
    ? buildMainLayout(context)
    : Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/lottie/empty_cart.json"),
          TextView(AppLocalizations.of(context)!.no_hold_cart_items, textSize: 24,setBold: true,alignment: Alignment.center,),
        ],
      ));
    
  }

  buildMainLayout( BuildContext context) {
    return Row(
      children: [
        buildUI( context),
        Helper.isTablet(context)
            ? Expanded(child: HoldCartDetailScreen(orderController.holdOrderList[orderController.selectedHoldedCart.value]))
            : Container()
      ],
    );
  }

  buildUI(BuildContext mContext) {
    return Container(
      decoration:
          BoxDecoration(border: Border.all(color: Colors.grey, width: 1)),
      width: Helper.isTablet(mContext)
          ? MediaQuery.of(mContext).size.width / 4
          : MediaQuery.of(mContext).size.width,
      child: ListView.builder(
          itemCount: orderController.holdOrderList.length,
          itemBuilder: (BuildContext context, int index) {
            var item = orderController.holdOrderList[index];
            return InkWell(
              child: ListTile(
                tileColor: orderController.selectedHoldedCart == index
                    ? Colors.greenAccent
                    : Colors.white,
                title:
                    TextView(item.customer != null ? item.customer!.name : ""),
                subtitle: TextView(item.date),
              ),
              onTap: () {
                orderController.setSelectedHoldedCartIndex(index);
                if (!Helper.isTablet(context))
                  Navigator.push(
                      mContext,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              new HoldCartDetailScreen(item)));
              },
            );
          }),
    );
  }

}
