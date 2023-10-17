import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/controller/printer_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/ui/screens/account/profile_screen.dart';
import 'package:odoo_pos/ui/screens/cart/hold_cart_list_screen.dart';
import 'package:odoo_pos/ui/screens/customer/customer_display_screen.dart';
import 'package:odoo_pos/ui/screens/home_screen.dart';
import 'package:odoo_pos/ui/screens/order/order_list_screen.dart';
import 'package:odoo_pos/ui/screens/printer/printer_list_screen.dart';
import 'package:odoo_pos/ui/screens/search_screen.dart';
import 'package:odoo_pos/ui/widgets/search_bar.dart';
import 'package:odoo_pos/ui/widgets/side_nav.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/invoice/model/printer_info.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';


class DashBoardScreen extends StatefulWidget {
  CashOpen? cashOpenData;

  DashBoardScreen(this.cashOpenData);

  @override
  State<StatefulWidget> createState() => DashBoardScreenState();
}

class DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  var appController = Get.find<AppController>();
  var shopController = Get.find<ShopController>();
  var orderController = Get.put(OrderController());
  var printerController = Get.put(PrinterController());
  int mSelectedIndex = 0;
  late StreamSubscription<dynamic> subscription;
  int? totalOrders;
  String? notes;
  double? bank, cash, openingBalance;
  int? id = 0;

  @override
  void initState() {
    Future.delayed(Duration.zero , (){
      subscription = shopController.appController.getNetworkStatus(context);
      printerController.listenPrinterconnectinStatus(context, HTPrinterType.NETWORK);
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    subscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    Navigator.of(context).pop();
    setState(() {
      mSelectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      Duration.zero,
      () async {
        id = await shopController.setOpeningBalanceForNewSession(widget.cashOpenData, context) ?? 0;
      },
    );

    return Scaffold(
      key: scaffoldKey,
      // hide app bar when order page is selected because order page has his own appbar
      appBar: !Helper.isTablet(context) && (mSelectedIndex == 1 || mSelectedIndex == 3) ? null : AppBar(
        automaticallyImplyLeading: Helper.isTablet(context),
        iconTheme: !Helper.isTablet(context) ? IconThemeData(color: Colors.black) : null,
        backgroundColor: !Helper.isTablet(context) ? Colors.white : Colors.black,
        title: !Helper.isTablet(context) 
        ? Searchbar(onSearchbarClicked: (){
              Navigator.of(context).push( MaterialPageRoute(builder: (c) => SearchScreen()));
            },
            onMenuButtonClicked: (){
              scaffoldKey.currentState?.openDrawer();
            },)
        : null,
        actions: [ 
          ...showAppbarAction()
        ],
      ) ,
      
      drawer: Obx(
        () => SideNav(selectedIndex: mSelectedIndex, customerDisplayWindowId: appController.customerDisplayWindowId.value, onPageSelected: (pageIndex) async{
          if(pageIndex != 1 && pageIndex !=5){
            _onItemTapped(pageIndex);
          }
          else{
            if (Helper.isTablet(context)) {
              _onItemTapped(pageIndex);
            } 
            mSelectedIndex = 1;
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OrderListScreen(),
            ));
          } 
        }, onQrCodeButtonClicked: (){
          orderController.getProductFromBarcodeAndAddToCart(context);
        },
        onCustomerCloseWindowClicked: (windowId) async {
          return appController.closeCustomerDisplayWindow(context, windowId);
        },
        onOpenCustomerWindowClicked: () async{
          var cartProducst = orderController.cartProducts;
          return appController.openCustomerDisplayWindow(context, cartProducst, Product.calculateTotalAmountOfCartTaxExcluded(cartProducst),  Product.calculateTotalTaxAmountofCart(orderController.cartProducts, appController.taxes), appController.selectedPosConfig?.currency.firstOrNull?.symbol, appController.selectedPosConfig?.currency.firstOrNull?.position,);
        },
          ),
      ),
    body: Obx((){
      return Helper.displayContent(
        canShow: true, 
        errorMessage: appController.splashResponseErrorMessage,
        isLoading: shopController.isLoading.value,
        context: context,
        content: LazyLoadIndexedStack(
        children: <Widget>[
          HomeScreen(),
          OrderListScreen(),
          HoldCartListScreen(),
          PrinterListScreen(onBackBtnClicked: (){
           setState(() {
            mSelectedIndex = 0;
           });
          },),
          ProfileScreen(),
          CustomerDisplayScreen(cartProducts: orderController.cartProducts , 
              totalAmount: Product.calculateTotalAmountOfCartTaxExcluded(orderController.cartProducts),
              totalVATAmount: Product.calculateTotalTaxAmountofCart(orderController.cartProducts, appController.taxes),
              currencyPosition: appController.selectedPosConfig?.currency.firstOrNull?.position, 
              currencySymbol: appController.selectedPosConfig?.currency.firstOrNull?.symbol,),
        ],
        index: mSelectedIndex,
      ),
    );
  })
    );
  }

  List<Widget> showAppbarAction(){
    return !Helper.isTablet(context) 
      ? [ 
          IconButton(onPressed: (){
            orderController.getProductFromBarcodeAndAddToCart(context);
          }, icon: Icon(Icons.qr_code),),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: TextView(AppLocalizations.of(context)!.posCloseProfile, textColor: Colors.black,), 
                onTap: () async {
                  shopController.closeShop(id!, context);
                },)
            ]
          ),

        ] 
      : [
        IconButton(onPressed: (){
          orderController.getProductFromBarcodeAndAddToCart(context);
        }, icon: Icon(Icons.qr_code),),
        TextButton(
            onPressed: () async {
              shopController.closeShop(id!, context);
            },
            child: TextView(
              AppLocalizations.of(context)!.posCloseProfile,
              setBold: true, textColor: Colors.white,
            ),
          ),
          Container(
            child: _holdCartActionButton(),
            margin: const EdgeInsets.all(8),
          ),
      ];
  }

  Widget _holdCartActionButton() {
    if (mSelectedIndex == 2) {
        return Obx(()=>
             Visibility(
              visible: orderController.holdOrderList.isNotEmpty,
              child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    if (orderController.holdOrderList.isNotEmpty) {
                      Helper.showAlertDialog(context,
                          title: AppLocalizations.of(context)!.hold_cart,
                          description: AppLocalizations.of(context)!.hold_cart_description,
                          onConfirm: () {
                            orderController.removeCurrentCartHold(false);                        
                      });
                    }
                  }),
            ),
          );
      } else {
        return mSelectedIndex == 0
            ? Obx(() => Visibility(
                  visible: orderController.cartCount > 0 ? true : false,
                  child: IconButton(
                      icon: Icon(Icons.stop_circle_outlined),
                      onPressed: () {
                        Helper.showAlertDialog(context,
                          title: AppLocalizations.of(context)!.hold_cart,
                          description: AppLocalizations.of(context)!.hold_cart_description,
                          onConfirm: () async{
                          orderController.holdCart(context);  
                      });
                      }),
                ))
            : Container();
      }
  }
  
}