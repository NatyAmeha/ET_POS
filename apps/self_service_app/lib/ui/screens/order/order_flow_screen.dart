import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/controller/order_controller.dart';
import 'package:self_service_app/ui/screens/home_screen.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/custom_text_field.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';
import 'package:self_service_app/utils/ui_helper.dart';

class OrderFlowScreen extends StatefulWidget {
  const OrderFlowScreen({super.key});

  @override
  State<OrderFlowScreen> createState() => _OrderFlowScreenState();
}

class _OrderFlowScreenState extends State<OrderFlowScreen> {
  var loadOrderController = Get.lazyPut(() => OrderController());
  var orderController = Get.find<OrderController>();
  var currentStep = 0;
  var isLoading = false;
  var nameController = TextEditingController();
  var emailOrPhoneController = TextEditingController();
  var isNameNotEmpty = false;
  var isEmailOrPhoneFieldNotEmpty = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    if (currentStep < 4) ...[
                      const SizedBox(height: 50),
                      TextViewHelper("Payment",
                          textStyle: Theme.of(context).textTheme.headlineLarge),
                    ],
                    const SizedBox(height: 70),
                    Expanded(
                      child: Stepper(
                        connectorThickness: 5,
                        margin: EdgeInsets.zero,
                        connectorColor:
                            MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.green;
                          } else {
                            return Colors.grey;
                          }
                        }),
                        type: StepperType.horizontal,
                        currentStep: currentStep,
                        elevation: 0,
                        controlsBuilder: (context, details) => SizedBox(),
                        steps: [
                          Step(
                            title: SizedBox(),
                            state: currentStep > 0
                                ? StepState.complete
                                : StepState.indexed,
                            isActive: currentStep >= 0,
                            content: buildName(context),
                          ),
                          Step(
                            title: SizedBox(),
                            state: currentStep > 1
                                ? StepState.complete
                                : StepState.indexed,
                            isActive: currentStep >= 1,
                            content: buildCompletePayment(context),
                          ),
                          Step(
                            title: SizedBox(),
                            state: currentStep > 2
                                ? StepState.complete
                                : StepState.indexed,
                            isActive: currentStep >= 2,
                            content: buildReceiptOption(context),
                          ),
                          Step(
                            title: SizedBox(),
                            state: currentStep > 3
                                ? StepState.complete
                                : StepState.indexed,
                            isActive: currentStep >= 3,
                            content: buildemailorPhoneNumberInput(context),
                          ),
                          Step(
                              title: SizedBox(),
                              state: currentStep > 4
                                  ? StepState.complete
                                  : StepState.indexed,
                              isActive: currentStep >= 4,
                              content: buildOrderComplete(context))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            if (currentStep < 4) buildBottomActionButtons(),
            if (isLoading) UiHelper.showProgressDialog(isLoading)
          ],
        ),
      ),
    );
  }

  buildName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 50),
          TextViewHelper("Please Enter your Name",
              textStyle: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 75),
          TextFieldHelper(
            hint: "Your name here",
            controller: nameController,
            onchanged: (value) {
              setState(() {
                isNameNotEmpty = value.isNotEmpty;
              });
            },
          ),
          const SizedBox(height: 75),
          SizedBox(
            width: 250,
            child: FilledButton(
              onPressed: isNameNotEmpty
                  ? () {
                      orderController.userName = nameController.text.toString();
                      setState(() {
                        currentStep = currentStep + 1;
                      });
                    }
                  : null,
              child: Text("Next"),
            ),
          )
        ],
      ),
    );
  }

  buildCompletePayment(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        TextViewHelper("Complete Payment on device",
            textStyle: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 120),
        Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 300,
          child: Image.asset("assets/images/complete_payment.png"),
        )
      ],
    );
  }

  buildReceiptOption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            TextViewHelper(
              "How would you like to receive your receipt?",
              textStyle: Theme.of(context).textTheme.displaySmall,
              maxline: 2,
              textAlignment: TextAlign.center,
            ),
            const SizedBox(height: 100),
            ContainerHelper(
              onTap: () {
                orderController.appController.changeReceiptOption(ReceiptOptions.SMS);
              },
              borderRadius: 32,
              color: Colors.white,
              borderColor:  orderController.appController.selectedReceiptOption.value ==
                      ReceiptOptions.SMS.name
                  ? Colors.green
                  : Colors.grey[300],
              child: TextViewHelper("Via text message (SMS)",
                  textStyle: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 40),
            ContainerHelper(
              onTap: () {
                 orderController.appController.changeReceiptOption(ReceiptOptions.EMAIL);
              },
              borderRadius: 32,
              color: Colors.white,
              borderColor:  orderController.appController.selectedReceiptOption.value ==
                      ReceiptOptions.EMAIL.name
                  ? Colors.green
                  : Colors.grey[300],
              child: TextViewHelper(
                "Via Email",
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 40),
            ContainerHelper(
              onTap: () {
                 orderController.appController.changeReceiptOption(ReceiptOptions.PRINTED);
              },
              color: Colors.white,
              borderRadius: 32,
              borderColor:  orderController.appController.selectedReceiptOption.value ==
                      ReceiptOptions.PRINTED.name
                  ? Colors.green
                  : Colors.grey[300],
              child: TextViewHelper("Printed",
                  textStyle: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  buildemailorPhoneNumberInput(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 50),
        TextViewHelper(showEmailOrPhoneInfo(),
            textStyle: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 50),
        TextFieldHelper(
          hint: "Email address",
          label: orderController.appController.selectedReceiptOption == ReceiptOptions.SMS
              ? "Phone number"
              : "Email address",
          controller: emailOrPhoneController,
          onchanged: (value) {
            setState(() {
              isEmailOrPhoneFieldNotEmpty = value.isNotEmpty;
            });
          },
        ),
        const SizedBox(height: 50),
        SizedBox(
          width: 250,
          child: FilledButton(
            onPressed: isEmailOrPhoneFieldNotEmpty
                ? () {
                    placeAnOrder();
                  }
                : null,
            child: Text("Submit"),
          ),
        )
      ],
    );
  }

  buildOrderComplete(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 50),
        TextViewHelper("Order complete!",
            textStyle: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 80),
        Icon(Icons.check_circle_outline,
            size: 140, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 80),
        TextViewHelper("Order number",
            textStyle: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 30),
        TextViewHelper(
          "${orderController.orderCounter}",
          textStyle: Theme.of(context).textTheme.headlineLarge,
          textColor: Theme.of(context).colorScheme.primary,
          setBold: true,
        ),
        const SizedBox(height: 120),
        TextViewHelper("Pick up your order at the counter",
            textStyle: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 100),
        SizedBox(
          width: 250,
          child: FilledButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (Route<dynamic> route) => false);
              },
              child: Text("Order again")),
        )
      ],
    );
  }

  buildBottomActionButtons() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 32, right: 32, bottom: 50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ContainerHelper(
              width: null,
              borderRadius: 32,
              customPadding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              color: Theme.of(context).colorScheme.background,
              onTap: () {
                setState(() {
                  if (currentStep > 0) {
                    currentStep = currentStep - 1;
                  } else {
                    Navigator.of(context).pop();
                  }
                });
              },
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios),
                  const SizedBox(width: 24),
                  TextViewHelper("Back",
                      textStyle: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            if (currentStep == 1 || currentStep == 2)
              FilledButton(
                onPressed: () {
                  setState(() {
                    currentStep = currentStep + 1;
                  });
                },
                child: Text("Continue"),
              ),
          ],
        ),
      ),
    );
  }

  showEmailOrPhoneInfo() {
    if (orderController.appController.selectedReceiptOption.value == ReceiptOptions.SMS.name) {
      return "Please enter your phone number";
    } else {
      return "Please enter your email address";
    }
  }

  placeAnOrder() async {
    setState(() {
      isLoading = true;
    });
    if (orderController.appController.selectedReceiptOption.value == ReceiptOptions.SMS.name) {
      orderController. phoneNumber = emailOrPhoneController.text;
    } else {
      orderController.email = emailOrPhoneController.text;
    }
    var isOrderPlaced = await orderController.placeOrder(context);
    setState(() {
      isLoading = false;
      if (isOrderPlaced) {
        currentStep = currentStep + 1;
      }
    });
  }
}
