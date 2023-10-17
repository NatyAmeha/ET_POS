import 'package:flutter/material.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OrderListTile extends StatelessWidget {
  OrderModel orderInfo;
  int index;
  int selectedIndex;
  Function? onClick;
  OrderListTile({
    super.key,
    required this.orderInfo,
    required this.index,
    required this.selectedIndex,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: ListTile(
          tileColor: selectedIndex == index ? Colors.greenAccent : Colors.white,
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TextView(orderInfo.orders[0].name, setBold: true),
            orderInfo.syncStatus !=  "sync" ? Icon(Icons.wifi_off) : Container()
          ]),
          subtitle: TextView("${AppLocalizations.of(context)!.date} - " + orderInfo.orders[0].creation_date!),
        ),
        onTap: () {
          this.onClick?.call();
        });
  }
}
