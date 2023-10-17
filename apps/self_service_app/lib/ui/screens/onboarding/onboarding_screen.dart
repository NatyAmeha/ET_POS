import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/controller/app_controller.dart';
import 'package:self_service_app/main.dart';
import 'package:self_service_app/ui/screens/onboarding/order_option_screen.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';
import 'package:self_service_app/utils/ui_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  var appController = Get.find<AppController>();

  @override
  void initState() {
    Future.delayed(Duration.zero,(){
      appController.initializedTimerContext(context);
      MyApp.setPrimaryColor(context, appController.companyInfo?.primary_color?.toColor());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: Container(
            width: double.infinity,
            child: SizedBox(),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            color: Theme.of(context).colorScheme.primary,
            child: SizedBox(),
          ),
        ),
        Positioned.fill(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16), 
              Image.asset(
                "assets/images/logo.png",
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.height * 0.2,
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      "assets/images/splash_screen.png",
                      height: MediaQuery.of(context).size.height * 0.65,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                      child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextViewHelper(
                          AppLocalizations.of(context)!.order,
                            textSize: 60, textColor: Colors.white),
                        TextViewHelper(
                          AppLocalizations.of(context)!.here,
                            setBold: true,
                            textSize: 60,
                            textColor: Colors.white),
                      ],
                    ),
                  )),
                  Positioned(
                    bottom: 40,
                    left: 40,
                    right: 40,
                    child: FilledButton(
                      onPressed: () {
                        appController.startTimerForActivityTracking();
                        Navigator.of(context).push( MaterialPageRoute(builder: (c) => OrderOptionScreen()));
                      },
                      child: Text(AppLocalizations.of(context)!.get_started),
                    ),
                  )
                ],
              ),
              Spacer(),
              languageSelector(),
              const SizedBox(height: 32),
            ],
          ),
        )
      ],
    ));
  }

  languageSelector() {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          appController.selectedLanguage.value == LanguageEnum.ENGLISH.name
              ? FilledButton(
                  onPressed: () {
                    appController.changeLanguage(context, LanguageEnum.ENGLISH);
                  },
                  child: Row(
                    children: [
                      Image.asset("assets/images/english_flag.png",
                          height: 25, width: 40, fit: BoxFit.cover,),
                      const SizedBox(width: 10),
                      Text("English")
                    ],
                  ),
                )
              : OutlinedButton(
                  onPressed: () {
                    appController.changeLanguage(context , LanguageEnum.ENGLISH);
                  },
                  child: Row(
                    children: [
                      Image.asset("assets/images/english_flag.png",
                          height: 25, width: 50, fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 10),
                      Text("English")
                    ],
                  ),
                ),
          const SizedBox(width: 40),
          appController.selectedLanguage.value == LanguageEnum.ARABIC.name
              ? FilledButton(
                  onPressed: () {
                    appController.changeLanguage(context, LanguageEnum.ARABIC);
                  },
                  child: Row(
                    children: [
                      Image.asset("assets/images/saudi_flag.png",
                          height: 25, width: 50),
                      const SizedBox(width: 8),
                      Text("عربي")
                    ],
                  ),
                )
              : OutlinedButton(
                  onPressed: () {
                    appController.changeLanguage(context , LanguageEnum.ARABIC);
                  },
                  child: Row(
                    children: [
                      Image.asset("assets/images/saudi_flag.png",
                          height: 25, width: 50),
                      const SizedBox(width: 8),
                      Text("Arabic")
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
