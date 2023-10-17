import 'package:flutter/material.dart';
import 'package:odoo_pos/helper.dart';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Searchbar extends StatelessWidget {
  Function? onSearchbarClicked;
  Function? onMenuButtonClicked;
  String? title;
  IconData? icon;
  Searchbar(
      {super.key,
      this.title,
      this.icon,
      this.onSearchbarClicked,
      this.onMenuButtonClicked});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (Helper.isTablet(context)) ...[
          const SizedBox(width: 100),
          TextView(
            title ?? AppLocalizations.of(context)!.point_of_sell,
            textStyle: Theme.of(context).textTheme.displayLarge,
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.1),
        ],
        Helper.isTablet(context)
            ? buildSearchBox(context)
            : Expanded(child: buildSearchBox(context))
      ],
    );
  }

  buildSearchBox(BuildContext context) {
    return CustomContainer(
        onTap: () {
          onSearchbarClicked?.call();
        },
        borderColor: Colors.black87,
        borderRadius: 32,
        customPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        height: 50,
        width: Helper.isTablet(context)
            ? MediaQuery.of(context).size.width * 0.5
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 8),
                !Helper.isTablet(context)
                    ? InkWell(
                        onTap: () {
                          onMenuButtonClicked?.call();
                        },
                        child: Icon(icon ?? Icons.menu))
                    : SizedBox(),
                const SizedBox(width: 24),
                TextView(AppLocalizations.of(context)!.search_products,
                    textStyle: Theme.of(context).textTheme.bodyMedium)
              ],
            ),
            Icon(Icons.search)
          ],
        ));
  }
}
