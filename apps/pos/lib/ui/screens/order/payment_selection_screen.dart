import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/order_controller.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/number_pad_beta.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:odoo_pos/utils.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:hozmacore/features/payment/model/payment.dart';
import 'package:hozmacore/shared_models/Response.dart' as AppResponse;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class PaymentSelectionScreen extends StatefulWidget {
  PaymentSelectionScreen();

  @override
  State<StatefulWidget> createState() => PaymentState();
}

class PaymentState extends State<PaymentSelectionScreen> {
  var orderController = Get.find<OrderController>();

  TextEditingController mCashController = TextEditingController();
  TextEditingController mCardController = TextEditingController();
  String mChangeValue = "";
  bool isInvoiceOpted = false;
  

  var enteredPriceString = "0";

  var isDecimal = false;
  var isPriceEntryActivated = false;
  var priceSelectionChanged = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      orderController.setEnteredPrice(0.0);
      orderController.getPaymentMethodsFromDb(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    orderController.removeAllSelectedPaymentMethods();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.payment),
        toolbarHeight: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: OutlinedButton(
                onPressed: orderController.selectedPaymentList.isNotEmpty == true ? () {
                  DialogHelper.hideSoftKeyBoard();
                  orderController.validateAndPlaceOrder(context);
                } : null,
                style: OutlinedButton.styleFrom(
                    side: BorderSide(width: 1.0, color: orderController.selectedPaymentList.isNotEmpty == true ? Colors.white : Colors.grey,)),
                child: TextView(AppLocalizations.of(context)!.validate,
                    textColor: orderController.selectedPaymentList.isNotEmpty == true ? Colors.white : Colors.grey,
                    setBold: true,
                    alignment: Alignment.center)),
          )
        ],
      ),
      body: SafeArea(
        child:  Obx((){
          return Helper.displayContent(
            canShow: orderController.paymentMethodResponseStatus == AppResponse.Status.COMPLETED, 
            errorMessage: orderController.paymentMethodResponseErrorMsg,
            context: context,
            isLoading: orderController.paymentMethodResponseStatus == AppResponse.Status.LOADING || orderController.isLoading.value,
            content: buildMainLayout(orderController.paymentMethodList, context),
          );
        })
      ),
    );
  }

  buildMainLayout(List<Payment>? payments, BuildContext context) {
    return CustomContainer(
      customMargin: Helper.is900Breakpoint(context)
          ? EdgeInsets.symmetric(horizontal: 60, vertical: 20)
          : null,
      child: Column(
        children: [
          SizedBox(height: Helper.isTablet(context) ? 20 : 0),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (Helper.is900Breakpoint(context)) ...[
                  buildPaymentMethodSideBar(),
                  const SizedBox(width: 20),
                ],
                Expanded(
                  child: CustomContainer(
                    width: Helper.is900Breakpoint(context)
                        ? MediaQuery.of(context).size.width * 0.5
                        : MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.9,
                    alignment: Alignment.topCenter,
                    borderColor: Helper.is900Breakpoint(context)
                        ? Colors.grey[300]
                        : null,
                    margin: Helper.isTablet(context) ? 16 : 0,
                    padding: 0,
                    borderRadius: 6,
                    child: Column(
                      crossAxisAlignment: !Helper.is900Breakpoint(context)
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Helper.is900Breakpoint(context)
                            ? CustomContainer(
                                color: Colors.grey[100],
                                alignment: Alignment.center,
                                child: TextView(AppLocalizations.of(context)!.selected_payment,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .titleLarge),
                              )
                            : paymentMethodList(payments),
                        SizedBox(height:40),
                        paymentSummary(),
                        Helper.isTablet(context) ? SizedBox(height: 40) : Spacer(),
                        CustomContainer(
                          alignment: Alignment.bottomCenter,
                          customPadding:
                              EdgeInsets.symmetric(horizontal: Helper.isTablet(context) ? 50 : 0, vertical:16),
                          width: Helper.is900Breakpoint(context)
                              ? 750
                              : MediaQuery.of(context).size.width * 0.9,
                          height: Helper.isTablet(context) ? MediaQuery.of(context).size.height * 0.35 : MediaQuery.of(context).size.height * 0.4 ,
                          child: AbsorbPointer(
                            absorbing: !isPriceEntryActivated ||
                                orderController.selectedPaymentIndex == -1,
                            child: NumberPadBeta(
                              hideActionPad: true,
                              onNumberClicked: (value) {
                                setState(() {
                                  handleNumberClick(value);
                                });
                              },
                              additionalActions: [
                                CustomContainer(
                                  padding: 0,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  selectedBorderSidesForRadius: [8, 0, 0, 0],
                                  borderColor: Colors.grey[300],
                                  onTap: () {
                                    var enteredPrice =
                                        orderController.enteredPrice.value +
                                            10;
                                    orderController
                                        .setEnteredPrice(enteredPrice);
                                    setState(() {
                                      priceSelectionChanged = false;
                                      enteredPriceString = "$enteredPrice";
                                    });
                                  },
                                  child: TextView("+10",
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                      textColor: Colors.white),
                                ),
                                CustomContainer(
                                  padding: 0,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  borderColor: Colors.grey[300],
                                  onTap: () {
                                    var enteredPrice =
                                        orderController.enteredPrice.value +
                                            20;
                                    orderController
                                        .setEnteredPrice(enteredPrice);
                                    setState(() {
                                      priceSelectionChanged = false;
                                      enteredPriceString = "$enteredPrice";
                                    });
                                  },
                                  child: TextView("+20",
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                      textColor: Colors.white),
                                ),
                                CustomContainer(
                                  padding: 0,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  borderColor: Colors.grey[300],
                                  onTap: () {
                                    var enteredPrice =
                                        orderController.enteredPrice.value +
                                            30;
                                    orderController
                                        .setEnteredPrice(enteredPrice);

                                    setState(() {
                                      priceSelectionChanged = false;
                                      enteredPriceString = "$enteredPrice";
                                    });
                                  },
                                  child: TextView("+30",
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                      textColor: Colors.white),
                                ),
                                CustomContainer(
                                  padding: 0,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  borderColor: Colors.grey[300],
                                  selectedBorderSidesForRadius: [0, 0, 0, 8],
                                  onTap: () {
                                    setState(() {
                                      if (enteredPriceString != "0") {
                                        if (enteredPriceString.length == 1) {
                                          enteredPriceString = "0";
                                        } else {
                                          enteredPriceString =
                                              enteredPriceString.substring(
                                                  0,
                                                  enteredPriceString.length -
                                                      1);
                                        }
                                        var enteredPrice =
                                            double.parse(enteredPriceString);
                                        orderController
                                            .setEnteredPrice(enteredPrice);
                                      }
                                    });
                                  },
                                  child: Icon(Icons.backspace_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  handleNumberClick(String value) {
    if (enteredPriceString != "0" && !priceSelectionChanged) {
      if (value == ".") {
        isDecimal = true;
      }
      if (enteredPriceString.contains(".") &&
          enteredPriceString
                  .split(".")
                  .elementAtOrNull(1)
                  ?.length
                  .isGreaterThan(2) ==
              true) {
      } else {
        enteredPriceString += value;
      }
    } else {
      enteredPriceString = value;
    }
    orderController.setEnteredPrice(double.parse(enteredPriceString));
    priceSelectionChanged = false;
  }

  buildPaymentMethodSideBar() {
    return CustomContainer(
      borderColor: Colors.grey[300],
      borderRadius: 6,
      width: MediaQuery.of(context).size.width * 0.3,
      margin: 16,
      padding: 0,
      child: Column(
        children: [
          CustomContainer(
            color: Colors.grey[100],
            child: TextView(AppLocalizations.of(context)!.payment_methods,
                textStyle: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 16),
          paymentMethodList(orderController.paymentMethodList),
          if(Helper.is900Breakpoint(context))...[
                      const SizedBox(height: 32),
                      TextView(
                        "${AppLocalizations.of(context)!.total_amount}:  ${orderController.appController.getPriceStringWithConfiguration(Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes))}",
                        textStyle: Theme.of(context).textTheme.displayMedium,
                        textColor: Theme.of(context).colorScheme.primary)
                    ]
        ],
      ),
    );
  }
  Widget paymentSummary() {
    return CustomContainer(
      customMargin:
          EdgeInsets.symmetric(horizontal: Helper.isTablet(context) ? 40 : 0),
      borderColor: Colors.grey[400],
      alignment: Alignment.topCenter,
      borderRadius: 6,
      width: Helper.is900Breakpoint(context)
          ? 800
          : MediaQuery.of(context).size.width * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Obx(
            () => TextView(
                orderController.appController.getPriceStringWithConfiguration(
                    orderController.enteredPrice.value),
                textStyle: Theme.of(context).textTheme.headlineLarge,
                textColor: isPriceEntryActivated
                    ? Theme.of(context).colorScheme.tertiary
                    : Colors.grey),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextView(
                    AppLocalizations.of(context)!.paid_by_customer,
                    textStyle: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextView(
                    "${orderController.appController.getPriceStringWithConfiguration(orderController.getTotalAmountPaidByCustomer())}",
                    textColor: Theme.of(context).colorScheme.tertiary,
                    textStyle: Theme.of(context).textTheme.titleMedium,
                  )
                ],
              ),
              Spacer(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextView(showPrice() >= 0 ?  AppLocalizations.of(context)!.remaining_amount :  AppLocalizations.of(context)!.returned_amount,
                        textStyle: Theme.of(context).textTheme.titleSmall),
                    TextView(
                      "${orderController.appController.getPriceStringWithConfiguration(showPrice())}",
                      textStyle: Theme.of(context).textTheme.titleMedium,
                      textColor: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget paymentMethodList(List<Payment>? payments) {
    return Helper.isTablet(context)
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: payments!.length,
            itemBuilder: (BuildContext context, int index) {
              var payment = orderController.paymentMethodList[index];
              return Obx(() => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: orderController.isPaymentInSelectedList(payment)
                      ? FilledButton(
                          onPressed: () {
                            orderController.getSelectedPaymentMethod(index);
                            setState(() {
                              priceSelectionChanged = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (orderController.selectedPaymentIndex ==
                                    index) ...[
                                  Icon(Icons.check_circle),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                    "${payment.name!}  ${orderController.appController.getPriceStringWithConfiguration(double.parse(payment.amountTendered ?? "0.0"))} "),
                                Spacer(),
                                IconButton(
                                    onPressed: () {
                                      orderController.deletePayment(payment, index);
                                      setState(() {
                                        isPriceEntryActivated = true;
                                        priceSelectionChanged = true;
                                      });
                                    },
                                    icon: Icon(Icons.close))
                              ],
                            ),
                          ))
                      : OutlinedButton(
                          onPressed: () {
                            orderController.addPayment(payment, index);
                            setState(() {
                              isPriceEntryActivated = true;
                              priceSelectionChanged = true;
                              var remainingPrice = Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes) - orderController.getTotalAmountPaidByCustomer();
                              // add remaining price to selected payment 
                              if(remainingPrice > 0){
                                enteredPriceString = remainingPrice.toString();
                                orderController.setEnteredPrice(remainingPrice); 
                              }
                            });
                          },
                          style: OutlinedButton.styleFrom(side: BorderSide(width: 1.0, color: Colors.grey[300]!)),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              child: Text(
                                  "${payment.name!}  ${orderController.appController.getPriceStringWithConfiguration(double.parse(payment.amountTendered ?? "0.0"))} ")),
                        )));
            })
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextView(AppLocalizations.of(context)!.select_payment,textStyle: Theme.of(context).textTheme.titleLarge),
                  
                ],
              ),
              const SizedBox(height: 30),
              if (payments?.isNotEmpty == true)
                SizedBox(
                  height: 50,
                  child: Obx(
                    () => ListView.separated(
                      shrinkWrap: true,
                      itemCount: orderController.paymentMethodList.length,
                      scrollDirection: Axis.horizontal,
                      separatorBuilder: (context, index) => SizedBox(width: 10),
                      itemBuilder: (BuildContext context, int index) {
                        var payment = orderController.paymentMethodList[index];
                        return Obx(
                          () => orderController
                                  .isPaymentInSelectedList(payment)
                              ? FilledButton(
                                  onPressed: () {
                                    orderController
                                        .getSelectedPaymentMethod(index);

                                    setState(() {
                                      priceSelectionChanged = true;
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (orderController
                                              .selectedPaymentIndex ==
                                          index) ...[
                                        Icon(Icons.check_circle),
                                        const SizedBox(width: 8),
                                      ],
                                      Text(
                                          "${payment.name!}  ${orderController.appController.getPriceStringWithConfiguration(double.parse(payment.amountTendered ?? "0.0"))} "),
                                      const SizedBox(width: 10),
                                      IconButton(
                                          onPressed: () {
                                            orderController.deletePayment(
                                                payment, index);
                                            setState(() {
                                              isPriceEntryActivated = true;
                                              priceSelectionChanged = true;
                                            });
                                          },
                                          icon: Icon(Icons.close))
                                    ],
                                  ))
                              : OutlinedButton(
                                  onPressed: () {
                                    orderController.addPayment(
                                        payment, index);
                                    setState(() {
                                      isPriceEntryActivated = true;
                                      priceSelectionChanged = true;
                                      var remainingPrice = Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes) -orderController.getTotalAmountPaidByCustomer();
                                      // add remaining price to selected payment 
                                      if(remainingPrice > 0){
                                        enteredPriceString = remainingPrice.toString();
                                        orderController.setEnteredPrice(remainingPrice); 
                                      }
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(side: BorderSide(width: 1.0, color: Colors.grey[300]!)),

                                  child: Text(
                                      "${payment.name!}  ${orderController.appController.getPriceStringWithConfiguration(double.parse(payment.amountTendered ?? "0.0"))} "),
                                ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
  }

  double showPrice() {
    // for order return
    if (Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes) < 0) {
      return Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes) + orderController.getTotalAmountPaidByCustomer();
    }
    // for normal order
    else {
      return Product.getTotalAmountOfCartTaxIncluded(orderController.cartProducts, orderController.appController.taxes) - orderController.getTotalAmountPaidByCustomer();
    }
  }
}
