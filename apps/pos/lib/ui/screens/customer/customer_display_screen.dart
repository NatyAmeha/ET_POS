import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hozmacore/constants/constants.dart';
import 'package:window_manager/window_manager.dart';


class CustomerDisplayScreen extends StatefulWidget {
  List<Product> cartProducts;
  double totalAmount;
  double totalVATAmount;
  String? currencyPosition;
  String? currencySymbol;
  CustomerDisplayScreen({
    super.key,
    required this.cartProducts,
    required this.totalAmount,
    required this.totalVATAmount,
    this.currencyPosition,
    this.currencySymbol,
  });

  @override
  State<CustomerDisplayScreen> createState() => _CustomerDisplayScreenState();
}

class _CustomerDisplayScreenState extends State<CustomerDisplayScreen> with WindowListener {
  var scrollController = ScrollController();
  var appController = Get.find<AppController>();

  List<Product> _products = [];
  double _total = 0;
  double _vat = 0;
  String _currencyPosition = "after";
  String _currencySymbol = "USD";
  @override
  void initState() {
    super.initState();
    setState(() {
      _products = widget.cartProducts;
      _total = widget.totalAmount;
    _vat = widget.totalVATAmount;
    _currencySymbol = widget.currencySymbol ?? "USD";;
    _currencyPosition = widget.currencyPosition ?? "after";
    });
    DesktopMultiWindow.setMethodHandler(receiveMessageFromPosApp); 
  }

  Future<dynamic> receiveMessageFromPosApp(MethodCall call ,  windowId) async {
    if(call.arguments == MultiWindowMessage.CLOSE_WINDOW.name){
      appController.canCloseCustomerWindowFromMainWindow = true;
    }
    else{
      var message = jsonDecode(call.arguments);
      var product = message["products"] as List<dynamic>;
      var cartProducts = product.map((e) => Product.fromJson(e)).toList();
      setState(() {
        _products = cartProducts;
        _total = message["totalAmount"];
        _vat = message["totalVATAmount"];
        _currencyPosition = message["currencyPosition"];
        _currencySymbol = message["currencySymbol"];
      });
      moveToEndofTheList();
    }
  }

  @override
  Widget build(BuildContext context) {
    moveToEndofTheList();
    return Scaffold(
      body: CustomContainer(
        height: double.infinity,
        width: double.infinity,
        padding: 0,
        child: Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomContainer(
                      child: Column(
                        children: [
                          TextView(AppLocalizations.of(context)!.shopping_cart,
                              textStyle:
                                  Theme.of(context).textTheme.titleLarge),
                          Divider(height: 40, color: Colors.black),
                          Expanded(
                            child: ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.only(bottom: 160),
                              itemCount: _products.length,
                              separatorBuilder: (context, index) =>
                                  Divider(height: 12),
                              itemBuilder: (context, index) {
                                return buildCartItem(
                                    _products[index], context);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                      child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomContainer(
                      height: 150,
                      borderColor: Colors.grey[400],
                      borderRadius: 0,
                      width: null,
                      color: Colors.grey[100],
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextView(
                                      "${AppLocalizations.of(context)!.subtotal} ${getPriceStringWithConfiguration(_total)}",
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displayMedium,
                                      setBold: false,
                                      textColor: Colors.black87,
                                    ),
                                    const SizedBox(height: 8),
                                    TextView(
                                      "${AppLocalizations.of(context)!.cartVAT} ${getPriceStringWithConfiguration(_vat)}",
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                      textColor: Colors.black54,
                                      setBold: false,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            VerticalDivider(color: Colors.grey),
                            Expanded(
                              child: CustomContainer(
                                  padding: 0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextView(
                                          AppLocalizations.of(context)!
                                              .cartTotal,
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          setBold: true),
                                      const SizedBox(height: 8),
                                      TextView(
                                          "${getPriceStringWithConfiguration(_total + _vat)}",
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                          setBold: true),
                                    ],
                                  )),
                            )
                          ]),
                    ),
                  ))
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image(
                        fit: BoxFit.fill,
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        image: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? AssetImage('assets/images/customer_display.jpeg')
                            : AssetImage(
                                'assets/images/customer_display.jpeg')),
                  ),
                  Positioned.fill(
                    child: CustomContainer(
                        margin: 0,
                        padding: 0,
                        color: Colors.black54,
                        child: SizedBox()),
                  ),
                  Positioned.fill(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 24),
                    child: Column(
                      children: [
                        TextView(AppLocalizations.of(context)!.customer_display,
                            textStyle:
                                Theme.of(context).textTheme.displayMedium,
                            textColor: Colors.white),
                        Spacer(),
                        TextView(AppLocalizations.of(context)!.powered_by,
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            textColor: Colors.white),
                        const SizedBox(height: 10),
                        TextView(
                          AppLocalizations.of(context)!.company_name,
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          textColor: Colors.white,
                        )
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartItem(Product product, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextView(
                "${product.display_name} (${getPriceStringWithConfiguration(double.parse(product.unit_price!))}) X${product.unitCount}",
                textStyle: Theme.of(context).textTheme.titleLarge,
                setBold: true,
              ),
              if(product.discount != null) ...[
            const SizedBox(height: 2),
            TextView("${AppLocalizations.of(context)!.discount} ${product.discount!}%", 
            textStyle: Theme.of(context).textTheme.bodyLarge,
            textColor: Colors.green,)              
          ]
          ],
          ),
          TextView(
            "${getPriceStringWithConfiguration(product.calculateFinalPriceTaxIncluded(appController.taxes))}",
            textStyle: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
  moveToEndofTheList(){
    Future.delayed(Duration.zero , (){
        scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1),
        curve: Curves.fastOutSlowIn);
    });
  }

  String getPriceStringWithConfiguration(double price){
     return _currencyPosition == "before"
                    ? "$_currencySymbol ${price.toStringAsFixed(2)}"
                    : "${price.toStringAsFixed(2)} $_currencySymbol";

  }
}
