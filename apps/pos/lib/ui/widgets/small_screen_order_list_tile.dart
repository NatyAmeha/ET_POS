import 'package:flutter/material.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';

class SmallScreenOrderListTile extends StatelessWidget {
  OrderModel orderInfo;
  int index;
  int selectedOrderIndex;
  Function? onOrderSelected;
  SmallScreenOrderListTile({
    required this.orderInfo,
    required this.index,
    required this.selectedOrderIndex,
    this.onOrderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
        onTap: () {
          onOrderSelected?.call();
        },
        margin: 8,
        borderColor: index == selectedOrderIndex ? Colors.black : null,
        borderRadius: 12,
        color: index == selectedOrderIndex ? Colors.grey[100] : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(orderInfo.orders[0].name,
                      textStyle: Theme.of(context).textTheme.bodyMedium),
                  TextView(
                    orderInfo.orders[0].creation_date,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  )
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextView(orderInfo.orders[0].amount_paid.toStringAsFixed(2),
                        textColor: Theme.of(context).colorScheme.tertiary,
                        textStyle: Theme.of(context).textTheme.titleLarge),
                if (orderInfo.syncStatus != "sync") ...[
                  const SizedBox(width: 4),
                  Icon(Icons.wifi_off)
                ]
              ],
            ),
          ],
        ));
  }
}
