import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/custom_text_field.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

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
    return ContainerHelper(
      padding: 30,
      borderRadius: 32,
      height: MediaQuery.of(context).size.height * 0.8,
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
              Flexible(child: TextViewHelper("${widget.workSpace}", maxline: 3, textStyle: Theme.of(context).textTheme.bodyMedium,textColor: Colors.black,)),
            ],),
            const SizedBox(height: 24),
            TextViewHelper("Sign in",
            textSize: 50, setBold: true,
                ),
            TextViewHelper("to your workspace",
                textStyle: Theme.of(context).textTheme.displaySmall, maxline: 2),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextViewHelper("Enter your username",
                      textStyle: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFieldHelper(
                    controller: emailControler,
                    hint: "Enter Email",
                    label: "Email",
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return "Fill the above field";
                      }
                    },
                    onchanged: (value) {
                      setState(() {
                        enableLoginBtn = canEnableLoginBtn();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  TextViewHelper("Enter your password",
                      textStyle: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextFieldHelper(
                    controller: passWordControler,
                    inputType: TextInputType.visiblePassword,
                    prefixIcon: Icons.key,
                    hint: "Enter password",
                    label: "Password",
                    obscureText: _obscure,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return "Fill the above field";
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
                  SizedBox(height: 75),
                  FilledButton(
                      child: Text("Login"),
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
