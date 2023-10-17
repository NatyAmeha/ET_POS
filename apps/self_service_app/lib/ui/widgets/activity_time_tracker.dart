import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class ActivityTimeTracker extends StatelessWidget {
  var appController = Get.find<AppController>();
  Function? onOrderReturn;
  Function? onCancelOrder;
  ActivityTimeTracker({super.key, this.onOrderReturn, this.onCancelOrder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: ContainerHelper(
          customPadding: const EdgeInsets.all(50),
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => TextViewHelper(
                          "${appController.timeToCompleteOrder.value.toString().substring(2, 7)}",
                          textColor: Colors.red,
                          textStyle: Theme.of(context).textTheme.displaySmall),
                    ),
                    TextViewHelper("Are you there?",
                        textStyle: Theme.of(context).textTheme.displayMedium),
                    IconButton(
                        onPressed: () {
                          onOrderReturn?.call();
                        },
                        icon: Icon(Icons.close),
                        iconSize: 40),
                  ],
                ),
                const SizedBox(height: 40),
                Image.asset("assets/images/timer.png", width: 400, height: 400),
                const SizedBox(height: 24),
                TextViewHelper(
                  "There haven't been any screen activity",
                  textStyle: Theme.of(context).textTheme.bodyLarge,
                  textAlignment: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 500,
                  child: FilledButton(
                    onPressed: () {
                      onOrderReturn?.call();
                    },
                    child: Text("Return to my order"),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 500,
                  child: OutlinedButton(
                    onPressed: () {
                      onCancelOrder?.call();
                    },
                    child: Text("Cancel my order"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
