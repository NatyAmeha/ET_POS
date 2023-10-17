import 'package:flutter/material.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class UiHelper {
  static Widget displayContent({
    required Widget content,
    required bool canShow,
    String? errorMessage,
    Widget? errorWidget,
    bool isLoading = false,
    Function? onTryAgain,
  }) {
    if (!canShow && errorMessage?.isNotEmpty == true) {
      return errorWidget ??
          showErrorMessage(errorMessage!, onTryAgain: () {
            onTryAgain?.call();
          });
    } else {
      return Stack(
        children: [
          if (canShow) content,
          if (isLoading) showProgressDialog(isLoading)
        ],
      );
    }
  }

  static showErrorMessage(String message, {Function? onTryAgain}) {
    return Material(
      child: ContainerHelper(
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
                      child: Text(
                        'Error',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(message),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: () {
                          onTryAgain?.call();
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text("Try again")))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget showProgressDialog(bool isLoading) {
    Widget _drawerWidget = Visibility(
      visible: isLoading,
      child: Container(
        child: SafeArea(
          child: SizedBox.expand(
            child: Center(
              child: Container(
                height: 100.0,
                width: 100.0,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 5.0,
                        offset: Offset(0.0, 5.0),
                      )
                    ]),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //CircularProgressIndicator(),
                    Container(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                    // Lottie.asset("assets/lottie/loading.json", height: 50, width: 50),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: Text(
                        "Please wait",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14.0,
                            decoration: TextDecoration.none),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        color: Colors.transparent,
      ),
    );
    return _drawerWidget;
  }

  static ScaffoldMessengerState showSnackbar(
      BuildContext context, String message,
      {Color? color = Colors.green,
      IconData? prefixIcon = Icons.check_circle,
      Duration duration = const Duration(seconds: 1)}) {
    var snackbar = ScaffoldMessenger.of(context);
    snackbar.removeCurrentSnackBar();
    snackbar.showSnackBar(SnackBar(
      backgroundColor: color ?? Colors.green,
      duration: duration,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(prefixIcon, color: Colors.white),
          const SizedBox(width: 16),
          Flexible(child: Text(message))
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 70, horizontal: 80),
    ));
    return snackbar;
  }

  static showAlertDialog(BuildContext context,
      {required String title,
      required String description,
      String cancelText = "Cancel",
      String confirmText = "Yes",
      Function? onCancel,
      Function? onConfirm}) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(description),
              actions: <Widget>[
                OutlinedButton(
                  child: Text(cancelText),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCancel?.call();
                  },
                ),
                FilledButton(
                  child: Text(confirmText),
                  onPressed: () {
                    Navigator.of(context).pop();
                    onConfirm?.call();
                  },
                )
              ],
            ));
  }

  static showBottomsheetDialog(BuildContext context ,  Widget content , {double width = double.infinity, double height = double.infinity, double horizontalMargin = 0, double verticalMargin = 0, bool dismissable = true, }){
    showModalBottomSheet(context: context,
    isDismissible: true,
    useSafeArea: true, 
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),

    ),
    constraints: BoxConstraints(
      maxWidth: width, 
      minHeight: MediaQuery.of(context).size.height * 0.5,
      maxHeight: height
    ),
     builder: (context) => ContainerHelper(
      color: Colors.white,
      borderRadius: 20,
      customMargin: EdgeInsets.only(left: horizontalMargin, right: horizontalMargin, bottom: verticalMargin),
      customPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: content)
    );
  } 

  static showModal(BuildContext context, Widget dialog,
      {bool dismissable = false}) {
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
}


extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}
