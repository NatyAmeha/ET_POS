import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:self_service_app/ui/screens/onboarding/splash_screen.dart';
import 'package:self_service_app/utils/app_config_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  if (!Platform.isIOS) {
    databaseFactory = databaseFactoryFfi;
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
  
  // called when from language selector in onboarding screen
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }

  static void setPrimaryColor(BuildContext context, Color selectedColor){
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeThemePrimaryColor(selectedColor);
  }
}

class _MyAppState extends State<MyApp> {
  var appController = Get.put(AppController());
  var selectedLanguage = LanguageEnum.ENGLISH.name;

  late Locale _local = Locale("en", '');
  ThemeData appTheme = AppTheme.Light;
  
  
  changeLanguage(Locale locale) {
    setState(() {
      _local = locale;
    });
  }

  changeThemePrimaryColor(Color selectedColor){
    setState(() {
       appTheme = AppTheme.updatePrimaryColor(selectedColor);
    });
  }

  @override
  void initState() {
    Future.delayed(Duration.zero , () async {
      setState(() {
        _local = AppConfigHelper.getSelectedLocal(LanguageEnum.ENGLISH.name);
      });
     
    });
    super.initState();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanDown: (dete){
        appController.restartTimer();
        
      },
      onTap: () {
        appController.restartTimer();
        
      },
      child: MaterialApp(
        title: 'Flutter Demo',
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
        locale: _local,
        theme:appTheme,
        home:  SplashScreen(),
      ),
    );
  }
}
