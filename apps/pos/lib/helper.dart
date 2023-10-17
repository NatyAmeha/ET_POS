import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hozmacore/datasource/shared_preference/shared_pref_repository.dart';
import 'package:hozmacore/shared_services/connectivity_service.dart';
import 'package:hozmacore/exception/app_exception.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/ui/widgets/CommonWidgets.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:odoo_pos/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class Helper{

  IConnectivityService? connectivityService;

  Helper({this.connectivityService});


  Stream<String> getNetworkConnectivity() {
    return connectivityService!.getConnectivityStatus();
  }

  static Future<R?> getDataFromPreference<R>(String name) async{
    try {
      var prefRepo = SharedPreferenceRepository();
      var result = await prefRepo.get<R>(name);
      return result;
    } on AppException catch (ex) {
      return Future.error(ex);
    }
  }

  static Future<bool> setDataToPreference<T>(String name , T data) async{
    try {
      var prefRepo = SharedPreferenceRepository();
      var result = await prefRepo.create<bool , T>(name , data);
      return result;
    } on AppException catch (ex) {
      return Future.error(ex);
    }
  }

  static Widget displayContent({
    required Widget content,
    required bool canShow,
    required BuildContext context,
    String? errorMessage,
    Widget? errorWidget,
    bool isLoading = false,
    Function? onTryAgain,
  }) {
      if (!canShow && errorMessage?.isNotEmpty == true) {
        return errorWidget ?? CommonWidgets.showErrorMessage(context, errorMessage!, onTryAgain: (){
          onTryAgain?.call();
        });
      } else {
        return Stack(
          children: [
            if (canShow) content,
            if (isLoading)
              DialogHelper.showProgressDialog(isLoading,)
          ],
      );
    }
  }

  static ScaffoldMessengerState showSnackbar(BuildContext context , String message , {Color? color = Colors.green , IconData? prefixIcon = Icons.check_circle , Duration duration = const Duration(seconds: 1)}){
    var snackbar =  ScaffoldMessenger.of(context);
    snackbar.removeCurrentSnackBar();
    snackbar.showSnackBar(SnackBar(
      backgroundColor: color ?? Colors.green,
      duration: duration,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(prefixIcon , color: Colors.white),
          const SizedBox(width: 16),
          Flexible(child: Text(message)) 
        ],
      ), 
      margin: EdgeInsets.symmetric(vertical: 70 , horizontal:  Helper.isTablet(context) ? 80 : 24),
    ));
    return snackbar;
  }

  static showAlertDialog(BuildContext context  , {required String title , required String description,
    String cancelText = "Cancel" , String confirmText = "Yes" , Function? onCancel , Function? onConfirm}){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(description),
              actions: <Widget>[
                TextButton(
                  child: TextView(cancelText,textColor: MyColors.primaryColor),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCancel?.call();
                  },
                ),
                ElevatedButton(
                  child: Text(confirmText),
                  style:
                      ElevatedButton.styleFrom(primary: MyColors.accentColor),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                )
              ],
            ));
  }

  static showModal(BuildContext context , Widget dialog, {bool dismissable = false}){
    showDialog(
      barrierLabel: "Barrier",
      barrierDismissible: dismissable,
      barrierColor: Colors.black.withOpacity(0.3),
      context: context,
      builder: (context) {
        return dialog;
      },
    );
  }
  

  static showPreviewModal(BuildContext context , double width , double height ,  {Uint8List? pdfData,   bool showPrintReciptBtn = false , String actionText = "Print receipt",  Function()? onTestPrintCalled} ) {
    Helper.showModal(
        context,
        dismissable: true,
        Center(
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                CustomContainer(
                  alignment: Alignment.topCenter,
                  width: width,
                  height: height,
                  child: SingleChildScrollView(
                    child: Column(
                        children: [
                          const SizedBox(height: 32),
                          TextView(AppLocalizations.of(context)!.submit_printing_receipt,textStyle: Theme.of(context).textTheme.displayMedium),
                          const SizedBox(height: 30),
                          Stack(children: [
                           
                            CustomContainer(
                              width: width,
                              height: height,
                              child: SizedBox()),
                            Positioned(
                              left: 24, right: 24,
                              child: Image.asset("assets/images/receipt_machine.png", width: 150 , height: 130,),
                            ),
                            Positioned.fill(
                              top:55,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Image.memory(Uint8List.fromList(pdfData!))))

                          ],),
                          const SizedBox(height: 80)
                        ],
                      ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: IconButton(onPressed: (){
                  Navigator.of(context).pop();
                }, icon: Icon(Icons.close),)),
                if(showPrintReciptBtn)
                Positioned.fill(
                  bottom: 24,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: FilledButton.icon(onPressed: (){
                      Navigator.of(context).pop();
                      onTestPrintCalled?.call();
                    }, icon: Icon(Icons.print), label: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(actionText))),
                  ))
              ],
            ),
          ),
        )); 
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape && MediaQuery.of(context).size.height > 600; 
  }

  static bool is900Breakpoint(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape && MediaQuery.of(context).size.width > 1000; 
  }

  static bool is900HeightBreakpoint(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape && MediaQuery.of(context).size.height > 1000; 
  }
}