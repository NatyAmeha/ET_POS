import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hozmacore/shared_models/Response.dart' as AppResponse;
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/utils/ui_helper.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var appController = Get.find<AppController>();

  @override
  void initState() {
    Future.delayed(Duration(seconds: 1) , (){
      appController.getSplashInfo(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx((){
      return UiHelper.displayContent(
        content: Container(color: Colors.white,), 
        canShow: appController.splashResponseStatus == AppResponse.Status.COMPLETED, 
        errorMessage: appController.splashResponseErrorMessage,
        isLoading: appController.splashResponseStatus == AppResponse.Status.LOADING,
        onTryAgain: (){
          appController.getSplashInfo(context);
        });
    }),
    );
  }

  
}
