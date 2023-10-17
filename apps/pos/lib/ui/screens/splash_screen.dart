import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:hozmacore/shared_models/Response.dart' as AppResponse;



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
      return Helper.displayContent(
        content: Container(color: Colors.white,), 
        canShow: appController.splashResponseStatus == AppResponse.Status.COMPLETED, 
        errorMessage: appController.splashResponseErrorMessage,
        isLoading: appController.splashResponseStatus == AppResponse.Status.LOADING,
        context: context,
        onTryAgain: (){
          appController.getSplashInfo(context);
        });
    }),
    );
  }

  loadingSplashScreen() {
    return Stack(
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 200),
            color: Colors.white,
            child: Image(
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width > 600 ? 248 : 148,
                height: MediaQuery.of(context).size.width > 600 ? 248 : 148,
                image: AssetImage('assets/images/logo.png'))),
        Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 100),
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator())
      ],
    );
  }

  
}
