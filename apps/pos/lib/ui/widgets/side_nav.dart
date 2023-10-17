import 'dart:io';
import 'package:odoo_pos/ui/widgets/custom_container.dart';
import 'package:odoo_pos/ui/widgets/textview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';



class SideNav extends StatefulWidget {
  int selectedIndex;
  int? customerDisplayWindowId;
  Function(int) onPageSelected;
  Function? onQrCodeButtonClicked;
  Function? onCloseClicked;
  Future<int?>? Function()?  onOpenCustomerWindowClicked;
  Future<bool> Function(int)? onCustomerCloseWindowClicked;
  SideNav({super.key, required this.selectedIndex, required this.onPageSelected, this.customerDisplayWindowId ,  
  this.onCloseClicked,  this.onQrCodeButtonClicked, 
  this.onCustomerCloseWindowClicked, this.onOpenCustomerWindowClicked});

  @override
  State<SideNav> createState() => _SideNavState();

}

class _SideNavState extends State<SideNav> {
  // var appController = Get.find<AppController>();
  int? _windowId;

  @override
  void initState() {
    _windowId = widget.customerDisplayWindowId;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width > 600 ? 40 : 40,
                    height: MediaQuery.of(context).size.width > 600 ? 40 : 40,
                    image: AssetImage('assets/images/logo.png')),
                IconButton(
                    onPressed: () {
                      widget.onCloseClicked?.call();
                    },
                    icon: Icon(Icons.close))
              ],
            ),
          ),
          const SizedBox(height: 32),
          ListView(shrinkWrap: true, children: [
            ListTile(
              leading: Icon(Icons.home),
              minVerticalPadding: 16,
              tileColor: widget.selectedIndex == 0
                  ? Theme.of(context).colorScheme.background
                  : Colors.white,
              title: TextView(
                AppLocalizations.of(context)!.home,
                textStyle: Theme.of(context).textTheme.titleMedium,
                setBold: widget.selectedIndex == 0,
              ),
              onTap: () {
                widget.onPageSelected(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt_outlined),
              minVerticalPadding: 16,
              tileColor: widget.selectedIndex == 1
                  ? Theme.of(context).colorScheme.background
                  : Colors.white,
              title: TextView(
                AppLocalizations.of(context)!.orders,
                textStyle: Theme.of(context).textTheme.titleMedium,
                setBold: widget.selectedIndex == 1,
              ),
              onTap: () {
                  widget.onPageSelected(1);
              },
            ),
            ListTile(
              minVerticalPadding: 16,
              leading: Icon(Icons.stop_circle),
              tileColor: widget.selectedIndex == 2
                  ? Theme.of(context).colorScheme.background
                  : Colors.white,
              title: TextView(AppLocalizations.of(context)!.hold_cart,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  setBold: widget.selectedIndex == 2),
              onTap: () {
                widget.onPageSelected(2);
              },
            ),
            ListTile(
              minVerticalPadding: 16,
              leading: Icon(Icons.print),
              tileColor: widget.selectedIndex == 3
                  ? Theme.of(context).colorScheme.background
                  : Colors.white,
              title: TextView(AppLocalizations.of(context)!.printer_setting,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  setBold: widget.selectedIndex == 3),
              onTap: () {
                widget.onPageSelected(3);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              minVerticalPadding: 16,
              tileColor: widget.selectedIndex == 4
                  ? Theme.of(context).colorScheme.background
                  : Colors.white,
              title: TextView(AppLocalizations.of(context)!.profile,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  setBold: widget.selectedIndex == 4),
              onTap: () {
                widget.onPageSelected(4);
              },
            ),
            if(Platform.isWindows || Platform.isMacOS || Platform.isLinux)
              customerDisplayManager()
          ]),
          Spacer(),
          Container(
            child: IconButton(
              icon: Icon(Icons.qr_code_scanner_outlined, size: 32),
              onPressed: () {
                widget.onQrCodeButtonClicked?.call();
                // readQr(context);
              },
            ),
            margin: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  Widget customerDisplayManager(){
    return CustomContainer(
      margin: 8,
      borderRadius: 8,
      padding: 8,
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Row(children: [
          TextView(AppLocalizations.of(context)!.customer_display,textStyle: Theme.of(context).textTheme.titleLarge,),
        ],),
        const SizedBox(height: 8),
        if(_windowId != null)
          ListTile(
            minLeadingWidth: 0,
            contentPadding: EdgeInsets.zero,
            leading:  Icon(Icons.display_settings),
            tileColor: widget.selectedIndex == 5
              ? Theme.of(context).colorScheme.background
              : Colors.white,
            title: TextView(AppLocalizations.of(context)!.customer_display_one,textStyle: Theme.of(context).textTheme.bodyLarge, textColor: Theme.of(context).colorScheme.tertiary,),
            trailing: InkWell(
              onTap: () async {
              var isClosed = await widget.onCustomerCloseWindowClicked?.call(_windowId!);
              if(isClosed == true){
                setState(() {
                  _windowId = null;
                });
               }
              },
              child: Icon(Icons.close, color: Colors.red,)),
          ),

        if(_windowId == null) ...[
          const SizedBox(height: 16),  
          FilledButton(onPressed: () async {
            var id = await widget.onOpenCustomerWindowClicked?.call();
            setState(() {
              _windowId = id;
            });
          }, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(AppLocalizations.of(context)!.open_customer_display)),)
          ]
              
      ],),
    );
  }
}
