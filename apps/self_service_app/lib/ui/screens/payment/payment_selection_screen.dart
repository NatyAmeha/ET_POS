import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/const/shop_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/ui/screens/order/order_flow_screen.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class PaymentSelectionScreen extends StatelessWidget {
  var appController = Get.find<AppController>();
  PaymentSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      TextViewHelper("Checkout",
                          textStyle: Theme.of(context).textTheme.headlineLarge),
                      const SizedBox(height: 80),
                      ContainerHelper(
                        color: Theme.of(context).colorScheme.background,
                        borderColor: Colors.grey[300],
                        padding: 24,
                        borderRadius: 8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextViewHelper(
                              "Total",
                              textStyle: Theme.of(context).textTheme.displaySmall,
                              textColor: Theme.of(context).colorScheme.primary,
                            ),
                            TextViewHelper(
                              "${appController.getTotalAmountInfoOfCartTaxIncluded}",
                              textStyle: Theme.of(context).textTheme.displaySmall,
                              textColor: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 70),
                      TextViewHelper("How would you like to pay?",
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          maxline: 2,),
                      const SizedBox(height: 70),
                      if(appController.paymentMethods?.isNotEmpty == true)
                      GridView.builder(
                        itemCount: appController.paymentMethods!.length,
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 24, mainAxisSpacing: 20, mainAxisExtent: 300), 
                        itemBuilder: (context, index) {
                          var paymentMethodName = appController.paymentMethods![index].name;
                          return buildPaymentOptionTile(
                            context,
                            "${paymentMethodName}",
                            type: appController.paymentMethods![index].type ?? ShopConstant.SHOP_PAYMENT_METHOD_CASH,
                            onSelected: () {
                              appController.selectPaymentMethod(appController.paymentMethods![index]);
                            },
                          );
                      },)
                      
                    ],
                  ),
                ),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.only(bottom: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ContainerHelper(
                          width: null,
                          borderRadius: 32,
                          color: Theme.of(context).colorScheme.background,
                          customPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            children: [
                              Icon(Icons.arrow_back_ios),
                              const SizedBox(width: 24),
                              TextViewHelper("Back",
                                  textStyle:
                                      Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                        ),
                        FilledButton(onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => OrderFlowScreen(),));

                        }, child: Text("Continue")),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }

  buildPaymentOptionTile(BuildContext context, String name,{required String type, Function? onSelected}) {
    return Obx(
      () => ContainerHelper(
        onTap: () {
          onSelected?.call();
        },
        borderRadius: 20,
        margin: 20,
        padding: 32,
        borderWidth: appController.selectedPayment.value?.name == name ? 2 : 1,
        borderColor: appController.selectedPayment.value?.name == name
            ? Colors.green
            : Colors.grey[300],
        child: Column(children: [
          Icon(getIconForPaymentMethod(type), size: 75),
          const SizedBox(height: 60),
          TextViewHelper(name,
              textStyle: Theme.of(context).textTheme.titleLarge,
              textAlignment: TextAlign.center,
              maxline: 2),
        ]),
      ),
    );
  }

  IconData getIconForPaymentMethod(String paymentMethodType){
    if(paymentMethodType == ShopConstant.SHOP_PAYMENT_METHOD_BANK){
      return Icons.credit_card_outlined;
    }
    else if(paymentMethodType == ShopConstant.SHOP_PAYMENT_METHOD_QR_PAY){
      return Icons.qr_code;
    }
    
    else{
      return Icons.account_balance_wallet_outlined;
    }
  }
}
