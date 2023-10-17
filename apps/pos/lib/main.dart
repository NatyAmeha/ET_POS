import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hozmacore/features/order/model/product/product.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/theme.dart';
import 'package:odoo_pos/ui/screens/customer/customer_display_screen.dart';
import 'package:odoo_pos/ui/screens/splash_screen.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isWindows || Platform.isMacOS || Platform.isLinux){
    try{
      await windowManager.ensureInitialized();
    }catch(ex){
      print("exception $ex");
    }
  }
  
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  if (!Platform.isIOS) {
    databaseFactory = databaseFactoryFfi;
  }

  if (args.firstOrNull == 'multi_window') {
    final argument = args[2].isEmpty
        ? const {}
        : jsonDecode(args[2]) as Map<String, dynamic>;
    runApp(CustomerDisplayApp(args: argument));
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  // load AppController
  var loadAppController = Get.lazyPut(() => AppController());
  MyApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'hozma.tech PoS',
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('ar', ''), // Arabic, no country code
      ],
      locale: Locale('en', ''),
      theme: AppTheme.Light ,
      home: SplashScreen(),
    );
  }
}



class CustomerDisplayApp extends StatefulWidget {
  final Map? args;
  var appController = Get.put(AppController());
  CustomerDisplayApp({
    Key? key,
    required this.args, 
  }) : super(key: key);

  @override
  State<CustomerDisplayApp> createState() => _CustomerDisplayAppState();
}

class _CustomerDisplayAppState extends State<CustomerDisplayApp> with WindowListener {
  void initState() { 
    super.initState();
    if (Platform.isWindows || Platform.isLinux){
      _init();
    }
  }

  void _init() async {
    windowManager.addListener(this);
    await windowManager.setFullScreen(true);
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setPreventClose(true);
    // fetch taxes from db for customer display price calculation
    await widget.appController.getTaxInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var prod = widget.args!["products"]as List<dynamic>;
    var cartProducts = prod.map((e) => Product.fromJson(e)).toList();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'hozma.tech PoS',
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', ''), // English, no country code
        Locale('ar', ''), // Arabic, no country code
      ],
      locale: Locale('en', ''),
      theme: AppTheme.Light ,
      home: CustomerDisplayScreen(cartProducts: cartProducts, totalAmount:  widget.args!["totalAmount"], totalVATAmount:  widget.args!["totalVATAmount"], currencyPosition:  widget.args!["currencyPosition"] , currencySymbol:  widget.args!["currencySymbol"],),
    );
  }

  @override
  void onWindowClose() {
    if(widget.appController.canCloseCustomerWindowFromMainWindow == true){
      windowManager.setPreventClose(false);
      windowManager.close();
    }
  }
}
