import 'package:flutter/material.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/custom_text_field.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class WorkspaceComponent extends StatefulWidget {
  String? workSpaceUrl;
  Function(String workSpace) onNextCalled;
  WorkspaceComponent({this.workSpaceUrl, required this.onNextCalled});

  @override
  State<WorkspaceComponent> createState() => _WorkspaceComponentState();
}

class _WorkspaceComponentState extends State<WorkspaceComponent> {
  TextEditingController workspaceController = new TextEditingController();
  bool enableNext = false;

  @override
  void initState() {
    workspaceController.text = widget.workSpaceUrl ?? "";
    enableNext = workspaceController.text.isNotEmpty;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ContainerHelper(
      padding: 30,
      borderRadius: 32,
      addshadow: true,
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.7,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            TextViewHelper(
              "Welcome to hozma tech",
              textStyle: Theme.of(context).textTheme.titleMedium,
              textAlignment: TextAlign.center,
            ),
            SizedBox(height:50),
            TextViewHelper("Sign in",textSize: 50,setBold: true),
            TextViewHelper("to your workspace",
                textStyle: Theme.of(context).textTheme.displaySmall, maxline: 2,),
            const SizedBox(height: 40),
           TextViewHelper("Enter your workspace HOZMA TECH URL",
                textStyle: Theme.of(context).textTheme.titleMedium, maxline: 2,),
                const SizedBox(height: 8),
            TextFieldHelper(
              controller: workspaceController,
              hint: "Your workspace",
              label: "",
              autoFocus: true,
              suffix: TextViewHelper(
                ".hozma.tech",
                textStyle: Theme.of(context).textTheme.titleSmall,
                textColor: Colors.black,
                setBold: true,
              ),
              prefixIcon: Icons.workspaces,
              validator: (value) {
                if (value?.isEmpty == true) {
                  return "Fill the above field";
                }
              },
              onchanged: (value) {
                setState(() {
                  enableNext = workspaceController.text.isNotEmpty;
                });
              },
            ),
            const SizedBox(height: 45),
            FilledButton(
              child:Text("Next"),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              onPressed: enableNext
                ? () {
                  widget.onNextCalled(workspaceController.text);
                }
                : null,
            )
          ],
        ),
      ),
    );
  }
}
