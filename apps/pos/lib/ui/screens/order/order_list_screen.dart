import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/ui/screens/dashboard_screen.dart';
import 'package:odoo_pos/ui/screens/order/order_detail_screen.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/large_screen_order_list_tile.dart';
import 'package:odoo_pos/ui/widgets/small_screen_order_list_tile.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OrderListScreen extends StatefulWidget {
  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  var orderController = Get.find<OrderController>();
  

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      orderController.fetchOrdersFromDb(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return Helper.displayContent(
        canShow: true, 
        isLoading: orderController.isLoading.value,
        context: context,
        content: buildMainLayout(context), 
      );
    }); 
  }

  buildMainLayout(BuildContext context) {
    return Scaffold(
      appBar: !Helper.isTablet(context)
          ? AppBar(
              title: Text(AppLocalizations.of(context)!.orders),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomContainer(
                customPadding: EdgeInsets.symmetric(
                    horizontal: Helper.isTablet(context)
                        ? MediaQuery.of(context).size.width * 0.05
                        : 0),
                child: Column(
                  children: [
                    // if(Helper.isTablet(context))
                    buildAppbarWithDateSelection(),

                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: buildOrderListSection(context),
                          ),
                          Helper.isTablet(context)
                              ? buildOrderedProductListWithNumberPad()
                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!Helper.isTablet(context))
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> DashBoardScreen(orderController.appController.posOpeningInfo)));

                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              const SizedBox(width: 16),
                              Text(AppLocalizations.of(context)!.new_order),
                            ],
                          ))),
                ),
              )
          ],
        ),
      ),
    );
  }

  buildonlineOfflineSelectorTAb() {
    return Obx(() => Row(
          children: [
            InkWell(
              onTap: () {
                orderController.setOfflineSelect(false);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: !orderController.isOfflineSelected.value
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.white,
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(32),
                    bottomStart: Radius.circular(32),
                  ),
                  border: Border.all(
                      color: !orderController.isOfflineSelected.value
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!orderController.isOfflineSelected.value)
                      Icon(Icons.check,
                          color: Theme.of(context).colorScheme.secondary),
                    TextView(
                      AppLocalizations.of(context)!.online_order,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      textColor: !orderController.isOfflineSelected.value
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.black,
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                orderController.setOfflineSelect(true);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: orderController.isOfflineSelected.value
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.white,
                  borderRadius: BorderRadiusDirectional.only(
                    topEnd: Radius.circular(32),
                    bottomEnd: Radius.circular(32),
                  ),
                  border: Border.all(
                      color: orderController.isOfflineSelected.value
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (orderController.isOfflineSelected.value)
                      Icon(Icons.check,
                          color: Theme.of(context).colorScheme.secondary),
                    TextView(
                      AppLocalizations.of(context)!.offline_order,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      textColor: orderController.isOfflineSelected.value
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.black,
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  buildOrderListSection(BuildContext context) {
    return Obx(
      () => CustomContainer(
        borderRadius: 8,
        customMargin: EdgeInsets.symmetric(
            horizontal: Helper.isTablet(context) ? 16 : 0,
            vertical: Helper.isTablet(context) ? 8 : 0),
        padding: 0,
        borderColor: Colors.grey[300],
        child: Column(children: [
          CustomContainer(
            color: Colors.grey[100],
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildonlineOfflineSelectorTAb(),
                if (Helper.isTablet(context))
                  FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> DashBoardScreen(orderController.appController.posOpeningInfo)));

                      },
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add),
                              const SizedBox(width: 16),
                              Text(AppLocalizations.of(context)!.new_order),
                            ],
                          )))
              ],
            ),
          ),
          SizedBox(height: 10),
          orderController.orderList.length > 0
              ? Expanded(
                  child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(height: 8,),
                      itemCount: orderController.orderList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Obx(() => Helper.isTablet(context)
                            ? LargeScreenOrderListTile(
                                orderInfo: orderController.orderList[index],
                                index: index,
                                selectedOrderIndex:
                                    orderController.selectedOrder.value,
                                onOrderSelected: () {
                                  orderController.setSelectedOrderIndex(index);
                                },
                              )
                            : SmallScreenOrderListTile(
                                orderInfo: orderController.orderList[index],
                                index: index,
                                selectedOrderIndex:
                                    orderController.selectedOrder.value,
                                onOrderSelected: () {
                                  orderController.setSelectedOrderIndex(index);
                                  if (!Helper.isTablet(context))
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                OrderDetailScreen(orderController
                                                    .orderList[index])));
                                },
                              ));
                      }))
              : Expanded(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/lottie/empty_order_list.json"),
                    TextView(
                      AppLocalizations.of(context)!.no_orders,
                      textSize: 24,
                      setBold: true,
                      alignment: Alignment.center,
                    ),
                  ],
                ))
        ]),
      ),
    );
  }

  buildOrderedProductListWithNumberPad() {
    return Obx(
      () => orderController.getSelectedOrder() != null
          ? CustomContainer(
              padding: 0,
              width: 550,
              
              child: OrderDetailScreen(orderController.getSelectedOrder()!))
          : (!Helper.isTablet(context)
              ? Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset("assets/lottie/empty_order_list.json"),
                      TextView(
                        AppLocalizations.of(context)!.no_orders,
                        textSize: 24,
                        setBold: true,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                )
              : Container()),
    );
  }

  handleDateSelection() async {
    final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020, 1, 1),
        lastDate: DateTime.now());

    if (range != null) {
      print(range);
      var firstDate = DateFormat('yyyy-MM-dd').format(range.start);
      var endDate = DateFormat('yyyy-MM-dd').format(range.end);
      var tempDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      int tempEpoch = range.end.microsecondsSinceEpoch;
      if (endDate == tempDate)
        tempEpoch = DateTime.now().microsecondsSinceEpoch;

      orderController
          .setDateRange("${firstDate.toString()} - ${endDate.toString()}");
      print(firstDate.toString() + "-" + endDate.toString());
      print(
          "date range micro--------> ${range.start.microsecondsSinceEpoch},\n $tempEpoch");
      orderController.fetchOrdersFromDbByDate(
          context, range.start.microsecondsSinceEpoch, tempEpoch);
    } else {
      orderController.setDateRange("");
    }
  }

  buildAppbarWithDateSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        // mainAxisSize: MainAxisSize.min,
        
        mainAxisAlignment: Helper.isTablet(context)
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (Helper.isTablet(context)) ...[
            CustomContainer(
              width: 50,
              height: 50,
             
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }else{
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> DashBoardScreen(orderController.appController.posOpeningInfo)));
                  }
                },
                child: Icon(Icons.arrow_back_ios)),
            const SizedBox(width: 16),
            TextView(
              AppLocalizations.of(context)!.orders,
              textStyle: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(width: 100),
          ],
          CustomContainer(
              onTap: () {
                handleDateSelection();
              },
              borderColor: Colors.black87,
              borderRadius: 32,
              customPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              height: 50,
              width: Helper.isTablet(context)
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.93,
              child: Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 8),
                    Icon(Icons.search),
                    const SizedBox(width: 32),
                    TextView(
                        orderController.dateRange.isNotEmpty
                            ? orderController.dateRange.value
                            : orderController.dateRange.value == "null"
                                ? AppLocalizations.of(context)!.select_date_range
                                : AppLocalizations.of(context)!.select_date_range,
                        textStyle: orderController.dateRange.isNotEmpty
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.bodyMedium),
                    Spacer(),
                    if (orderController.dateRange.isNotEmpty)
                      InkWell(
                        onTap: () {
                          orderController.setDateRange("");
                          orderController.fetchOrdersFromDb(context);
                        },
                        child: Icon(Icons.close, size: 30),
                      )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
