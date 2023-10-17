import 'package:flutter/material.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/controller/app_controller.dart';
import 'package:odoo_pos/resource/strings/string.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/custom_text_field.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginComponent extends StatefulWidget {
  String workSpace;
  final Function(String email, String password) onLoginClicked;
  Function? onbackBtnClicked;
  LoginComponent({super.key, required this.workSpace, required this.onLoginClicked, this.onbackBtnClicked});

  @override
  State<LoginComponent> createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailControler = new TextEditingController();
  TextEditingController passWordControler = new TextEditingController();
  bool enableLoginBtn = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: 30,
      borderRadius: 32,
      height: Helper.isTablet(context) ? MediaQuery.of(context).size.height * 0.8 : MediaQuery.of(context).size.height * 0.7,
      addshadow: true,
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
              IconButton(onPressed: (){
                widget.onbackBtnClicked?.call();
              }, icon: Icon(Icons.arrow_back)),
              const SizedBox(width: 16),
              Flexible(child: TextView("${widget.workSpace}", maxline: 3, textStyle: Theme.of(context).textTheme.bodyMedium,textColor: Colors.black,)),
            ],),
            const SizedBox(height: 24),
            TextView(AppLocalizations.of(context)!.workspaceSignin,
            textSize: 50, setBold: true,
                ),
            TextView(AppLocalizations.of(context)!.workspaceMessage,
                textStyle: Theme.of(context).textTheme.displaySmall, maxline: 2),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextView(AppLocalizations.of(context)!.workspaceUsername,
                      textStyle: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: emailControler,
                    hint: Strings.EMAIL_PLACEHOLDER,
                    label: AppLocalizations.of(context)!.username,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return AppLocalizations.of(context)!
                            .text_field_error_message;
                      }
                    },
                    onchanged: (value) {
                      setState(() {
                        enableLoginBtn = canEnableLoginBtn();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextView(AppLocalizations.of(context)!.workspacePassword,
                      textStyle: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: passWordControler,
                    inputType: TextInputType.visiblePassword,
                    prefixIcon: Icons.key,
                    hint: Strings.PASSWORD_PLACEHOLDER,
                    label: AppLocalizations.of(context)!.password,
                    obscureText: _obscure,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return AppLocalizations.of(context)!
                            .text_field_error_message;
                      }
                    },
                    onchanged: (value) {
                      setState(() {
                        enableLoginBtn = canEnableLoginBtn();
                      });
                    },
                    suffix: InkWell(
                        child: _obscure
                            ? Icon(Icons.visibility_off)
                            : Icon((Icons.visibility)),
                        onTap: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        }),
                  ),
                  SizedBox(height: Helper.isTablet(context) ? 75 : 40),
                  FilledButton(
                      child: Text(AppLocalizations.of(context)!.login),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                        ),
                      onPressed: enableLoginBtn
                        ? () async {
                          if (canEnableLoginBtn()) {
                            widget.onLoginClicked(emailControler.text,passWordControler.text);
                          }
                        }
                        : null),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool canEnableLoginBtn() {
    return (emailControler.text.isNotEmpty &&
        passWordControler.text.isNotEmpty);
  }
}
