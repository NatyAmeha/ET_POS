//ProgressDialog
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:hozmacore/features/shop/model/cashOpen.dart';

import 'package:hozmacore/features/shop/model/cashClose.dart';
import 'AppConfiguration.dart';

class DialogHelper {
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
                    BoxShadow(color: Colors.grey,blurRadius: 5.0, offset: Offset(0.0, 5.0),)
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //CircularProgressIndicator(),
                    Container(
                      height: 50,
                      width: 50,
                      
                      child: Lottie.asset("assets/lottie/loading.json"),
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

  static confirmationDialog(
      BuildContext context, String title, String description,
      {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
        ),
        content: Text(
          description,
          style: Theme.of(context).textTheme.caption,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              closeDialog(ctx);
            },
            child: Text(
              "Cancel",
            ),
          ),
          TextButton(
            onPressed: () {
              if (onConfirm != null) {
                closeDialog(ctx);
                onConfirm();
              }
            },
            child: Text("Ok"),
          ),
        ],
      ),
    );
  }

  static double totalOpeningBalance = 0.0;
  static double totalClosingBalance = 0.0;
  static double difference = 0.0;
  static double countedBank = 0.0;
  static bool isCoinSelected = false;
  static List<AvailableCoin>? coins;
  static TextEditingController controller = TextEditingController(text: "0");
  static TextEditingController noteController = TextEditingController(text: "");
  static TextEditingController bankController =
      TextEditingController(text: "0");
  static bool isLeft =
      Configuration.DEFAULT_CURRENCY_POSITION == 'before' ? true : false;
  static String? symbol = Configuration.DEFAULT_CURRENCY_SYMBOL;

  static void openingBalanceDialog(BuildContext context, CashOpen cashOpen,
      {Function(Map<String, dynamic> value)? onConfirm}) {
    coins = cashOpen.availableCoins;
    coins?.forEach((element) {
      element.initialValue = 0;
    });
    // print(cashOpen.availableCoins?.firstOrNull?.initialValue.toString() + "wdgfhjgfjh");
    // print(coins?[0].initialValue.toString() + "hdwgfhd");
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: SingleChildScrollView(
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            title: Container(
              color: Colors.white12,
              margin: EdgeInsets.only(bottom: 12),
              child: Text(
                "OPENING CASH CONTROL",
                style: Theme.of(context)
                    .textTheme
                    .headline5!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            content: Column(
              children: <Widget>[
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          "Opening Cash",
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 50,
                        child: TextFormField(
                          onChanged: (val) {
                            isCoinSelected = false;
                            if (val != totalOpeningBalance.toString()) {
                              noteController.text = "";
                              val = val.trim();
                              print("that " + val);
                              if (val.isNotEmpty) {
                                totalOpeningBalance = double.parse(val);
                              }
                            }
                          },
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.center,
                          enabled: true,
                          controller: controller,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            hintText: "",
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          hideSoftKeyBoard();
                          qtyDialog(context);
                        },
                        icon: Icon(
                          Icons.analytics_outlined,
                          size: 46,
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    height: 100,
                    child: TextField(
                      controller: noteController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: "Notes",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(2))),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 6),
                      ),
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                )
              ],
              mainAxisSize: MainAxisSize.min,
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  var coinsUsed = {};
                  coins!.forEach((element) {
                    if (element.initialValue! > 0) {
                      coinsUsed.putIfAbsent(
                          element.id.toString(), () => element.initialValue);
                    }
                  });

                  var req = {
                    "coins": coinsUsed.isEmpty ? false : coinsUsed,
                    "openingcash": totalOpeningBalance,
                    "notes": noteController.text.toString()
                  };

                  if (onConfirm != null) {
                    onConfirm(req);
                  }
                },
                child: Text("Open session"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void closingBalanceDialog(BuildContext context, CashClose cashClose,
      {Function(Map<String, dynamic> value)? onConfirm, Function()? onOpen}) {
    coins = cashClose.paymentInput.values.first.availableCoins;
    coins!.forEach((element) {
      element.initialValue = 0;
    });
    controller.text = cashClose.paymentInput.values.first.counted.toString();
    totalOpeningBalance = 0.0;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, state) {
        controller.addListener(() {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            state(() {
              print("*********");
              // totalOpeningBalance = controller.text as double;
            });
          });
        });
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              title: Container(
                color: Colors.white12,
                margin: EdgeInsets.only(bottom: 12),
                child: Text(
                  "CLOSING CONTROL",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              content: Container(
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    ),
                    Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(
                                          "Total ${cashClose.ordersDetails.quantity} orders",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isLeft
                                              ? symbol! +
                                                  cashClose
                                                      .ordersDetails.amount!
                                                      .toStringAsFixed(2)
                                              : cashClose.ordersDetails.amount!
                                                      .toStringAsFixed(2) +
                                                  symbol!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(
                                          "Payments",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isLeft
                                              ? symbol! +
                                                  cashClose.paymentsAmount
                                                      .toStringAsFixed(2)
                                              : cashClose.paymentsAmount
                                                      .toStringAsFixed(2) +
                                                  symbol!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Text(
                                          "Customer Account",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          isLeft
                                              ? symbol! +
                                                  cashClose.payLaterAmount
                                                      .toStringAsFixed(2)
                                              : cashClose.payLaterAmount
                                                      .toStringAsFixed(2) +
                                                  symbol!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            height: 60,
                            child: SingleChildScrollView(
                              child: Text(
                                cashClose.openingNotes!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Table(
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(children: [
                            Text(
                              "Payment Method",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Expected",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Counted",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            Container(),
                            Text(
                              "Difference",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ]),
                          TableRow(children: [
                            Text(
                              cashClose.defaultCashDetails.name!,
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              isLeft
                                  ? symbol! +
                                      cashClose.defaultCashDetails.amount!
                                          .toStringAsFixed(2)
                                  : cashClose.defaultCashDetails.amount!
                                          .toStringAsFixed(2) +
                                      symbol!,
                              style: Theme.of(context).textTheme.caption,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              width: 10,
                              child: Center(
                                child: TextFormField(
                                  onChanged: (val) {
                                    isCoinSelected = false;
                                    if (val != totalOpeningBalance.toString()) {
                                      val = val.trim();
                                      noteController.text = "";
                                      state(() {
                                        if (val.isNotEmpty) {
                                          totalOpeningBalance =
                                              double.parse(val);
                                        }
                                      });
                                    }
                                  },
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  textAlign: TextAlign.center,
                                  enabled: true,
                                  controller: controller,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                    hintText: "",
                                    hintStyle:
                                        Theme.of(context).textTheme.caption,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                hideSoftKeyBoard();
                                qtyDialog(context);
                                state(() {
                                  totalOpeningBalance = 0.0;
                                });
                              },
                              icon: Icon(
                                Icons.analytics_outlined,
                                size: 24,
                              ),
                            ),
                            Text(
                              isLeft
                                  ? symbol! +
                                      (totalOpeningBalance +
                                              cashClose.paymentInput.values
                                                  .first.difference!)
                                          .toStringAsFixed(2)
                                  : (totalOpeningBalance +
                                              cashClose.paymentInput.values
                                                  .first.difference!)
                                          .toStringAsFixed(2) +
                                      symbol!,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                          cashClose.defaultCashDetails.opening! > 0
                              ? TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      "Opening",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  Text(
                                    isLeft
                                        ? symbol! +
                                            cashClose
                                                .defaultCashDetails.opening!
                                                .toStringAsFixed(2)
                                        : cashClose.defaultCashDetails.opening!
                                                .toStringAsFixed(2) +
                                            symbol!,
                                    style: Theme.of(context).textTheme.caption,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(),
                                  Container(),
                                  Container()
                                ])
                              : TableRow(children: [
                                  Container(),
                                  Container(),
                                  Container(),
                                  Container(),
                                  Container(),
                                ]),
                          cashClose.defaultCashDetails.paymentAmount! > 0
                              ? TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Text(
                                      "Opening",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ),
                                  Text(
                                    isLeft
                                        ? symbol! +
                                            cashClose.defaultCashDetails
                                                .paymentAmount!
                                                .toStringAsFixed(2)
                                        : cashClose.defaultCashDetails
                                                .paymentAmount!
                                                .toStringAsFixed(2) +
                                            symbol!,
                                    style: Theme.of(context).textTheme.caption,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Container(),
                                  Container(),
                                  Container()
                                ])
                              : TableRow(children: [
                                  Container(),
                                  Container(),
                                  Container(),
                                  Container(),
                                  Container(),
                                ]),
                          ...cashClose.otherPaymentMethods.map<TableRow>((pay) {
                            return TableRow(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  pay.name!,
                                  style: Theme.of(context).textTheme.caption,
                                ),
                              ),
                              Text(
                                isLeft
                                    ? symbol! + pay.amount!.toStringAsFixed(2)
                                    : pay.amount!.toStringAsFixed(2) + symbol!,
                                style: Theme.of(context).textTheme.caption,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Container(),
                              Container(),
                              Container(),
                            ]);
                          }).toList(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        margin: EdgeInsets.only(top: 30, bottom: 10),
                        height: 100,
                        child: TextField(
                          controller: noteController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: "Notes",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(2))),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 6),
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    )
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    var coinsUsed = {};
                    coins!.forEach((element) {
                      if (element.initialValue! > 0) {
                        coinsUsed.putIfAbsent(
                            element.id.toString(), () => element.initialValue);
                      }
                    });

                    var req = {
                      "coins": coinsUsed.isEmpty ? false : coinsUsed,
                      "amount": totalOpeningBalance,
                    };
                    if (onConfirm != null) {
                      onConfirm(req);
                    }
                  },
                  child: Text("Close Session"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (onOpen != null) {
                      onOpen();
                    }
                  },
                  child: Text("Keep Session Open"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Continue Selling"),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  static qtyDialog(BuildContext context) {
    if (!isCoinSelected) {
      clearData();
    }
    print(coins![0].initialValue.toString() + "gerjhgfhj" + coins![0].name!);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            child: AlertDialog(
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.zero,
              title: Container(
                color: Colors.white12,
                margin: EdgeInsets.only(bottom: 12),
                child: Text(
                  "Coins/Bills",
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              content: Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 300,
                      height: 300,
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 2,
                          // width / height: fixed for *all* items
                          childAspectRatio: 3,
                        ),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  width: 50,
                                  child: TextFormField(
                                    onChanged: (val) {
                                      val = val.trim();
                                      print("this" + val);
                                      if (val !=
                                          totalOpeningBalance.toString()) {
                                        if (val.isNotEmpty) {
                                          state(() {
                                            var t = coins![index].value *
                                                coins![index].initialValue!;
                                            totalOpeningBalance -= t;
                                            totalOpeningBalance +=
                                                coins![index].value *
                                                    double.parse(val);
                                            coins![index].initialValue =
                                                int.parse(val);
                                            if (coins![index].initialValue! >
                                                0) {
                                              isCoinSelected = true;
                                            }
                                            print(totalOpeningBalance);
                                          });
                                        }
                                      }
                                    },
                                    initialValue: "0",
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    enabled: true,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 2),
                                      hintText: "",
                                      hintStyle:
                                          TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ),
                                Text(
                                  coins![index].name!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: coins!.length,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Total ${Configuration.DEFAULT_CURRENCY_POSITION == 'before' ? Configuration.DEFAULT_CURRENCY_SYMBOL! + totalOpeningBalance.toStringAsFixed(2) : totalOpeningBalance.toStringAsFixed(2) + Configuration.DEFAULT_CURRENCY_SYMBOL!}",
                        style: Theme.of(context)
                            .textTheme
                            .headline5!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.grey,
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    isCoinSelected = true;
                    controller.text = totalOpeningBalance.toString();
                    String temp = "Money Details: \n";
                    coins!.forEach((element) {
                      if (element.initialValue != 0) {
                        String symbol =
                            Configuration.DEFAULT_CURRENCY_POSITION == 'before'
                                ? Configuration.DEFAULT_CURRENCY_SYMBOL! +
                                    element.value.toString()
                                : element.value.toString() +
                                    Configuration.DEFAULT_CURRENCY_SYMBOL!;
                        print(symbol);
                        temp += "-" +
                            element.initialValue!.toInt().toString() +
                            "x " +
                            symbol +
                            "\n";
                        print(temp);
                      }
                    });
                    if (totalOpeningBalance > 0) noteController.text = temp;
                    Navigator.of(context).pop(totalOpeningBalance);
                  },
                  child: Text("Confirm"),
                ),
                ElevatedButton(
                  onPressed: () {
                    isCoinSelected = false;
                    clearData();
                    Navigator.of(context).pop(0.0);
                  },
                  child: Text("Discard"),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  static clearData() {
    totalOpeningBalance = 0.0;
    controller.text = "0";
    noteController.text = "";
    coins!.forEach((element) {
      element.initialValue = 0;
    });
  }

  static void closeDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void hideSoftKeyBoard() {
    SystemChannels.textInput.invokeMethod("TextInput.hide");
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape &&
        MediaQuery.of(context).size.height > 600;
  }
}
