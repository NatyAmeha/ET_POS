import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget DateRangePicker(
  context, Function(DateTimeRange?) onDateSelected
) {
  var orderController = Get.find<OrderController>();
  return GestureDetector(
      onTap: () async {
        // TODO keyboard issue in samsung: https://github.com/flutter/flutter/issues/62401
        
      },
      child: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    orderController.dateRange.isNotEmpty
                        ? orderController.dateRange.value
                        : orderController.dateRange.value == "null"
                            ? AppLocalizations.of(context)!.select_date_range
                            : AppLocalizations.of(context)!.select_date_range,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Visibility(
                      visible: orderController.dateRange.isNotEmpty ? true : false,
                      child: GestureDetector(
                          onTap: () {
                            orderController.setDateRange("");
                            if (orderController.isOfflineSelected == true) {
                              //_controllerOrderTab.getOnlineOrder();
                            } else if (orderController.isOfflineSelected == false) {
                              // _controllerOrderTab.getOfflineOrder();
                            }
                            orderController.fetchOrdersFromDb(context);
                          },
                          child: Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.black
                          )))
                ],
              ))));
}
