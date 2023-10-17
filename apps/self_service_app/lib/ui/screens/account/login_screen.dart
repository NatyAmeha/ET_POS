import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:self_service_app/controller/auth_controller.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/login_component.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';
import 'package:self_service_app/ui/widgets/workspace_component.dart';
import 'package:self_service_app/utils/ui_helper.dart';

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
      var workSpaceFromPreference =
          await authController.getWorkspaceUrl() ?? "";
      setWorkspaceUrl(workSpaceFromPreference);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          return UiHelper.displayContent(
            canShow: true, // content displayed from the get go,
            isLoading: authController.isLoading,
            content: Stack(
              children: [
                Positioned.fill(
                    child: buildLoginContentForSmallScreen()),
              ],
            ),
          );
        }));
  }

  buildLoginContentForSmallScreen() {
    return Stack(
      children: [
        Positioned.fill(
          top: 160,
          child: Align(
            alignment: Alignment.topCenter,
            child: ContainerHelper(
              alignment: Alignment.topCenter,
              customPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
            left: 24,
            top: 24,
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  ContainerHelper(
                    padding: 0,
                    borderRadius: 4,
                    height: 25,
                    width: 25,
                    color: Colors.white,
                    child: TextViewHelper(
                      "h",
                      textStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextViewHelper(
                    "hozma tech",
                    textStyle: Theme.of(context).textTheme.titleMedium,
                    textColor: Colors.white,
                  )
                ],
              ),
            )),
        Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Image.asset("assets/images/login_graphics.png",
                height: 150, width: 150)),
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
