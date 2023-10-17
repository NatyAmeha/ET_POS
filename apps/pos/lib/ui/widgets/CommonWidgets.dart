import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:odoo_pos/resource/myStyle/MyColors.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../resource/strings/string.dart';

class CommonWidgets {
  static showProgressbar() {
    return Material(
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 50),
          padding: EdgeInsets.only(top: 15, bottom: 15),
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             // CircularProgressIndicator(),
              Container(
                height: 50,
                width: 50,
                child: Lottie.asset("assets/lottie/loading.json"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(Strings.LOADING),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static emptyMessage() {
    return Center(
      child: Text(
        Strings.NO_DATA_FOUND,
        style: TextStyle(
            color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  static showErrorMessage(BuildContext context,  String message, {Function? onTryAgain})  {
    return Material(
      child: CustomContainer(
        color: Colors.white,
        child: Center(
          child: Wrap(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 50),
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.white,
                  borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(AppLocalizations.of(context)!.error, style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),),
                    ),
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: (){
                      onTryAgain?.call();
                    }, child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(AppLocalizations.of(context)!.try_again)))
      
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  static showHoldCartMaterialDialog(BuildContext context,String message) {
    return showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("${AppLocalizations.of(context)!.error} !"),
          content: new Text(message),
          actions: <Widget>[
            TextButton(
              child: TextView(AppLocalizations.of(context)!.cancel,textColor: MyColors.primaryColor),
              onPressed: () {
                // Navigator.of(context).pop();
              },
            ),
          ],
        ));
  }
}
