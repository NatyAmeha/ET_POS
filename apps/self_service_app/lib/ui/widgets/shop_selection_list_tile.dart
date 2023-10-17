import 'package:flutter/material.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:self_service_app/ui/widgets/container_helper.dart';
import 'package:self_service_app/ui/widgets/textview_helper.dart';

class ShopSelectionListTile extends StatelessWidget {
  POSConfig posConfig;
  String? agentName;
  Function? onResumeButtonClicked;
  ShopSelectionListTile({
    required this.posConfig,
    required this.agentName,
    this.onResumeButtonClicked,
  });

  @override
  Widget build(BuildContext context) {
    return ContainerHelper(
      padding: 0,
      borderRadius: 10,
      borderColor: Colors.grey[300],
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextViewHelper(posConfig.name,textStyle: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 45),
                Row(
                  children: [
                    Icon(Icons.person,color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    TextViewHelper(agentName,textStyle: Theme.of(context).textTheme.titleLarge),
                    Spacer(),
                    posConfig.display_button_new!
                        ? FilledButton(
                            child: Text("New"),
                            onPressed: () {
                              onResumeButtonClicked?.call();
                            },
                          )
                        : Container(),
                    posConfig.display_button_resume!
                        ? FilledButton(
                            child: Text("Resume"),
                            onPressed: () {
                              onResumeButtonClicked?.call();
                            },
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
          if (posConfig.status != null)
            Positioned(
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadiusDirectional.only(topEnd: Radius.circular(10)
                    )
                  ),
                  child: TextViewHelper(posConfig.status, textColor: Colors.white),
                ),
              )
            )
        ],
      ),
    );
  }
}
