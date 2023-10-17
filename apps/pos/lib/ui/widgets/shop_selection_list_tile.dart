import 'package:flutter/material.dart';
import 'package:hozmacore/features/auth/model/loginResponse.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return CustomContainer(
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
                TextView(posConfig.name,textStyle: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 55),
                Row(
                  children: [
                    Icon(Icons.person,color: Theme.of(context).colorScheme.secondary),
                    const SizedBox(width: 8),
                    TextView(agentName,textStyle: Theme.of(context).textTheme.titleLarge),
                    Spacer(),
                    posConfig.display_button_new!
                        ? FilledButton(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(AppLocalizations.of(context)!.startPOSProfile),
                            ),
                            onPressed: () {
                              onResumeButtonClicked?.call();
                            },
                          )
                        : Container(),
                    posConfig.display_button_resume!
                        ? FilledButton(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(AppLocalizations.of(context)!.resumePOSProfile),
                            ),
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
                  child: TextView(posConfig.status, textColor: Colors.white),
                ),
              )
            )
        ],
      ),
    );
  }
}
