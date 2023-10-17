import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';
import 'package:self_service_app/utils/ui_helper.dart';

class OrderOptionScreen extends StatefulWidget {
  const OrderOptionScreen({super.key});

  @override
  State<OrderOptionScreen> createState() => _OrderOptionScreenState();
}

class _OrderOptionScreenState extends State<OrderOptionScreen> {
  var appController = Get.find<AppController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
          child: Column(children: [
            TextViewHelper("Select where you'd like to Eat", textSize: 60, maxline: 3, textAlignment: TextAlign.center,),
            const SizedBox(height: 100),
            Expanded(
              child: GridView(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 500,
                  crossAxisSpacing: 50
                ),
                children: [
                  orderOptionListTile("Take Away", "assets/images/take_out.png",
                      () {
                    appController.selectOrderOption(
                        context, OrderOptionType.TAKE_AWAY);
                  }),
                  orderOptionListTile("Eat In", "assets/images/eat_in.png", () {
                    appController.selectOrderOption(
                        context, OrderOptionType.EAT_IN);
                  })
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }

  Widget orderOptionListTile(
      String title, String image, Function? onActionClicked) {
    return ContainerHelper(
      onTap: () {
        onActionClicked?.call();
      },
      padding: 32,
      borderWidth: 3,
      borderRadius: 16,
      borderColor: Colors.grey[300],
      child: Column(
        children: [
          CircleAvatar(
            radius: 150,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Image.asset(image, width: 170, height: 170),
          ),
          const SizedBox(height: 60),
          TextViewHelper(title,
              textStyle: Theme.of(context).textTheme.displayLarge),
        ],
      ),
    );
  }
}
