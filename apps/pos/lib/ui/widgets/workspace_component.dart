import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/custom_text_field.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';

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
    return CustomContainer(
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
            TextView(
              AppLocalizations.of(context)!.workspaceWelcome,
              textStyle: Theme.of(context).textTheme.titleMedium,
              textAlignment: TextAlign.center,
            ),
            SizedBox(height: Helper.isTablet(context) ? 50 : 50),
            TextView(AppLocalizations.of(context)!.workspaceSignin,textSize: 50,setBold: true),
            TextView(AppLocalizations.of(context)!.workspaceMessage,
                textStyle: Theme.of(context).textTheme.displaySmall, maxline: 2,),
            const SizedBox(height: 40),
           TextView(AppLocalizations.of(context)!.workspaceEnterUrl,
                textStyle: Theme.of(context).textTheme.titleMedium, maxline: 2,),
                const SizedBox(height: 8),
            CustomTextField(
              controller: workspaceController,
              hint: AppLocalizations.of(context)!.your_workspace,
              label: "",
              autoFocus: true,
              suffix: TextView(
                ".hozma.tech",
                textStyle: Theme.of(context).textTheme.titleSmall,
                textColor: Colors.black,
                setBold: true,
              ),
              prefixIcon: Icons.workspaces,
              validator: (value) {
                if (value?.isEmpty == true) {
                  return AppLocalizations.of(context)!.text_field_error_message;
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
              child:Text(AppLocalizations.of(context)!.workspaceNext),
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
