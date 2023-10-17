import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/shared_models/Response.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/controller/shop_controller.dart';
import 'package:odoo_pos/ui/screens/customer/customer_selection_screen.dart';
import 'package:odoo_pos/ui/screens/order/payment_selection_screen.dart';
import 'package:odoo_pos/ui/widgets/CommonWidgets.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/number_pad_beta.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:hozmacore/constants/constants.dart';



class CartScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  var shopController = Get.find<ShopController>();
  var orderController = Get.find<OrderController>();
  var scrollController = ScrollController();
  static const int QTY = 0;
  static const int PRICE = 1;
  static const int DISC = 2;

  int mActionValue = QTY;
  double mUnitTax = 0.0;
  String? mDisc = "";
  bool isCheck = false;
  bool resetQty = true;
  bool resetPrice = true;
  bool resetDiscount = true;
  bool decimalAdded = false;
  int decimalPoint = 0;
  var preventScrollWhenUserClickProductInCart = false;

  @override
  void initState() {
    Future.delayed(Duration.zero , (){
      orderController.getCartProducts();
    });
    orderController.appController.onSelectedProductIndexchangedInCart((){
      if(!preventScrollWhenUserClickProductInCart){
        scrollToSelectedProductInCart();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isCheck?portrait(context):  Helper.isTablet(context)
        ? buildBodyUI( context)
        : portrait(context);
  }

  portrait(BuildContext context) {
    isCheck = true;
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.cart_page),
          actions: [
            Obx(() => Visibility(
                  visible: orderController.cartCount > 0 ? true : false,
                  child: IconButton(
                      icon: Icon(Icons.stop_circle_outlined),
                      onPressed: () {
                        
                        Helper.showAlertDialog(context,
                          title: AppLocalizations.of(context)!.hold_cart,
                          description: AppLocalizations.of(context)!.hold_cart_description,
                          onConfirm: () async{
                          orderController.holdCart(context);  
                          // notifier.removeList();                       
                      });
                      }),
                ))
            
          ],
        ),
        body: buildBodyUI(context)
    );
  }

  setActionValue(int value) {
    setState(() {
      mActionValue = value;
      resetQty = true;
      resetPrice = true;
      resetDiscount = true;
      decimalAdded = false;
      decimalPoint = 0;
    });
  }

  selectCustomerFromList(BuildContext context) async {
    var customer = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => new CustomerSelectionPage()));
    orderController.setCustomer(customer);
  }


  buildBodyUI( BuildContext context) {
    return Obx((){
      switch(orderController.cartProductsResponseStatus){
        case Status.LOADING:
          return CommonWidgets.showProgressbar();   
        case Status.COMPLETED:
          return CustomContainer(
            borderRadius: 0,
            width: getCartLayoutWidth(context),
            child: Column(
              children: [
                cartProductList(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                Expanded(child: numberPad(context)),
              ],
            ),
          );
        case Status.ERROR:
          return CommonWidgets.showErrorMessage(context, shopController.selectedShop.value.message?? "");
      }
    });   
  }

  cartProductList() {
    return CustomContainer(
      borderRadius: 6,
      padding: 0,
      borderColor: Colors.grey[300],
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end, 
        children: [
         Container(
          child: 
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              itemCount: orderController.cartCount,
              separatorBuilder: (context, index) => Divider(height: 0),
              itemBuilder: (BuildContext context, int index) {
                var product = orderController.cartProducts[index];
                return productItemLayout(product, index, onProductSelected: (){
                  preventScrollWhenUserClickProductInCart = true;
                  orderController.updateSelectedProductIndexInCart(index);
                  preventScrollWhenUserClickProductInCart = false;
                });
              }),
          ),),
        
          Padding(
            padding :  const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              Divider(thickness: 1, color: Colors.grey),
            TextView(
              AppLocalizations.of(context)!.cartTotal + ": " + Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes).toStringAsFixed(2),
              textSize: 24,
              setBold: true,
            ),
            TextView(AppLocalizations.of(context)!.cartVAT + ":  " + Product.calculateTotalTaxAmountofCart(orderController.cartProducts, orderController.appController.taxes).toStringAsFixed(2),textSize: 18,)
              
            ],),
          )
        ],
    ),
    );
  }
  


  double getCartLayoutWidth(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape &&
            MediaQuery.of(context).size.height > 600
        ? MediaQuery.of(context).size.width / 2.9
        : MediaQuery.of(context).size.width;
  }

  scrollToSelectedProductInCart(){
    Future.delayed(Duration.zero , (){
      if(scrollController.positions.isNotEmpty){
        scrollController.animateTo(
        (90 * orderController.selectedProductIndexInCart).toDouble(),
        duration: const Duration(milliseconds: 1),
        curve: Curves.fastOutSlowIn
        );
      }
      
    });
  }

  numberPad(BuildContext context) {
    return Obx(
      ()=> AbsorbPointer(
        absorbing: orderController.cartProducts.length == 0,
        child: NumberPadBeta(
          initialAction: NumberPadAction.QTY.name,
          heightFactorForActionPad: 2,
          widthFactorForActionPad: 1.5,
          additionalActions: [
            CustomContainer(padding: 0,color: Colors.black,borderColor: Colors.grey,
              onTap: ()async {
                var customer = await Navigator.push(context, MaterialPageRoute(builder: (context) => new CustomerSelectionPage()));
                  orderController.setCustomer(customer);
              },
              selectedBorderSidesForRadius: [8,0,0,0],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle_outlined,
                  color:Colors.white, size: 30),
                  Flexible(
                    child: TextView(
                        orderController.selectedCustomer.value == null
                            ? AppLocalizations.of(context)!.cartCustomer
                            : orderController.selectedCustomer.value!.name!,
                        padding: 4,
                        textColor: Colors.white),
                  ),
                ],
              ),
            ),
            CustomContainer(
                onTap: () {
                  if (orderController.cartProducts.isNotEmpty){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new PaymentSelectionScreen()));
                  }
                  else{
                    Helper.showSnackbar(
                      context, 
                      AppLocalizations.of(context)!.cart_is_empty, 
                      color: Colors.redAccent,
                      prefixIcon: Icons.error_outline
                    );
                  }
                },
                padding: 0,
                selectedBorderSidesForRadius: [0,0,0,8],
                color: Theme.of(context).colorScheme.primary,
                width: getCartLayoutWidth(context) / 4,
                height: MediaQuery.of(context).size.height / 6,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 30,
                        color: Colors.white,
                      ),
                      Flexible(
                        child: TextView(
                          AppLocalizations.of(context)!.cartPayment,
                          padding: 4,
                          textColor: Colors.white,
                        ),
                      )
                    ])),
          ],
          onNumberClicked: (value) {
            setState(() {
              if (value == ".") {
                if (mActionValue != QTY) {
                  setKeyboardValue(-1);
                }
              } else {
                setKeyboardValue(int.parse(value));
              }
            });
            scrollToSelectedProductInCart();
          },
          onActionSelected: (value) {
            setState(() {
              if (value == NumberPadAction.QTY.name) {
                setActionValue(QTY);
              } else if (value == NumberPadAction.PRICE.name) {
                setActionValue(PRICE);
              } else if (value == NumberPadAction.DISCOUNT.name) {
                setActionValue(DISC);
              } else if (value == NumberPadAction.DELETE.name) {
                onDelButtonClicked(context);
              }
            });
          },
        ),
      ),
    );
  }

  

  productItemLayout(Product data, int index, {Function? onProductSelected}) {
    return Column(children: [
      Obx((){
        return CustomContainer(
          onTap: (){
            onProductSelected?.call();
          },
          padding: 12,
          color: orderController.selectedProductIndexInCart == index ? Theme.of(context).colorScheme.secondaryContainer : Colors.white, 
          borderRadius: 0,
            child:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  TextView(
                    data.display_name,
                    setBold: true,
                    textStyle: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  TextView(
                    data.priceWithQtyAndUom(),
                    textSize: 16,
                  ),
                  const SizedBox(height: 2),
                  data.discount != null
                      ? TextView(
                          data.discountInfo(),
                          textSize: 16,
                        )
                      : Container()
                ]),
              ),
              TextView(
                shopController.appController.getPriceStringWithConfiguration(data.calculateFinalPriceTaxIncluded(shopController.appController.taxes)),
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ]));
        }
      )
    ]);
  }

  setKeyboardValue(int value) {
    var selectedProduct = orderController.cartProducts[shopController.selectedProductIndexInCart];
    switch (mActionValue) {
      case QTY:
        if (selectedProduct.unitCount! < 30000 && resetQty) {
          selectedProduct.unitCount = value;
          resetQty = false;
          orderController.updateProductInCart(context , selectedProduct);
        } else if (selectedProduct.unitCount! < 30000) {
          selectedProduct.unitCount = int.parse(
              selectedProduct.unitCount.toString() + value.toString());
          orderController.updateProductInCart(context, selectedProduct);
        }
        break;
      case DISC:
        if(value > 0 && resetDiscount){
          mDisc = value.toString();
          resetDiscount = false;
        }
        else if(value == -1 && !decimalAdded){
          if(!resetDiscount){
            mDisc = selectedProduct.discount.toString() + ".";
            decimalAdded = true;
            decimalPoint = 0;
          }
        }
        else if(value != -1 && double.parse(mDisc! + value.toString()) < 100.0 &&  decimalPoint < 2){
          mDisc = selectedProduct.discount.toString() +value.toString();
          if(decimalAdded){
              decimalPoint++;
          }
        }
        selectedProduct.discount = mDisc;
        orderController.updateProductInCart(context,  selectedProduct);
        break;
      case PRICE:
        mUnitTax = double.parse(selectedProduct.unitTax!);
        if (value > 0 && resetPrice) {
          selectedProduct.unit_price = value.toString();
          resetPrice = false;
        } 
        else if(value == -1 && !decimalAdded){
          if(!resetPrice){
          selectedProduct.unit_price = selectedProduct.unit_price.toString() + ".";
          decimalAdded = true;
          decimalPoint = 0;
          }
        }
        else{
          if(decimalPoint < 2 && value != -1){
            selectedProduct.unit_price = selectedProduct.unit_price.toString() + value.toString();
            if(decimalAdded){
              decimalPoint++;
            }
          }
        
        }
        selectedProduct.price_tax_inclusive =
            (((mUnitTax * double.parse(selectedProduct.unit_price!))) +
                    double.parse(selectedProduct.unit_price!))
                .toString();
        orderController.updateProductInCart(context, selectedProduct);
        break;
    }
  }

  void onDelButtonClicked(BuildContext context) {
    var selectedProduct =
        orderController.cartProducts[shopController.selectedProductIndexInCart];
    switch (mActionValue) {
      case QTY:
        if (selectedProduct.unitCount! < 10 && selectedProduct.unitCount! > 0) {
          selectedProduct.unitCount = 0;
          resetQty = true;
        } else if (selectedProduct.unitCount! <= 0) {
          resetQty = true;
          selectedProduct.unitCount = 0;
          orderController.updateProductInCart(context , selectedProduct);
        } else {
          selectedProduct.unitCount = (selectedProduct.unitCount! / 10).toInt();
          orderController.updateProductInCart(context , selectedProduct);
        }
        break;
      case DISC:
        if (selectedProduct.discount != null  && selectedProduct.discount!.length <= 1){
            selectedProduct.discount = null;
            mDisc = "";
            resetDiscount = true;
            decimalAdded = false;
            decimalPoint = 0;
        }
        else if (selectedProduct.discount != null ) {
          if(selectedProduct.discount![selectedProduct.discount!.length -1]  == "."){
            decimalAdded = false;
            decimalPoint = 0;
          }
          var discount = selectedProduct.discount;
          selectedProduct.discount =discount.toString().substring(0, discount.toString().length - 1);
          mDisc = selectedProduct.discount;
          if(decimalPoint > 0){
            decimalPoint--;
          }
          orderController.updateProductInCart(context , selectedProduct);
        } else {
          selectedProduct.discount = null;
          mDisc = "";
          resetDiscount = true;
          decimalAdded = false;
          decimalPoint = 0;
        }
        break;
      case PRICE:
        if (selectedProduct.unit_price != null &&  selectedProduct.unit_price!.length <= 1){
          selectedProduct.unit_price = "0";
          selectedProduct.price_tax_inclusive = "0";
          orderController.updateProductInCart(context , selectedProduct);
          resetPrice = true;
          decimalAdded = false;
          decimalPoint = 0;
        }
        else if(selectedProduct.unit_price != null){
          if(selectedProduct.unit_price![selectedProduct.unit_price!.length -1]  == "."){
            decimalAdded = false;
            decimalPoint = 0;
          }
          selectedProduct.unit_price = selectedProduct.unit_price!.substring(0, selectedProduct.unit_price!.length - 1);
          if(decimalPoint > 0){
            decimalPoint--;
          }
          orderController.updateProductInCart(context , selectedProduct);
        }
        else {
          selectedProduct.unit_price = orderController.cartProducts[shopController.selectedProductIndexInCart].unit_price;
          resetPrice = true;
          decimalAdded = false;
          decimalPoint = 0;
        }
        break;
    }
  }
}
