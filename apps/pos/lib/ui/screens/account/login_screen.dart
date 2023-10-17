import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/auth_controller.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/login_component.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:odoo_pos/ui/widgets/workspace_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class LoginScreen extends StatefulWidget {
  @override
  LoginState createState() => new LoginState();
}

class LoginState extends State<LoginScreen> {
  var authController = Get.put(AuthController());
  String? workSpace;
  String workSpacePrefix = "";
  var showWorkspace = true;

  @override
  initState() {
    Future.delayed(Duration.zero, () async {
      var workSpaceFromPreference =await authController.getWorkspaceUrl() ?? "";
      setWorkspaceUrl(workSpaceFromPreference);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx((){
        return Helper.displayContent(
          canShow: true, // content displayed from the get go, 
          isLoading: authController.isLoading,
          context: context,
          content: Stack(
            children: [
              Positioned.fill(
                child: Helper.isTablet(context)
                ? buildLoginContentForLargeScreen()
                : buildLoginContentForSmallScreen()
              ),
            ],
          ), 
        );
      }
    ));
  }

  buildLoginContentForSmallScreen() {
    return Stack(
      children: [
        Positioned.fill(
          top: 160,
          child: Align(
            alignment: Alignment.topCenter,
            child: CustomContainer(
              alignment: Alignment.topCenter,
              customPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: (workSpace != null)
                  ? showWorkspace
                      ? WorkspaceComponent(
                          workSpaceUrl: workSpacePrefix,
                          onNextCalled: (String workspaceUrl) {
                            setState(() {
                              showWorkspace = false;
                            });
                            setWorkspaceUrl(workspaceUrl);
                          })
                      : LoginComponent(
                          workSpace: workSpace!,
                          onLoginClicked: (email, password) {
                            authController.login(
                                email, password, workSpace!, context);
                          },
                          onbackBtnClicked: () {
                            setState(() {
                              showWorkspace = true;
                            });
                          },
                        )
                  : SizedBox(),
            ),
          ),
        ),
        Positioned(
          left: 24, top: 24,
          child: Align(
          alignment: Alignment.topLeft, 
          child: Row(
            children: [
              CustomContainer(
                padding: 0,
                borderRadius: 4,
                height: 25, width: 25 , color: Colors.white, child: TextView("h", textStyle: Theme.of(context).textTheme.titleLarge,),),
              const SizedBox(width: 8),
              TextView("hozma tech", textStyle: Theme.of(context).textTheme.titleMedium,textColor: Colors.white,)
            ],
          ),
          )
        ),
        Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Image.asset("assets/images/login_graphics.png",
                height: 150, width: 150)),
      ],
    );
  }

  buildLoginContentForLargeScreen() {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
          children: [
            Expanded(flex: 5, child: Container(color: Colors.black)),
            Expanded(flex: 3, child: Container(color: Colors.white))
          ],
        )),
        Positioned(
          left: 50, top: 24,
          child: Align(
          alignment: Alignment.topLeft, 
          child: Row(
            children: [
              CustomContainer(
                padding: 0,
                borderRadius: 4,
                height: 25, width: 25 , color: Colors.white, child: TextView("h", textStyle: Theme.of(context).textTheme.titleLarge,),),
              const SizedBox(width: 8),
              TextView("hozma tech", textStyle: Theme.of(context).textTheme.titleMedium,textColor: Colors.white,)
            ],
          ),
          )
        ),
        Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Image.asset("assets/images/login_graphics.png",
                height: 300, width: 300)),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 80),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextView(
                          AppLocalizations.of(context)!.company_description,
                          textStyle: Theme.of(context).textTheme.headlineLarge,
                          textColor: Colors.white,
                          maxline: 5,
                        ),
                        const SizedBox(height: 8),
                        TextView(
                          AppLocalizations.of(context)!.sign_in_description,
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                          maxline: 3,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 150),
                workSpace != null
                    ? Expanded(
                        flex: 3,
                        child: showWorkspace
                            ? WorkspaceComponent(
                                workSpaceUrl: workSpacePrefix,
                                onNextCalled: (String workspaceUrl) {
                                  setState(() {
                                    showWorkspace = false;
                                  });
                                  setWorkspaceUrl(workspaceUrl);
                                })
                            : LoginComponent(
                                workSpace: workSpace!,
                                onLoginClicked: (email, password) {
                                  authController.login(
                                      email, password, workSpace!, context);
                                },
                                onbackBtnClicked: () {
                                  setState(() {
                                    showWorkspace = true;
                                  });
                                },
                              ),
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
        
      ],
    );
  }

  setWorkspaceUrl(String workSpaceString) {
    setState(() {
      workSpacePrefix = workSpaceString.replaceAll(".hozma.tech", '').trim();
      workSpace = workSpacePrefix + ".hozma.tech";
    });
  }
}
