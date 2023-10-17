import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hozmacore/features/order/model/orderModel.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LargeScreenOrderListTile extends StatelessWidget {
  OrderModel orderInfo;
  int index;
  int selectedOrderIndex;
  Function? onOrderSelected;
  LargeScreenOrderListTile(
      {required this.orderInfo,
      required this.index,
      required this.selectedOrderIndex,
      this.onOrderSelected});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return CustomContainer(
          onTap: () {
            onOrderSelected?.call();
          },
          padding: 0,
          borderColor: index == selectedOrderIndex ? Colors.black : null,
          color: index == selectedOrderIndex ? Colors.grey[100] : Colors.white,
          borderRadius: 10,
          child: Row(
            children: [
              CustomContainer(
                alignment: Alignment.centerLeft,
                width: (constraints.maxWidth - 5) / 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextView(AppLocalizations.of(context)!.ordDetOrderDetails,
                        textStyle: Theme.of(context).textTheme.bodyLarge),
                    TextView(orderInfo.orders[0].creation_date,
                        textColor: Theme.of(context).colorScheme.secondary,
                        textStyle: Theme.of(context).textTheme.titleMedium)
                  ],
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - 5) / 4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle_outlined),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextView(
                          orderInfo.customer?.name ??
                              orderInfo.orders[0].username,
                          textStyle: Theme.of(context).textTheme.titleLarge),
                    )
                  ],
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - 5) / 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextView(AppLocalizations.of(context)!.total_amount,
                        textStyle: Theme.of(context).textTheme.bodyLarge),
                    TextView("${double.parse(orderInfo.orders[0].amount_total!).toStringAsFixed(2)}",
                        textStyle: Theme.of(context).textTheme.titleLarge)
                  ],
                ),
              ),
              CustomContainer(
                alignment: Alignment.centerRight,
                width: (constraints.maxWidth - 5) / 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextView(AppLocalizations.of(context)!.paid,
                        textStyle: Theme.of(context).textTheme.bodyLarge),
                    TextView(orderInfo.orders[0].amount_paid.toStringAsFixed(2),
                        textColor: Theme.of(context).colorScheme.tertiary,
                        textStyle: Theme.of(context).textTheme.titleLarge)
                  ],
                ),
              )
            ],
          ));
    });
  }
}
